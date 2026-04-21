# homebrew-tap

Canonical Homebrew tap for BenchAGI tools.

## Install

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
| `openclaw` | `brew install benchagi/tap/openclaw` | Multi-channel AI gateway with extensible messaging integrations |

Future BenchAGI formulae will ship from this same tap — no new tap repo per tool.

## Upgrading

```bash
brew update
brew upgrade benchagi/tap/openclaw
```

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
