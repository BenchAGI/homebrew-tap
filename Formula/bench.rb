# frozen_string_literal: true

# Homebrew formula for the BenchAGI CLI (legacy alias).
#
# Ships TWO binaries from one package:
#   * `benchagi`  — V2 streaming-aware native WebSocket client (canonical)
#   * `bench`     — legacy v0.x wrapper around `openclaw` (deprecated alias)
#
# Customers install via: brew install BenchAGI/tap/bench
#
# Alternative install paths:
#   curl -fsSL https://raw.githubusercontent.com/BenchAGI/bench-cli/main/scripts/install.sh | sh
#   npm install -g @benchagi/cli
class Bench < Formula
  desc "BenchAGI CLI — streaming-aware terminal access to the OpenClaw agent system"
  homepage "https://github.com/BenchAGI/bench-cli"
  url "https://github.com/BenchAGI/bench-cli/archive/refs/tags/v1.0.0-beta.10.tar.gz"
  sha256 "5fdd52ff70a532017133489994636a9c9fefade7558213f230a587292845ac28"
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

    # Keep the alias formula behavior aligned with Formula/benchagi.rb.
    (bin/"benchagi-make-dock-app").write <<~SH
      #!/bin/sh
      exec /bin/bash "#{libexec}/scripts/make-dock-app.sh" "$@"
    SH
    chmod 0755, bin/"benchagi-make-dock-app"
  end

  def caveats
    <<~EOS
      The canonical formula is:
        brew install BenchAGI/tap/benchagi

      For the clickable BenchAGI Dock app (the glyph), run:
        benchagi-make-dock-app
      or install it directly:  brew install --cask BenchAGI/tap/benchagi
    EOS
  end

  test do
    assert_match "1.0.0-beta.10", shell_output("#{bin}/bench version")
    assert_match "benchagi 1.0.0-beta.10", shell_output("#{bin}/benchagi version")
  end
end
