# frozen_string_literal: true

# The clickable BenchAGI Dock app (the "glyph"): boot cinematic -> agent selector
# -> cloud seat (Enter) or local Claude Code seat (l). Built locally from the CLI
# (the formula) so it opens cleanly without notarization. Requires the CLI, which
# this cask installs as a dependency.
cask "benchagi" do
  version "1.0.0-beta.6"
  sha256 :no_check

  url "https://github.com/BenchAGI/bench-cli/archive/refs/tags/v#{version}.tar.gz"
  name "BenchAGI"
  desc "Clickable BenchAGI launcher — boot + agent selector (cloud or local seat)"
  homepage "https://benchagi.com"

  depends_on formula: "BenchAGI/tap/benchagi"

  # Build the self-contained BenchAGI.app locally (no Gatekeeper download prompt).
  installer script: {
    executable: "#{HOMEBREW_PREFIX}/bin/benchagi-make-dock-app",
    must_succeed: false,
  }

  uninstall delete: "#{Dir.home}/Applications/BenchAGI.app"
  zap trash: "#{Dir.home}/Applications/BenchAGI.app"
end
