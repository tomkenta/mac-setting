"""Fixed-prompt Claude smoke test. No user input or model-selected shell commands."""

import fcntl
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile


PROMPT = (
    "これはAIホームサーバーの動作テストです。外部情報や個人情報は必要ありません。"
    "『AIホームサーバーの動作テストに成功しました。』から始めて、"
    "自動化を安全に始めるための確認事項を日本語で3つ、200文字以内で書いてください。"
)
TIMEOUT_SECONDS = 180


class SmokeError(Exception):
    pass


def command(claude):
    # safe-mode retains subscription login (bare mode does not). No built-in or
    # MCP tools, project customizations, session history, or permission bypass.
    return [
        claude, "--safe-mode", "-p", PROMPT,
        "--tools", "", "--disallowedTools", "*",
        "--strict-mcp-config", "--mcp-config", '{"mcpServers":{}}',
        "--disable-slash-commands", "--no-session-persistence",
        "--permission-mode", "dontAsk", "--max-turns", "1",
        "--max-budget-usd", "0.50", "--output-format", "json",
    ]


def execute(args, workdir):
    process = subprocess.Popen(
        args, cwd=workdir, stdin=subprocess.DEVNULL,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        text=True, start_new_session=True,
    )
    try:
        stdout, stderr = process.communicate(timeout=TIMEOUT_SECONDS)
    except subprocess.TimeoutExpired:
        os.killpg(process.pid, signal.SIGKILL)
        stdout, stderr = process.communicate()
        return 124, stdout, stderr
    return process.returncode, stdout, stderr


def run(home, claude, executor=execute):
    root = home / "Library/Application Support/KentaOS/ai-smoke"
    root.mkdir(parents=True, exist_ok=True, mode=0o700)
    # Prevent overlapping calls (including double-clicks in n8n). No retry.
    with (root / ".lock").open("a") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as error:
            raise SmokeError("Another AI smoke test is running; do not retry yet.") from error

        run_dir = Path(tempfile.mkdtemp(prefix="run-", dir=root))
        workdir = run_dir / "work"
        workdir.mkdir(mode=0o700)
        code, stdout, stderr = executor(command(claude), workdir)
        (run_dir / "response.json").write_text(stdout, encoding="utf-8")
        (run_dir / "stderr.log").write_text(stderr, encoding="utf-8")
        if code != 0:
            raise SmokeError(f"Claude failed (exit {code}); inspect {run_dir}. No retry was made.")
        try:
            response = json.loads(stdout)
        except json.JSONDecodeError as error:
            raise SmokeError(f"Invalid Claude JSON; inspect {run_dir}.") from error
        if (
            not isinstance(response, dict)
            or response.get("type") != "result"
            or response.get("subtype") != "success"
            or response.get("is_error") is not False
            or not isinstance(response.get("result"), str)
            or not response["result"].strip()
        ):
            raise SmokeError(f"Claude returned no successful result; inspect {run_dir}.")
        report = run_dir / "report.md"
        report.write_text(response["result"].strip() + "\n", encoding="utf-8")
        return {"status": "ok", "report_path": str(report), "run_dir": str(run_dir)}


def main():
    os.umask(0o077)
    claude = shutil.which("claude")
    if not claude:
        print("Claude Code is missing from PATH.", file=sys.stderr)
        return 1
    try:
        result = run(Path.home(), claude)
    except (SmokeError, OSError) as error:
        print(str(error), file=sys.stderr)
        return 1
    print(json.dumps(result, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
