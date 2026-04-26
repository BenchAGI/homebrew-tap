# Homebrew formula for bench-reflective-dreaming — the dream / canon /
# consolidation cron jobs that turn agent session memory into durable wiki
# entries.
#
# Install (end-user):
#   brew tap benchagi/tap
#   brew install benchagi/tap/bench-reflective-dreaming
#   brew services start bench-reflective-dreaming
#
# PREREQUISITES (read carefully before publishing):
#   1. The source repo BenchAGI/bench-reflective-dreaming does not yet
#      exist. As of 2026-04-26 the dream/canon/consolidation runners live
#      inline in the bench-harness repo and the BenchAGI_Mono_Repo. Before
#      this formula can be installed, the cron-job runners must be
#      extracted into a dedicated repo (or a top-level `reflective-dreaming/`
#      directory inside bench-harness) and a v0.1.0 release cut.
#   2. bench-harness must be installed first — this formula declares it
#      as a runtime dependency.
#   3. The host needs `claude` CLI on PATH with the
#      `claude-sonnet-4-6` model available (configured under
#      ~/.openclaw/agents/<agent>/agent/auth*.json). The cron runners
#      shell out to `claude` for the dream synthesis pass.
class BenchReflectiveDreaming < Formula
  desc "Dream, canon, and consolidation cron runners for BenchAGI agents"
  homepage "https://github.com/BenchAGI/bench-reflective-dreaming"
  url "https://github.com/BenchAGI/bench-reflective-dreaming/archive/refs/tags/v0.1.0.tar.gz"
  # sha256 will be filled in once v0.1.0 is tagged. Compute with:
  #   curl -L https://github.com/BenchAGI/bench-reflective-dreaming/archive/refs/tags/v0.1.0.tar.gz | shasum -a 256
  version "0.1.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"

  depends_on "bash"
  depends_on "benchagi/tap/bench-harness"
  depends_on "jq"

  def install
    libexec.install "scripts" if Dir.exist?("scripts")
    libexec.install "launchd" if Dir.exist?("launchd")

    # Expected layout in the source repo:
    #   scripts/run-dream.sh
    #   scripts/run-canon-consolidation.sh
    #   scripts/run-session-distill.sh
    #   launchd/com.benchagi.reflective-dreaming.plist
    {
      "run-dream.sh"               => "bench-dream",
      "run-canon-consolidation.sh" => "bench-canon-consolidate",
      "run-session-distill.sh"     => "bench-session-distill",
    }.each do |src, dst|
      target = libexec/"scripts"/src
      bin.install_symlink target => dst if target.exist?
    end
  end

  service do
    run [opt_bin/"bench-dream"]
    keep_alive false
    run_at_load true
    # Dream pass runs hourly; canon consolidation is invoked from inside the
    # dream runner once per day (it gates on a UTC-hour check).
    interval 3600
    log_path "#{Dir.home}/.openclaw/logs/reflective-dreaming.out.log"
    error_log_path "#{Dir.home}/.openclaw/logs/reflective-dreaming.err.log"
  end

  def caveats
    <<~EOS
      bench-reflective-dreaming is installed and depends on bench-harness.

      Required one-time setup:
        1. Confirm Claude CLI is available and authorized:
             claude --version
             claude models | grep -i sonnet-4-6
           The cron runners default to `claude-sonnet-4-6`. To override:
             export BENCH_DREAM_MODEL=claude-sonnet-4-6
           Persist it the same way you persisted BENCH_WIKI_INGEST_KEY.
        2. Confirm the wiki vault exists at:
             ~/.openclaw/wiki/main/
           Dream output is written under _dreams/ and _canon/ inside that vault.
        3. Start the launchd agent:
             brew services start bench-reflective-dreaming

      Logs:
        ~/.openclaw/logs/reflective-dreaming.log
        ~/.openclaw/logs/canon-consolidation.log

      Manual runs:
        bench-dream                     # one dream pass for the current agent
        bench-canon-consolidate         # force a canon consolidation now
        bench-session-distill           # distill the latest session into wiki

      Upgrading:
        brew upgrade benchagi/tap/bench-reflective-dreaming && \\
          brew services restart bench-reflective-dreaming
    EOS
  end

  test do
    # The runners support `--dry-run` for idempotent self-test (no model
    # call, no wiki writes). Until v0.1.0 lands we can only assert the
    # symlinks exist and are executable.
    %w[bench-dream bench-canon-consolidate bench-session-distill].each do |cmd|
      target = bin/cmd
      next unless target.exist?

      assert_predicate target, :executable?
    end
  end
end
