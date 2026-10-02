#!/bin/bash
set -uo pipefail

failures=0

if [ -x /opt/homebrew/bin/brew ]; then
  export PATH="/opt/homebrew/opt/node@24/bin:/opt/homebrew/bin:$PATH"
elif [ -x /usr/local/bin/brew ]; then
  export PATH="/usr/local/opt/node@24/bin:/usr/local/bin:$PATH"
fi

ok() {
  printf 'OK   %s\n' "$1"
}

warn() {
  printf 'WARN %s\n' "$1"
  failures=$((failures + 1))
}

if /usr/bin/nc -z 127.0.0.1 22 >/dev/null 2>&1; then
  ok "SSH is listening on port 22"
else
  warn "SSH is not listening on port 22"
fi

if /bin/launchctl print system/com.apple.screensharing >/dev/null 2>&1; then
  ok "Screen Sharing service is loaded"
else
  warn "Screen Sharing service is not loaded"
fi

if /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null | grep -q 'enabled'; then
  ok "macOS firewall is enabled"
else
  warn "macOS firewall is disabled"
fi

if /usr/bin/nc -z 127.0.0.1 5678 >/dev/null 2>&1; then
  ok "n8n is listening on 127.0.0.1:5678"
else
  warn "n8n is not listening on 127.0.0.1:5678"
fi

if /bin/launchctl print system/com.tomkenta.n8n >/dev/null 2>&1; then
  ok "n8n LaunchDaemon is loaded"
else
  warn "n8n LaunchDaemon is not loaded"
fi

for command_name in brew uv node npm n8n claude codex; do
  if command -v "$command_name" >/dev/null 2>&1; then
    ok "$command_name is installed"
  else
    warn "$command_name is not on PATH"
  fi
done

if command -v node >/dev/null 2>&1 && [[ "$(node --version)" == v24.* ]]; then
  ok "Node.js 24 is active"
else
  warn "Node.js 24 is not active"
fi

PYTHON_ENV="$HOME/.local/share/kenta-os/python"
if [ -x "$PYTHON_ENV/bin/python" ] && "$PYTHON_ENV/bin/python" -c 'import langgraph' >/dev/null 2>&1; then
  ok "Python environment can import LangGraph"
else
  warn "LangGraph Python environment is unavailable"
fi

if [ -d /Applications/Tailscale.app ]; then
  ok "Tailscale is installed"
else
  warn "Tailscale.app is not installed"
fi

if [ "$failures" -eq 0 ]; then
  printf '\nAll automated checks passed.\n'
  exit 0
fi

printf '\n%d check(s) need attention.\n' "$failures"
exit 1
