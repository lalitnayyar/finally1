# Review: Changes Since Last Commit

Reviewed the current worktree against `HEAD`, including tracked edits and untracked files under `.claude-plugin/`, `.claude/`, `independent-reviewer/`, and `transh/`.

## Findings

### High: README quick start points to files that do not exist

Files: `README.md:20`, `README.md:24`, `README.md:27`, `README.md:58`, `README.md:68`, `README.md:71`, `README.md:72`, `README.md:74`

The new README instructs users to copy `.env.example`, run `./scripts/start_mac.sh`, run `./scripts/start_windows.ps1`, and start a frontend from `frontend/`. It also lists `scripts/`, `test/`, and `Dockerfile` in the project structure. None of those paths exist in the current checkout:

- `.env.example`: missing
- `scripts/`: missing
- `frontend/`: missing
- `test/`: missing
- `Dockerfile`: missing

This makes the top-level quick start unusable for a fresh reader. Either add the promised files as part of the same change, or revise the README to describe the currently runnable backend-only workflow.

### High: Enabling the reviewer plugin can make normal Claude stops rewrite the repo

Files: `.claude/settings.json:6`, `independent-reviewer/hooks/hooks.json:3`, `independent-reviewer/hooks/hooks.json:8`

The tracked settings now enable `independent-reviewer@LalitTools`, and the plugin registers a `Stop` hook that runs:

```text
codex exec "Review changes since last commit and write results to the file planning/REVIEW.md"
```

Because this hook fires on every Claude `Stop` event, ordinary assistant turns can launch Codex and rewrite `planning/REVIEW.md` even when the user did not ask for a review. The generated review file is also inside the worktree being reviewed, so repeated hook runs can keep the tree dirty and produce unstable diffs.

Recommendation: make this an explicit command instead of an always-on `Stop` hook, or write generated review artifacts to an ignored path outside the reviewed diff.

### Medium: Local permission settings should not be committed

File: `.claude/settings.local.json:1`

The untracked local settings file grants:

```json
"Bash(codex exec *)"
```

This is broad machine-local permission state. If committed, it would normalize arbitrary `codex exec` invocations from project prompts and hooks, including the new reviewer automation that writes repo files.

Recommendation: keep `.claude/settings.local.json` untracked and add it to `.gitignore` if needed. Shared repo settings should be narrower and reviewed separately.

### Medium: Reviewer agent says it reviews all changes but only reviews `PLAN.md`

File: `.claude/agents/change-reviewer.md:6`, `.claude/agents/change-reviewer.md:10`

The agent text says it reviews all changes since the last commit, but the command it requires is:

```text
codex exec "Please review the file planning/PLAN.md and write your feedback to planning/REVIEW.md"
```

That excludes changes to README, Claude settings, plugin hooks, local permission files, and future application code. This can produce a false sense that the full diff was reviewed.

Recommendation: either change the prompt to review `git diff HEAD` plus untracked files, or rename the agent as a `PLAN.md`-only reviewer.

### Medium: Reviewer agent uses wrong path casing

File: `.claude/agents/reviewer.md:6`

The reviewer prompt references `planning/Plan.md`, but the file in the repo is `planning/PLAN.md`. This will work on case-insensitive filesystems and fail on case-sensitive environments.

Recommendation: update the prompt to `planning/PLAN.md`.

### Low: New agent prompts contain typos and truncated text

Files: `.claude/agents/reviewer.md:6`, `.claude/agents/codex-reviewer.md:6`, `.claude/agents/codex-reviewer.md:7`, `.claude/agents/change-reviewer.md:8`

The new prompt files include typos and stray/truncated text such as `reiew`, `Y'`, `sae`, and `kick of`. These may not break execution, but prompt files are operating instructions, so ambiguity here makes the automation harder to trust.

Recommendation: clean up these prompt files before relying on them.

### Low: `transh/` appears to be scratch review output

Files: `transh/README.md`, `transh/REVIEW1.md`, `transh/REVIEW2.md`, `transh/REVIEWcodex.md`

The untracked `transh/` directory contains alternate README/review artifacts. If this is temporary scratch space, committing it will add noisy documents with unclear ownership and lifecycle.

Recommendation: move any useful content into canonical planning docs and ignore or remove the scratch directory.

## Open Questions

- Should `planning/REVIEW.md` be tracked as a current review artifact, or generated on demand and ignored?
- Is the independent reviewer plugin intended to be shared project tooling, or just local workflow experimentation?

## Coverage Notes

No application source code changed in the tracked diff. I did not run tests because the reviewed changes are documentation and Claude/plugin configuration only.
