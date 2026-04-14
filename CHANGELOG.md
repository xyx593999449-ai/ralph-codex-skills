# Changelog

## 2026-04-14

### Changed
- Rewrote `README.md` in Simplified Chinese for the open-source Codex adaptation, clarifying that the public package is the four-skill bundle under `skills/`, not a requirement to copy the whole repository root.
- Refocused `README.md` around the Codex global-skill installation path and documented `run-ralph-codex` as a self-contained skill that injects its own runtime templates into target projects.
- Documented the recommended four-step flow as `brainstorming -> prd -> ralph -> run-ralph-codex` and expanded the setup section with Codex global-skill installation instructions.
- Clarified `run-ralph-codex` usage, including `--all`, Git gating, `--model`, and `--reasoning-effort`, plus the append-only backlog and timestamped log conventions.

## 2026-04-13

### Added
- Added a local `skills/brainstorming/` skill adapted from `obra/superpowers`, including optional visual companion assets and scripts for browser-assisted brainstorming.
- Added Codex support to `ralph.sh` with `--tool codex`.
- Added `CODEX.md` guidance for Codex-driven Ralph iterations.
- Added timestamped iteration log support under `tmp/ralph/`.
- Added a local Codex plugin manifest at `.codex-plugin/plugin.json`.
- Added `fixture/.gitignore` and `tmp/ralph/.gitkeep` to keep validation artifacts and log directories stable.
- Added the `run-ralph-codex` skill, including bundled runtime templates and a reusable shell wrapper for injecting missing files before executing `ralph.sh --tool codex`.
- Added `--all` support to `run-ralph-codex`, allowing the wrapper to set its iteration cap from the current pending story count.
- Added Git environment gating to `run-ralph-codex`, including an explicit prompt path when the target directory is not a repository plus optional `--init-git` and `--repo <path>` flags.
- Fixed Ralph completion detection so Codex-backed runs now use `prd.json` as the primary completion signal instead of trusting any raw `<promise>COMPLETE</promise>` string found in the log.
- Added explicit `--model` and `--reasoning-effort` passthrough support so `run-ralph-codex` can control the launched `codex exec` invocation.

### Changed
- Updated `skills/prd/SKILL.md` for Codex-compatible plain `SKILL.md` discovery, explicit input expectations, and output behavior.
- Updated `skills/ralph/SKILL.md` for Codex-compatible plain `SKILL.md` discovery and append-only backlog handling.
- Updated `README.md` to document the new `run-ralph-codex` execution skill.
- Updated `README.md` to document the intended four-step flow: `brainstorming -> prd -> ralph -> run-ralph-codex`.
- Updated `prd.json` planning metadata to treat the backlog as append-only and document the timestamped log policy.
- Updated `README.md` with Codex prerequisites, usage, append-only backlog guidance, and log inspection instructions.

### Removed
- Removed the checked-in generated fixture marker `fixture/.validated`; it is now treated as runtime output.
