#!/bin/bash
# Mac mini server setup (Apple Silicon / macOS)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER_BREWFILE="$REPO_DIR/Brewfile.server"
N8N_TEMPLATE="$REPO_DIR/server/launchd/com.tomkenta.n8n.plist.template"
N8N_DATA_DIR="$HOME/Library/Application Support/KentaOS/n8n"
LOG_DIR="$HOME/Library/Logs/KentaOS"
PYTHON_ENV="$HOME/.local/share/kenta-os/python"
LAUNCH_DAEMON="/Library/LaunchDaemons/com.tomkenta.n8n.plist"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "This script supports macOS only." >&2
  exit 1
fi

if [ "$(uname -m)" != "arm64" ]; then
  echo "Warning: this setup is designed for Apple Silicon, but found $(uname -m)." >&2
fi

if ! /usr/bin/dscl . -read "/Groups/admin" GroupMembership 2>/dev/null | grep -qw "$(id -un)"; then
  echo "Run this script from an administrator account." >&2
  exit 1
fi

echo "==> [1/8] Administrator authorization"
sudo -v

echo "==> [2/8] macOS server settings"
sudo /usr/sbin/systemsetup -setremotelogin on
sudo /bin/launchctl enable system/com.apple.screensharing
sudo /bin/launchctl kickstart -k system/com.apple.screensharing

sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

# Keep a headless server awake and ask macOS to restart it after power returns.
sudo /usr/bin/pmset -a sleep 0 autorestart 1 powernap 1 tcpkeepalive 1 womp 1

echo "==> [3/8] Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  echo "Homebrew was installed but could not be found." >&2
  exit 1
fi

BREW_PREFIX="$(brew --prefix)"
BREW_SHELLENV="eval \"\$($BREW_PREFIX/bin/brew shellenv)\""

touch "$HOME/.zprofile"
if ! grep -Fqx "$BREW_SHELLENV" "$HOME/.zprofile"; then
  printf '\n%s\n' "$BREW_SHELLENV" >> "$HOME/.zprofile"
fi

echo "==> [4/8] Minimal server packages"
brew bundle --file="$SERVER_BREWFILE"
brew link --overwrite --force node@22 >/dev/null 2>&1 || true
export PATH="$BREW_PREFIX/opt/node@22/bin:$BREW_PREFIX/bin:/usr/bin:/bin:/usr/sbin:/sbin"

if [[ "$(node --version)" != v22.* ]]; then
  echo "Expected Node.js 22, but found $(node --version)." >&2
  exit 1
fi

if [ ! -d /Applications/Tailscale.app ]; then
  brew install --cask tailscale
else
  echo "Tailscale.app already exists; skipping installation."
fi

echo "==> [5/8] AI command-line tools and n8n"
for package_name in n8n @anthropic-ai/claude-code @openai/codex; do
  if ! npm list --global --depth=0 "$package_name" >/dev/null 2>&1; then
    npm install --global "$package_name"
  fi
done

echo "==> [6/8] Python and LangGraph"
if [ ! -x "$PYTHON_ENV/bin/python" ]; then
  uv venv --python 3.12 "$PYTHON_ENV"
fi
uv pip install --python "$PYTHON_ENV/bin/python" --requirements "$REPO_DIR/server/requirements.txt"

echo "==> [7/8] n8n LaunchDaemon"
mkdir -p "$N8N_DATA_DIR" "$LOG_DIR"
chmod 700 "$N8N_DATA_DIR" "$LOG_DIR"

N8N_KEY_FILE="$N8N_DATA_DIR/.encryption-key"
if [ ! -s "$N8N_KEY_FILE" ]; then
  /usr/bin/openssl rand -hex 32 > "$N8N_KEY_FILE"
  chmod 600 "$N8N_KEY_FILE"
fi
N8N_ENCRYPTION_KEY="$(tr -d '\n' < "$N8N_KEY_FILE")"
TEMP_PLIST="$(mktemp -t com.tomkenta.n8n.XXXXXX)"
trap 'rm -f "$TEMP_PLIST"' EXIT

/usr/bin/sed \
  -e "s|__BREW_PREFIX__|$BREW_PREFIX|g" \
  -e "s|__HOME__|$HOME|g" \
  -e "s|__USER__|$(id -un)|g" \
  -e "s|__GROUP__|$(id -gn)|g" \
  -e "s|__N8N_DATA_DIR__|$N8N_DATA_DIR|g" \
  -e "s|__N8N_ENCRYPTION_KEY__|$N8N_ENCRYPTION_KEY|g" \
  -e "s|__LOG_DIR__|$LOG_DIR|g" \
  "$N8N_TEMPLATE" > "$TEMP_PLIST"
/usr/bin/plutil -lint "$TEMP_PLIST"
sudo /usr/bin/install -o root -g wheel -m 600 "$TEMP_PLIST" "$LAUNCH_DAEMON"

sudo /bin/launchctl bootout system/com.tomkenta.n8n >/dev/null 2>&1 || true
sudo /bin/launchctl bootstrap system "$LAUNCH_DAEMON"
sudo /bin/launchctl enable system/com.tomkenta.n8n
sudo /bin/launchctl kickstart -k system/com.tomkenta.n8n

echo "==> [8/8] Verification"
sleep 2
"$REPO_DIR/server/healthcheck.sh" || true

echo ""
echo "Server setup finished. Complete these interactive steps once:"
echo "  1. Open Tailscale and sign in; approve its macOS system extension."
echo "  2. Run: claude"
echo "  3. Run: codex"
echo "  4. From another Mac, open n8n through an SSH tunnel:"
echo "       ssh -L 5678:127.0.0.1:5678 $(id -un)@<tailscale-hostname>"
echo "     Then visit http://127.0.0.1:5678"
echo ""
echo "Important: FileVault can require a local login after a full power loss."
echo "n8n data: $N8N_DATA_DIR"
echo "n8n logs: $LOG_DIR"

open -a Tailscale >/dev/null 2>&1 || true
