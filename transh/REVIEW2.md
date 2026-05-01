# Review: Changes Since Last Commit

Reviewed the current worktree against `HEAD`, including tracked edits and untracked files under `.claude/`, `planning/`, and `transh/`.

## Findings

### High: Stop hook performs unrequested repo writes at the end of every Claude turn

File: `.claude/settings.json:13`

The new `Stop` hook runs:

```text
codex exec "Review changes since last commit and write results to the file planning/REVIEW.md"
```

Because `Stop` fires whenever Claude finishes a turn, normal sessions will now launch a Codex review and rewrite `planning/REVIEW.md` even when the user did not request a review. The output file is also part of the worktree being reviewed, so each hook run can review and overwrite its own previous artifact. That keeps the tree dirty and makes review results unstable.

Recommendation: remove the always-on `Stop` hook. Prefer an explicit command for reviews, or have automation write to an ignored, unique artifact outside the reviewed diff.

### High: Local permission policy should not be committed

File: `.claude/settings.local.json:1`

The untracked local settings file allows:

```json
"Bash(codex exec *)"
```

This is broad, machine-local permission state. If committed, it would normalize arbitrary `codex exec` usage from prompts, including the newly added agent prompts that write repo files.

Recommendation: keep `.claude/settings.local.json` untracked and add it to `.gitignore` if needed. If shared permissions are required, put narrowly scoped, reviewed settings in the repo-level config instead.

### Medium: `change-reviewer` says it reviews all changes but only reviews `PLAN.md`

File: `.claude/agents/change-reviewer.md:6`

The agent claims it "reviews all changes since the last commit using shell commands", but the required command is:

```text
codex exec "Please review the file planning/PLAN.md and write your feedback to planning/REVIEW.md"
```

That excludes `.claude` settings, agent definitions, command files, local permission files, `transh/` files, and any future non-`PLAN.md` changes. This can produce a false clean review while risky config changes are present.

Recommendation: either change the prompt to review `git diff HEAD` plus untracked files, or rename/reword the agent as a `PLAN.md`-only reviewer.

### Medium: `reviewer` uses the wrong path casing

File: `.claude/agents/reviewer.md:6`

The agent instructs reviewers to inspect `planning/Plan.md`, but the repo file is `planning/PLAN.md`. This works on case-insensitive filesystems and fails on case-sensitive systems.

Recommendation: update the path to `planning/PLAN.md`.

### Medium: `PLAN.md` keeps contradictions instead of resolving them

Files: `planning/PLAN.md:140`, `planning/PLAN.md:361`, `planning/PLAN.md:372`

The environment section labels `OPENROUTER_API_KEY` as required, then says the server starts normally without it and only `/api/chat` returns 503. Later, the LLM section says there is an API key in the project-root `.env`.

The plan also still tells implementers to use the `cerebras-inference skill`, while the newly appended Notes section says agent-specific tooling guidance should be moved out of the production spec. The document now contains both the problematic instruction and a note saying it should not be there.

Recommendation: define one OpenRouter contract: optional for app startup, required only for live chat, with mock mode as the no-key test path. Move agent/tooling guidance to an agent-facing file and keep `PLAN.md` focused on runtime behavior.

### Low: new agent prompts contain typos and truncated text

Files: `.claude/agents/reviewer.md:6`, `.claude/agents/codex-reviewer.md:6`, `.claude/agents/codex-reviewer.md:7`, `.claude/agents/change-reviewer.md:8`

The new prompt files include `reiew`, `Y'`, `sae`, and `kick of`. These may not break execution, but prompt files are operating instructions, so typos and truncated text make intended behavior harder to trust.

Recommendation: clean up the agent prompt text before relying on these agents.

### Low: `transh/` appears to be scratch review output

Files: `transh/REVIEW1.md`, `transh/REVIEWcodex.md`

The untracked `transh/` directory contains alternate review outputs. If this is temporary scratch space, committing it will add noisy review artifacts with unclear lifecycle.

Recommendation: either move useful content into the canonical planning docs or keep `transh/` ignored.

## Open Questions

- Should `planning/REVIEW.md` be tracked as a current review artifact, or generated on demand and ignored?
- Should the `.claude/agents/*` files be project-level shared tooling, or are they local workflow experiments?

## Coverage Notes

No application source code changed in the tracked diff. The README edits look consistent with the documented start scripts and do not raise a blocking issue.
