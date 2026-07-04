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

### [ibelick/ui-skills](https://github.com/ibelick/ui-skills)
- `baseline-ui` — deslop UI: fix spacing, hierarchy, typography, small layout issues
- `fixing-accessibility` — audit and fix HTML a11y (ARIA, keyboard nav, focus, contrast)
- `fixing-metadata` — audit and fix HTML metadata (titles, OG tags, canonical URLs, JSON-LD)
- `fixing-motion-performance` — audit and fix animation performance (layout thrashing, compositor)

All included skills are self-contained guidance — none require an external CLI.

## How skills are wired to agents

Two mechanisms are in play:

**1. Deterministic bindings (agents explicitly told to use a skill).**
These agents have the `Skill` tool and instructions to invoke specific skills when
their conditions are met:

| Agent / command | Skill(s) | When |
|-----------------|----------|------|
| `code-reviewer` | `scrutinize` | every review, before summarizing |
| `code-reviewer` | `fixing-accessibility`, `fixing-motion-performance`, `fixing-metadata`, `baseline-ui` | when the diff touches UI/HTML/CSS |
| `feature-developer` | `debug-mantra` | in debug/diagnosis mode (`/fix-bug`, `/hotfix`) |
| `feature-developer` | `baseline-ui`, `fixing-accessibility`, `fixing-metadata`, `fixing-motion-performance` | when the change touches UI/HTML/CSS |
| `qa-tester` | `fixing-accessibility` | when testing UI/HTML |
| `/fix-bug` (Step 4) | `post-mortem` | after the fix is verified |
| `/hotfix` (footer) | `post-mortem` | recommended follow-up |

**2. Automatic selection (model decides from the skill `description`).**
`management-talk` and any skill above, when used outside its bound agent, still
fire automatically in the main conversation based on their trigger text — or on
explicit `/skill-name` invocation.

> Note: subagents can only invoke skills if `Skill` is listed in their `tools:`
> frontmatter. The three agents above were updated to include it; the other
> agents (`system-analyst`, `code-explainer`, `pipeline-state`) are left unbound.

## Updating
These are copies, not submodules. To refresh, re-copy the skill folders from the
upstream repos' `skills/` directories.
