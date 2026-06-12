# frozen_string_literal: true

# The clickable BenchAGI Dock app (the "glyph"): boot cinematic -> agent selector
# -> tunnel/direct harness, local Claude Code (l), or local Codex CLI (x). Built
# locally from the CLI (the formula) so it opens cleanly without notarization.
# Requires the CLI, which this cask installs as a dependency.
cask "benchagi" do
  version "1.0.0-beta.10"
  # Same artifact the `benchagi` formula installs — pin the same checksum.
  sha256 "5fdd52ff70a532017133489994636a9c9fefade7558213f230a587292845ac28"

  url "https://github.com/BenchAGI/bench-cli/archive/refs/tags/v#{version}.tar.gz",
      verified: "github.com/BenchAGI/bench-cli/"
  name "BenchAGI"
  desc "Clickable BenchAGI launcher — boot + agent selector (harness, Claude, or Codex)"
  homepage "https://benchagi.com/"

  depends_on formula: "BenchAGI/tap/benchagi"

  # Build the self-contained BenchAGI.app locally (no Gatekeeper download prompt).
  # make-dock-app.sh is idempotent (rm -rf + rebuild) and headless-safe (no
  # prompts/stdin at install time; icon/codesign steps are best-effort), so a
  # failure here is a real build failure and should fail the cask.
  installer script: {
    executable:   "#{HOMEBREW_PREFIX}/bin/benchagi-make-dock-app",
    must_succeed: true,
  }

  uninstall delete: "#{Dir.home}/Applications/BenchAGI.app"

  zap trash: "#{Dir.home}/Applications/BenchAGI.app"
end
