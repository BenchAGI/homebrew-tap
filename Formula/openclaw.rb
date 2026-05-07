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
# Source: BenchAGI/openclaw at the cloud-brain CLI executor fix. We build
# from source here so customer installs pick up the gateway `/v1/llm_turn`
# executor before the next public npm tarball is published.
class Openclaw < Formula
  desc "Multi-channel AI gateway with extensible messaging integrations"
  homepage "https://github.com/BenchAGI/openclaw"
  url "https://github.com/BenchAGI/openclaw/archive/012e846071a2da38fd7200ae541118644cbf859e.tar.gz"
  sha256 "3b4ab44cab52ae0a06663a3cda4e02356175ed09e88f3886430868931e3cb72b"
  license "MIT"
  version "2026.5.7"

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
