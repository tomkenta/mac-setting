# Run with: HOMEBREW_DEVELOPER=0 brew ruby server/tests/homebrew_npm_path_test.rb
# Exercises Homebrew's real npm subprocess launcher, without installing packages.
require "bundle"
require "bundle/package_types"
require "tmpdir"
require "fileutils"

repo_dir = File.expand_path("../..", __dir__)

Dir.mktmpdir("mac-setting-homebrew-path-") do |test_prefix|
  node_bin = File.join(test_prefix, "opt/node@24/bin")
  node = File.join(node_bin, "node")
  npm = File.join(node_bin, "npm")

  # Isolate the fallback /opt/node path from this Mac's existing Node installation.
  Object.send(:remove_const, :HOMEBREW_PREFIX)
  Object.const_set(:HOMEBREW_PREFIX, Pathname.new(test_prefix))
  ENV["HOMEBREW_PREFIX"] = test_prefix
  ENV["PATH"] = "/usr/bin:/bin:/usr/sbin:/sbin"
  ENV.delete("NPM_CONFIG_PREFIX")
  Homebrew::Bundle::Npm.define_singleton_method(:package_manager_executable) { Pathname.new(npm) }

  # Evaluate the actual Brewfile inside Homebrew's already-filtered environment.
  recorder = Object.new
  [:brew, :cask, :npm].each { |type| recorder.define_singleton_method(type) { |_name| } }
  brewfile = File.join(repo_dir, "Brewfile.server")
  recorder.instance_eval(File.read(brewfile), brewfile)

  # Like first setup, the versioned runtime appears only after the Brewfile loads.
  FileUtils.mkdir_p(node_bin)
  File.write(node, "#!/bin/sh\nprintf 'Node 24 fixture executed\\n'\n")
  File.write(npm, "#!/usr/bin/env node\n")
  File.chmod(0755, node, npm)

  unless Homebrew::Bundle.system(npm, "--version")
    abort "FAIL: npm's /usr/bin/env node launcher cannot find Node 24 inside Homebrew"
  end
  unless ENV["NPM_CONFIG_PREFIX"] == test_prefix
    abort "FAIL: npm's global prefix was lost inside Homebrew"
  end
  puts "PASS: real Homebrew subprocess finds versioned Node and preserves npm prefix"
end
