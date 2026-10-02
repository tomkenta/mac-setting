import fcntl
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import Mock, patch


SERVER = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("ai_smoke", SERVER / "ai_smoke.py")
smoke = importlib.util.module_from_spec(spec)
spec.loader.exec_module(smoke)


class SmokeTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="ai-smoke-test-")
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        old_umask = os.umask(0o077)
        self.addCleanup(os.umask, old_umask)

    def response(self, **overrides):
        return json.dumps({
            "type": "result", "subtype": "success", "is_error": False,
            "result": "AIホームサーバーの動作テストに成功しました。",
            **overrides,
        }, ensure_ascii=False)

    def run_with(self, code=0, stdout=None, stderr=""):
        return smoke.run(
            self.home, "/fake/claude",
            executor=lambda args, work: (code, self.response() if stdout is None else stdout, stderr),
        )

    def test_success_saves_private_report_outside_repository(self):
        result = self.run_with()
        self.assertEqual("ok", result["status"])
        report = Path(result["report_path"])
        self.assertIn("AIホームサーバー", report.read_text())
        self.assertEqual(0o600, report.stat().st_mode & 0o777)
        self.assertEqual(0o700, report.parent.stat().st_mode & 0o777)
        self.assertTrue(report.is_relative_to(self.home / "Library/Application Support/KentaOS/ai-smoke"))

    def test_repeated_runs_do_not_overwrite(self):
        first = self.run_with()
        second = self.run_with()
        self.assertNotEqual(first["report_path"], second["report_path"])
        self.assertTrue(Path(first["report_path"]).is_file())

    def test_exit_failure_preserves_logs_but_no_report(self):
        with self.assertRaisesRegex(smoke.SmokeError, "exit 1"):
            self.run_with(code=1, stdout="Authentication failed", stderr="error")
        root = self.home / "Library/Application Support/KentaOS/ai-smoke"
        self.assertEqual([], list(root.rglob("report.md")))
        self.assertEqual("Authentication failed", next(root.rglob("response.json")).read_text())
        self.assertEqual("error", next(root.rglob("stderr.log")).read_text())

    def test_malformed_or_error_results_fail_closed(self):
        bad_results = [
            "not JSON", "[]", "null", "{}",
            self.response(is_error=True), self.response(is_error="false"),
            self.response(subtype="error_max_turns"),
            self.response(result=""), self.response(result=None),
        ]
        for data in bad_results:
            with self.subTest(data=data), self.assertRaises(smoke.SmokeError):
                self.run_with(stdout=data)
        self.assertEqual([], list(self.home.rglob("report.md")))

    def test_parallel_call_is_rejected_before_ai_execution(self):
        root = self.home / "Library/Application Support/KentaOS/ai-smoke"
        root.mkdir(parents=True)
        executor = Mock()
        with (root / ".lock").open("a") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            with self.assertRaisesRegex(smoke.SmokeError, "Another"):
                smoke.run(self.home, "/fake/claude", executor)
        executor.assert_not_called()

    def test_command_preserves_login_but_disables_tools_and_customizations(self):
        args = smoke.command("/fake/claude")
        self.assertIn("--safe-mode", args)
        self.assertNotIn("--bare", args)
        self.assertEqual("", args[args.index("--tools") + 1])
        self.assertEqual("*", args[args.index("--disallowedTools") + 1])
        self.assertIn("--strict-mcp-config", args)
        self.assertEqual({"mcpServers": {}}, json.loads(args[args.index("--mcp-config") + 1]))
        self.assertEqual("dontAsk", args[args.index("--permission-mode") + 1])
        self.assertNotIn("--dangerously-skip-permissions", args)
        self.assertEqual("1", args[args.index("--max-turns") + 1])
        self.assertEqual("0.50", args[args.index("--max-budget-usd") + 1])

    def test_timeout_kills_process_group_without_retry(self):
        process = Mock(pid=987654)
        process.communicate.side_effect = [
            subprocess.TimeoutExpired("claude", 180), ("partial", "timeout")
        ]
        with patch.object(smoke.subprocess, "Popen", return_value=process) as start, \
                patch.object(smoke.os, "killpg") as kill:
            result = smoke.execute(["/fake/claude"], self.home)
        self.assertEqual((124, "partial", "timeout"), result)
        start.assert_called_once()
        kill.assert_called_once_with(process.pid, smoke.signal.SIGKILL)
        self.assertTrue(start.call_args.kwargs["start_new_session"])
        self.assertEqual(subprocess.DEVNULL, start.call_args.kwargs["stdin"])

    def test_manual_workflow_has_no_credentials_schedule_or_retry(self):
        workflow = json.loads((SERVER / "n8n/ai-smoke.manual.json").read_text())
        self.assertFalse(workflow["active"])
        self.assertEqual(3, len(workflow["nodes"]))
        nodes = {node["type"]: node for node in workflow["nodes"]}
        self.assertIn("n8n-nodes-base.manualTrigger", nodes)
        ssh = nodes["n8n-nodes-base.ssh"]
        self.assertNotIn("credentials", ssh)
        self.assertFalse(ssh["retryOnFail"])
        self.assertEqual('/bin/bash "$HOME/mac-setting/server/run-ai-smoke.sh"', ssh["parameters"]["command"])
        self.assertNotIn("{{", ssh["parameters"]["command"])
        self.assertGreater(workflow["settings"]["executionTimeout"], smoke.TIMEOUT_SECONDS)

    def test_n8n_verifier_rejects_failures_and_accepts_saved_report(self):
        node = json.loads((SERVER / "n8n/ai-smoke.manual.json").read_text())["nodes"][-1]
        source = node["parameters"]["jsCode"]
        harness = (
            "const fn = new Function('$input', " + json.dumps(source) + ");\n"
            "const invoke = reply => fn({ first: () => ({ json: reply }) });\n"
            "const good = invoke({code:0,stdout:JSON.stringify({status:'ok',report_path:'/saved/report.md'})});\n"
            "if (good[0].json.status !== 'ok') throw Error('invalid success');\n"
            "for (const reply of [{code:1,stdout:'{}'}, {code:null,stdout:'{}'},\n"
            "{code:0,stdout:'not json'}, {code:0,stdout:'{}'}]) {\n"
            "  let failed = false; try { invoke(reply); } catch { failed = true; }\n"
            "  if (!failed) throw Error('failure was treated as success');\n"
            "}\n"
        )
        node_path = shutil.which("node")
        if not node_path and Path("/opt/homebrew/opt/node@24/bin/node").is_file():
            node_path = "/opt/homebrew/opt/node@24/bin/node"
        if not node_path:
            self.skipTest("Node.js is not installed; run on the server to validate the Code node")
        completed = subprocess.run([node_path, "-e", harness], capture_output=True, text=True)
        self.assertEqual(0, completed.returncode, completed.stderr)


if __name__ == "__main__":
    unittest.main()
