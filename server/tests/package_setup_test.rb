#!/usr/bin/env ruby
# Read-only contract tests; no Homebrew installs or macOS settings are executed.
require "minitest/autorun"
require "open3"
require "tmpdir"
require "fileutils"
require "rexml/document"

class ServerPackageSetupTest < Minitest::Test
  REPO_DIR = File.expand_path("../..", __dir__)
  SETUP = File.read(File.join(REPO_DIR, "setup-server.sh"))
  PACKAGE_SETUP = SETUP.split('echo "==> [4/8]', 2).last
                      .split('echo "==> [6/8]', 2).first
  PACKAGE_SETUP_WITH_BANNER = 'echo "==> [4/8]' + PACKAGE_SETUP

  class BrewfileRecorder
    attr_reader :entries

    def initialize
      @entries = []
    end

    [:brew, :cask, :npm].each do |type|
      define_method(type) { |name| @entries << [type, name] }
    end
  end

  def test_all_server_software_is_declared_in_one_brewfile
    recorder = BrewfileRecorder.new
    original_environment = ENV.to_h
    begin
      ENV["HOMEBREW_PREFIX"] = "/test-homebrew"
      recorder.instance_eval(File.read(File.join(REPO_DIR, "Brewfile.server")))
      assert ENV["PATH"].start_with?("/test-homebrew/opt/node@24/bin:")
      assert_equal "/test-homebrew", ENV["NPM_CONFIG_PREFIX"]
    ensure
      ENV.replace(original_environment)
    end
    assert_equal [[:brew, "node@24"], [:brew, "uv"],
                  [:cask, "tailscale-app"], [:cask, "claude-code"],
                  [:cask, "codex"], [:npm, "n8n"]], recorder.entries
    refute_match(/\bnpm install\b|\bbrew install\b|\bbrew link\b/, PACKAGE_SETUP)
    refute_includes SETUP, 'node@22'
  end

  def test_bundle_has_node_path_and_global_prefix_before_installing
    output, status = run_package_setup
    assert status.success?, output
    assert_match(/BUNDLE bundle --file=.*Brewfile\.server/, output)
    assert_includes output, "BUNDLE_ENV node_path=true global_prefix=true"
    assert_includes output, "REBUILD scoped=true rebuild --global=false --ignore-scripts=false"
    assert_includes output, "N8N --version"
    assert_operator output.index("BUNDLE bundle"), :<, output.index("REBUILD scoped")
    assert_operator output.index("REBUILD scoped"), :<, output.index("N8N --version")
  end

  def test_wrong_node_version_stops_before_runtime_preparation
    output, status = run_package_setup(node_version: "v22.18.0")
    refute status.success?
    assert_includes output, "Expected Node.js 24, but found v22.18.0."
    refute_includes output, "REBUILD"
    refute_includes output, "N8N --version"
  end

  def test_missing_n8n_stops_without_rebuilding_other_packages
    output, status = run_package_setup(n8n_installed: false)
    refute status.success?
    assert_includes output, "n8n was not installed at"
    refute_includes output, "REBUILD"
  end

  def test_failed_rebuild_stops_before_launching_n8n
    output, status = run_package_setup(rebuild_status: 1)
    refute status.success?
    assert_includes output, "REBUILD scoped=true"
    refute_includes output, "N8N --version"
  end

  def test_launchd_and_healthcheck_use_same_node_version
    template = File.read(File.join(REPO_DIR, "server/launchd/com.tomkenta.n8n.plist.template"))
    document = REXML::Document.new(template)
    path = REXML::XPath.first(document, "//key[.='PATH']/following-sibling::string[1]").text
    assert path.start_with?("__BREW_PREFIX__/opt/node@24/bin:")
    assert_includes template, "__BREW_PREFIX__/bin/n8n"
    healthcheck = File.read(File.join(REPO_DIR, "server/healthcheck.sh"))
    assert_includes healthcheck, "/opt/homebrew/opt/node@24/bin:"
    assert_includes healthcheck, "/usr/local/opt/node@24/bin:"
  end

  private

  def run_package_setup(node_version: "v24.0.0", n8n_installed: true, rebuild_status: 0)
    Dir.mktmpdir("mac-setting-package-test-") do |test_dir|
      n8n_dir = File.join(test_dir, "lib/node_modules/n8n")
      FileUtils.mkdir_p(n8n_dir) if n8n_installed
      environment = {
        "BREW_PREFIX" => test_dir,
        "SERVER_BREWFILE" => File.join(REPO_DIR, "Brewfile.server"),
        "TEST_NODE_VERSION" => node_version,
        "TEST_REBUILD_STATUS" => rebuild_status.to_s
      }
      mocks = <<~'BASH'
        set -euo pipefail
        brew() {
          printf 'BUNDLE %s\n' "$*"
          [[ "$PATH" == "$BREW_PREFIX/opt/node@24/bin:"* ]]
          [[ "$NPM_CONFIG_PREFIX" == "$BREW_PREFIX" ]]
          printf 'BUNDLE_ENV node_path=true global_prefix=true\n'
        }
        node() { printf '%s\n' "$TEST_NODE_VERSION"; }
        npm() {
          if [[ "$*" == 'root --global' ]]; then
            printf '%s/lib/node_modules\n' "$BREW_PREFIX"
          else
            [[ "$PWD" == "$BREW_PREFIX/lib/node_modules/n8n" ]]
            printf 'REBUILD scoped=true %s\n' "$*"
            return "$TEST_REBUILD_STATUS"
          fi
        }
        n8n() { printf 'N8N %s\n' "$*"; }
        claude() { :; }
        codex() { :; }
      BASH
      Open3.capture2e(environment, "/bin/bash", "-c", mocks + PACKAGE_SETUP_WITH_BANNER)
    end
  end
end
