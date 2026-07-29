# frozen_string_literal: true

# Homebrew formula for OpenClaw — Bench's multi-channel AI gateway.
#
# Install (end-user):
#   brew tap benchagi/tap
#   brew install benchagi/tap/openclaw
#
# Note the tap-prefixed install command: an unrelated `openclaw` cask exists
# in homebrew-cask (an old WarCraft-style game remake) that collides on the
# short name, so bare `brew install openclaw` resolves to the cask. Always
# use the fully qualified name to disambiguate.
#
# Source: BenchAGI/openclaw customer harness refresh. We build from source here
# so customer installs pick up the BenchAGI cloud-brain bridge and local-seat
# capture gateway.
class Openclaw < Formula
  desc "Multi-channel AI gateway with extensible messaging integrations"
  homepage "https://github.com/BenchAGI/openclaw"
  url "https://github.com/BenchAGI/openclaw/archive/refs/tags/v2026.6.11-bench.1.tar.gz"
  version "2026.6.11-bench.1"
  sha256 "3dbf6ede5cc8a1b74a2faea17ffc39115f31188508b052c31f525e8c71380608"
  SOURCE_COMMIT = "684aabb3254cb75933041741c41a8adc991ddec5"
  license "MIT"

  depends_on "pnpm" => :build
  depends_on "node"

  conflicts_with "benchagi-openclaw", because: "both install a bin/openclaw executable"

  def install
    # GitHub source archives do not contain .git, while the Bench fork keeps
    # package.json on the upstream base version. Inject the signed-off release
    # tag so dist/build-info.json preserves the formula artifact's true lineage.
    ENV["GIT_RELEASE"] = "v#{version}"
    ENV["GIT_COMMIT"] = SOURCE_COMMIT
    system "pnpm", "install", "--frozen-lockfile"
    system "pnpm", "build:docker"
    system "npm", "pack", "--ignore-scripts"
    system "npm", "install", *std_npm_args, Dir["openclaw-*.tgz"].first
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  def caveats
    <<~EOS
      Next steps:
        1. Authorize OpenClaw with your default model provider:
             openclaw models auth login
        2. Start the gateway (defaults to localhost:18789):
             openclaw gateway start
        3. Verify with:
             curl http://localhost:18789/health

      Config lives in ~/.openclaw/openclaw.json — Bench's deploy runbooks
      document the shape of that file per role (Aurelius, Cole, Sage, etc).

      Name collision note: always use the fully qualified name to install or
      upgrade (an unrelated openclaw cask exists in homebrew-cask):
        brew install benchagi/tap/openclaw
        brew upgrade benchagi/tap/openclaw
    EOS
  end

  test do
    assert_match "OpenClaw", shell_output("#{bin}/openclaw --version")
    build_info = JSON.parse((libexec/"lib/node_modules/openclaw/dist/build-info.json").read)
    assert_equal "v#{version}", build_info.fetch("release")
    assert_equal SOURCE_COMMIT, build_info.fetch("commit")
  end
end
