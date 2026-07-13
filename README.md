# homebrew-tap

Canonical Homebrew tap for BenchAGI tools.

## Install

> **Recent Homebrew builds refuse formulae from untrusted third-party taps**
> ("Refusing to load formula from untrusted tap"). If you hit that, trust the
> tap once before installing (the command doesn't exist on older brews — skip
> it there):
>
> ```bash
> brew trust benchagi/tap
> ```

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

## Which OpenClaw formula?

This tap (`benchagi/tap`) is the **canonical** home for all BenchAGI formulae. It ships two
OpenClaw builds that both install a `bin/openclaw` executable, so they are marked
`conflicts_with` each other — install exactly one:

| Formula | What it is |
|---------|------------|
| `openclaw` | Current Bench OpenClaw gateway — includes the cloud-brain bridge and `local-seat.capture`, follows the current Bench release tags, and does not add an `aurelius` wrapper |
| `benchagi-openclaw` | Legacy customer-harness formula pinned to `v2026.6.1-6` — includes the older bridge build, Node 24 packaging, and the `aurelius` convenience wrapper |

New and current BenchAGI rollouts should use `openclaw`. Keep `benchagi-openclaw` only
where an existing install recipe explicitly depends on its legacy Node 24 packaging or
the `aurelius` wrapper.

The old `bench` formula has been renamed to `benchagi` (`formula_renames.json`); existing
`bench` installs migrate automatically on `brew update && brew upgrade`.

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

The formula actually consumed by Homebrew is [`Formula/openclaw.rb`](Formula/openclaw.rb) in this tap. Each release pins the BenchAGI fork tag and tarball SHA256 here. Release automation may stage a candidate elsewhere, but a customer formula is not canonical until this tap contains the reviewed tag, explicit formula version, checksum, and build-identity assertion.

The Bench fork deliberately keeps `package.json` on its upstream base version. Because GitHub source archives do not include `.git`, each formula bump must pin `source_commit`, inject both `GIT_RELEASE=v<formula-version>` and `GIT_COMMIT=<source-commit>` during the build, and test the resulting `dist/build-info.json`. Runtime receipts must treat formula release, source commit, and package-reported version as separate facts. If build logic changes without a new source version, increment the formula `revision` so existing installs are offered the rebuilt artifact; remove the revision on the next version bump.

The OpenClaw source is at [BenchAGI/openclaw](https://github.com/BenchAGI/openclaw).
