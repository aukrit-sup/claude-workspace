# Claude Skills

Skills in this directory are vendored (copied) from two upstream repositories so
the agent can reference them during work. Each skill lives in its own folder with
a `SKILL.md`.

## Sources

### [thananon/9arm-skills](https://github.com/thananon/9arm-skills)
- `debug-mantra` — four-mantra debugging discipline (reproduce, trace, falsify, cross-reference)
- `post-mortem` — write the canonical engineering record of a fixed bug (root cause, fix, validation)
- `scrutinize` — outsider-perspective end-to-end review of a plan, PR, or code change
- `management-talk` — rewrite engineer-to-engineer content for engineering-org leadership
- `qwenchance` — keep a long task on-track; avoid loops and manage context budget

### [ibelick/ui-skills](https://github.com/ibelick/ui-skills)
- `baseline-ui` — deslop UI: fix spacing, hierarchy, typography, small layout issues
- `fixing-accessibility` — audit and fix HTML a11y (ARIA, keyboard nav, focus, contrast)
- `fixing-metadata` — audit and fix HTML metadata (titles, OG tags, canonical URLs, JSON-LD)
- `fixing-motion-performance` — audit and fix animation performance (layout thrashing, compositor)
- `ui-skills-root` — select the smallest useful UI Skills context *(requires the `ui-skills` CLI)*

## Notes on external dependencies
- `ui-skills-root` invokes the `ui-skills` CLI.

These skills are still readable/usable as guidance, but their CLI-backed features
will not work unless the corresponding tool is installed.

## Updating
These are copies, not submodules. To refresh, re-copy the skill folders from the
upstream repos' `skills/` directories.
