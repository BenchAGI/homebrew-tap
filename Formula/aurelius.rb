# frozen_string_literal: true

# Homebrew formula for the Aurelius agent-vault bridge (@benchagi/aurelius-bridge).
#
# Ships the `aurelius` CLI: device pairing + the gateway-loop turn runner (routes
# a bridge turn through the local OpenClaw gateway's keyed agent loop) + the
# `aurelius gateway set-key|status|ping` helpers used in local-model onboarding.
#
# Customers install via: brew install BenchAGI/tap/aurelius
#
# The bridge is pure Node (no runtime dependencies, all ESM .mjs), so the install
# is just: drop the files into libexec + write a node bin shim. Requires node >= 20.
#
# RELEASE NOTE: the source repo (BenchAGI/aurelius-bridge) must be PUBLIC and the
# v0.1.0 tag pushed for this url to fetch (mirrors how openclaw/bench-cli ship).
# Refresh the sha256 from the published tag tarball before pushing the tap.
class Aurelius < Formula
  desc "Aurelius agent-vault bridge — keyed gateway-loop turn runner + onboarding CLI"
  homepage "https://github.com/BenchAGI/aurelius-bridge"
  url "https://github.com/BenchAGI/aurelius-bridge/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "459fdd97dc49f4ef9e53903b950478333612130d78b037ea1808ba734bc3354f"
  license "MIT"

  depends_on "node"

  def install
    # No build, no npm install — zero runtime deps. Ship bin + runtime as-is.
    libexec.install "bin", "runtime", "package.json"

    (bin/"aurelius").write <<~SH
      #!/bin/sh
      exec "#{Formula["node"].opt_bin}/node" "#{libexec}/bin/aurelius.mjs" "$@"
    SH
    chmod 0755, bin/"aurelius"
  end

  def caveats
    <<~EOS
      Local-model onboarding:
        openclaw models auth paste-api-key --provider anthropic   # place the customer key
        echo 'AURELIUS_BRIDGE_RUNNER=gateway' >> ~/.aurelius/bridge.env   # keyed gateway-loop
        aurelius gateway ping                                      # verify a keyed turn
      Pair the in-app /aurelius surface:
        aurelius link        # zero-touch, uses the Bench sign-in
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/aurelius --help")
  end
end
