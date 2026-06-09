# typed: false
# frozen_string_literal: true

# Homebrew formula sketch for the BenchAGI-flavored OpenClaw harness.
#
# Status: PUBLISHED 2026-06-04. Release v2026.6.1-2 cut on BenchAGI/openclaw
# (bench-sync B1-B4 customer harness); this formula pushed to
# BenchAGI/homebrew-tap as benchagi-openclaw.rb.
#   Customer install: `brew install benchagi/tap/benchagi-openclaw`
# This copy in kestrel-aurelius/customer-rollout/ is the source of truth; the tap
# copy is generated from it. Re-publish: cut a new release tag, recompute sha256,
# bump url/version here, re-push to the tap.
#
# OR replace with a web-app-driven installer that downloads + extracts the same
# release tarball into ~/.openclaw/install/ and registers the launchd plist —
# friendlier for non-Homebrew customers. Wave 5 work; not in this sketch.

class BenchagiOpenclaw < Formula
  desc "BenchAGI-flavored OpenClaw agent harness (Slack + CLI + cloud-brain bridge)"
  homepage "https://github.com/BenchAGI/openclaw"
  # Released 2026-06-04: upstream OpenClaw v2026.6.1 plus BenchAGI bridge and
  # bench-sync extension B1-B4 (commit 4c68d9b).
  url "https://github.com/BenchAGI/openclaw/archive/refs/tags/v2026.6.1-4.tar.gz"
  version "2026.6.1-4"
  sha256 "30744a3532c33eb63b1521354028f5dd933574c9788234c957548b0f531b234e"
  license "MIT"

  depends_on "node@24" # OpenClaw is a Node CLI; matches the version Cory's MBP runs
  depends_on "pnpm"

  # Optional: the customer should also have `claude` (Claude Code CLI) installed
  # and logged in. Not declared as a brew dep because Anthropic distributes
  # claude via npm + a separate installer.

  def install
    # Build OpenClaw locally during install.
    system "pnpm", "install", "--frozen-lockfile"
    system "pnpm", "run", "build"

    # Install the runtime into Homebrew's libexec, and a wrapper into bin.
    libexec.install Dir["*"]
    (bin/"openclaw").write <<~SHELL
      #!/bin/bash
      exec #{Formula["node@24"].opt_bin}/node "#{libexec}/openclaw.mjs" "$@"
    SHELL
    chmod 0755, bin/"openclaw"

    # Convenience wrapper: `aurelius` → openclaw agent --agent aurelius
    # (only installed if the customer wants the same toolbar-style seat Cory uses).
    (bin/"aurelius").write <<~SHELL
      #!/bin/bash
      # BenchAGI Aurelius CLI seat via OpenClaw.
      exec #{bin}/openclaw agent --agent aurelius "$@"
    SHELL
    chmod 0755, bin/"aurelius"
  end

  def caveats
    <<~EOS
      To finish setup on this machine (one-time per customer machine):

        # 1. Initialize OpenClaw + register an Aurelius agent
        openclaw configure

        # 2. Seed Claude OAuth into the OpenClaw anthropic provider
        OPENCLAW_AGENT_DIR=~/.openclaw/agents/aurelius/agent \\
          openclaw models auth setup-token --provider anthropic
        # (Paste a long-lived token from `claude setup-token` when prompted.)

        # 3. Wire the OpenClaw MCP into Claude Code (engineering seat)
        claude mcp add openclaw --scope user -- \\
          node #{HOMEBREW_PREFIX}/opt/benchagi-openclaw/libexec/extensions/claude-code-bridge/serve.mjs

        # 4. (Optional) Install the launchd gateway so OpenClaw runs in the background
        openclaw gateway install

      See the customer install recipe at:
        https://github.com/BenchAGI/openclaw/blob/main/docs/customer-rollout/install-recipe.md
    EOS
  end

  test do
    # Smoke: CLI loads + reports version.
    output = shell_output("#{bin}/openclaw --version")
    assert_match(/OpenClaw 2026\./, output)
  end
end
