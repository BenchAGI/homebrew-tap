# homebrew-tap

Canonical Homebrew tap for BenchAGI tools.

## Install

BenchAGI CLI and clickable Dock launcher:

```bash
brew tap benchagi/tap
brew install benchagi/tap/benchagi
benchagi-make-dock-app
```

The cask runs the same Dock-app builder after installing the formula:

```bash
brew install --cask benchagi/tap/benchagi
```

OpenClaw gateway:

```bash
brew tap benchagi/tap
brew install benchagi/tap/openclaw
```

Then:

```bash
openclaw models auth login         # authorize a default model provider
openclaw gateway start             # start the local gateway on :18789
curl http://localhost:18789/health # verify
```

## What this tap contains

| Formula | Command | Description |
|---------|---------|-------------|
| `benchagi` | `brew install benchagi/tap/benchagi` | BenchAGI CLI, premium TUI, agent picker, local Claude/Codex seats, and local Dock-app helper |
| `benchagi` cask | `brew install --cask benchagi/tap/benchagi` | Builds `~/Applications/BenchAGI.app` from the installed CLI helper |
| `openclaw` | `brew install benchagi/tap/openclaw` | Multi-channel AI gateway with extensible messaging integrations |

## Upgrading

```bash
brew update
brew upgrade benchagi/tap/openclaw
brew upgrade benchagi/tap/benchagi
benchagi-make-dock-app
```

After upgrading both packages, verify the local-seat memory bridge:

```bash
benchagi doctor
benchagi version
```

`benchagi doctor` must find OpenClaw gateway method `local-seat.capture`.
The launcher picker must expose Enter = tunnel, `d` = direct gateway, `l` =
local Claude Code, and `x` = local Codex CLI before a customer desktop release
is considered complete.

For local Codex CLI seats, first launch may ask you to review hooks. Run
`/hooks` in Codex and trust the BenchAGI seat bridge hook; until that hook is
trusted, local prompt captures are skipped. This release requires
`benchagi/tap/openclaw` 2026.6.1-6 or newer and BenchAGI CLI 1.0.0-beta.10 or
newer.

## Name collision note

Always use the fully qualified name (`benchagi/tap/openclaw`) to install or upgrade. An unrelated `openclaw` cask exists in homebrew-cask (an old game remake) that collides on the short name.

## Migrating from `benchagi/openclaw`

The previous tap (`BenchAGI/homebrew-openclaw`) is deprecated. Migrate:

```bash
brew untap benchagi/openclaw
brew tap benchagi/tap
brew install benchagi/tap/openclaw
```

## Source

Formula source of truth lives in the BenchAGI monorepo at [`tools/homebrew/openclaw.rb`](https://github.com/BenchAGI/BenchAGI_Mono_Repo/blob/main/tools/homebrew/openclaw.rb). This tap's `Formula/openclaw.rb` mirrors it on each release, with the SHA256 pinned to the release tarball.

The OpenClaw source is at [BenchAGI/openclaw](https://github.com/BenchAGI/openclaw).
