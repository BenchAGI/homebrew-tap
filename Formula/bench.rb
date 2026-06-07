# frozen_string_literal: true

# Homebrew formula for the BenchAGI CLI.
#
# Ships TWO binaries from one package:
#   * `bench`     — legacy v0.x wrapper around `openclaw`
#   * `benchagi`  — V2 streaming-aware native WebSocket client
#
# Customers install via: brew install BenchAGI/tap/bench
#
# Alternative install paths:
#   curl -fsSL https://raw.githubusercontent.com/BenchAGI/bench-cli/main/scripts/install.sh | sh
#   npm install -g @benchagi/cli
class Bench < Formula
  desc "BenchAGI CLI — streaming-aware terminal access to the OpenClaw agent system"
  homepage "https://github.com/BenchAGI/bench-cli"
  url "https://github.com/BenchAGI/bench-cli/archive/refs/tags/v1.0.0-beta.3.tar.gz"
  version "1.0.0-beta.3"
  sha256 "dbbe183b7e7cf2d1a8ba066ec74da988c426306497437872b16ee48c7618ac58"
  license "MIT"

  depends_on "node"

  def install
    system "#{Formula["node"].opt_bin}/npm", "install", "--no-save"
    system "#{Formula["node"].opt_bin}/npm", "run", "build"

    libexec.install Dir["*"]

    (bin/"bench").write <<~SH
      #!/bin/sh
      exec "#{Formula["node"].opt_bin}/node" "#{libexec}/bin/bench.mjs" "$@"
    SH
    chmod 0755, bin/"bench"

    (bin/"benchagi").write <<~SH
      #!/bin/sh
      exec "#{Formula["node"].opt_bin}/node" "#{libexec}/bin/benchagi.mjs" "$@"
    SH
    chmod 0755, bin/"benchagi"
  end

  test do
    assert_match "bench v", shell_output("#{bin}/bench version")
    assert_match "benchagi 1.0.0-beta.3", shell_output("#{bin}/benchagi version")
  end
end
