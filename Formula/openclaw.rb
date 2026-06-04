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
# so customer installs pick up upstream OpenClaw v2026.6.1 plus the BenchAGI
# cloud-brain bridge.
class Openclaw < Formula
  desc "Multi-channel AI gateway with extensible messaging integrations"
  homepage "https://github.com/BenchAGI/openclaw"
  url "https://github.com/BenchAGI/openclaw/archive/refs/tags/v2026.6.1-2.tar.gz"
  sha256 "760febe0a71f7bdfc2aca2e2e2c5437018a3a4da92e92b673576c160ca23beee"
  license "MIT"
  version "2026.6.1-2"

  depends_on "node"
  depends_on "pnpm" => :build

  def install
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
  end
end
