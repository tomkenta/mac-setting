require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"

class WorkspaceTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)

  def test_common_tools_are_shared_without_duplicate_node_or_casks
    common = File.read(File.join(ROOT, "Brewfile.common"))
    assert_includes common, 'brew "node@24"'
    assert_includes common, 'brew "ghq"'
    %w[Brewfile Brewfile.server].each do |name|
      text = File.read(File.join(ROOT, name))
      assert_includes text, '"Brewfile.common"'
      refute_match(/^brew "node(?:@24)?"$/, text)
      refute_match(/^cask "google-chrome"$/, text)
    end
  end

  def test_sync_refuses_dirty_and_detached_repositories_without_pulling
    Dir.mktmpdir do |dir|
      root = File.join(dir, "repos")
      bin = File.join(dir, "bin")
      FileUtils.mkdir_p(bin)
      %w[mac-setting dotfiles external_brain x-posting].each do |n|
        FileUtils.mkdir_p(File.join(root, n, ".git"))
      end
      File.write(File.join(bin, "git"), <<~'SH')
        #!/bin/bash
        name="${2##*/}"
        case "$3" in
          remote) echo "https://github.com/tomkenta/$name.git" ;;
          status) [ "$name" != external_brain ] || echo '?? daily.md' ;;
          symbolic-ref) [ "$name" != x-posting ] ;;
          rev-parse) exit 0 ;;
          pull) echo "PULLED $name" ;;
          *) exit 99 ;;
        esac
      SH
      FileUtils.chmod(0755, File.join(bin, "git"))
      out, status = Open3.capture2e({"WORKSPACE_ROOT" => root, "PATH" => "#{bin}:#{ENV['PATH']}"},
                                   "bash", File.join(ROOT, "scripts/sync-repos.sh"))
      refute status.success?
      assert_includes out, "PULLED mac-setting"
      assert_includes out, "PULLED dotfiles"
      refute_includes out, "PULLED external_brain"
      refute_includes out, "PULLED x-posting"
      assert_includes out, "uncommitted changes"
      assert_includes out, "detached HEAD"
    end
  end
end
