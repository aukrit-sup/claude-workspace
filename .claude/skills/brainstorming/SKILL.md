---
name: brainstorming
description: Socratic design brainstorming with the user to turn a vague feature/idea into resolved design decisions BEFORE any spec or code is written. Runs in the main conversation (orchestrator), never inside a subagent — a subagent can only list open questions, it cannot hold a live back-and-forth with the user. Trigger on /brainstorming, /brainstorm, and proactively before writing a spec or starting design when the request is ambiguous, underspecified, or has multiple viable approaches — e.g. the user says "ช่วยออกแบบ", "ถกแบบก่อน", "คุยดีไซน์", "brainstorm", "let's design this", "help me think through", or hands a one-line idea that needs shaping. Precedes system-analyst in /spec-only and /build-feature.
---

# Brainstorming

Turn a fuzzy request into settled design decisions through a real dialogue with the user, so the spec that follows is a formality — not a pile of guesses.

## Where this runs

This skill runs in the **main conversation (the orchestrator / slash-command loop)** — the only place that can ask the user a question and get an answer back. **Do not put brainstorming inside a subagent.** `system-analyst` runs isolated: it can list "open questions" but cannot resolve them with the user mid-run. So brainstorm first, resolve the decisions, *then* hand the resolved decisions to `system-analyst` to formalize into a spec.

## Be proportional (ponytail)

Gauge the request before interrogating anyone:

- **Clear + small** (a well-scoped one-liner, an obvious bug fix) → skip brainstorming or do a single confirming sentence. Don't inflict 10 questions on a 5-minute task.
- **Ambiguous, large, or multiple viable approaches** → run the full loop below.

When you skip, say so in one line ("ชัดพอแล้ว ข้าม brainstorm ไปทำ spec เลย") and move on.

## Workflow

### 1. Frame the problem
State, in one sentence, the problem you think the user is solving — not the solution they proposed. Get a yes/no. If you can't state it, that *is* the first question. Often the stated solution is not the real need; surface that gap now, not after a spec is written.

### 2. Ask one question at a time
Socratic, not a questionnaire. Ask the single highest-leverage question, react to the answer, then go deeper. Dumping 8 questions at once gets shallow answers and hides which one actually matters.
- Use the **AskUserQuestion** tool when the choice is discrete (2–4 concrete options) — it's faster for the user and records the decision cleanly.
- Ask open-ended in prose when the space isn't yet discrete.

### 3. Surface hidden assumptions
Say the assumptions out loud and get confirm/deny: who uses this, how often, what scale, what happens on failure, what "done" looks like. An unspoken assumption is the most expensive kind — it survives all the way to production.

### 4. Explore alternatives, then recommend
For each load-bearing decision, put 2–3 approaches on the table with their trade-offs, then **recommend one** with a reason — don't just present a menu and make the user architect it. Include the laziest option that could work (do nothing / use what exists / native feature). Challenge scope explicitly: name what you are proposing to *leave out* (YAGNI) and confirm the user agrees.

### 5. Converge — don't brainstorm forever
When the load-bearing decisions are settled, stop. Say the decisions are settled and move to the brief. Circling back over a decided point is looping (see [[stay-on-track]]) — resist it.

### 6. Produce the design brief
Output a compact brief — the resolved input for `system-analyst`, not a full spec:

- **Problem** — one paragraph, in the user's own terms
- **Decisions** — the settled choices (what, and one-line why)
- **Chosen approach** — plus the alternatives rejected, one line each on why
- **Scope** — explicitly in / out
- **Left for the spec** — details that are genuinely `system-analyst`'s job to work out (not unresolved design decisions — those you should have resolved here)

**In a pipeline** (`/spec-only`, `/build-feature`): write the brief to the run report directory as `00-brainstorm.md`, and pass it verbatim into the `system-analyst` prompt so the spec builds on settled decisions instead of re-asking.
**Standalone** (`/brainstorm`): present the brief in chat and offer to continue with `/spec-only` or `/build-feature`.

## Operating rules

- **Live dialogue only.** If you cannot actually ask the user (you're in a subagent, or running headless), you are not brainstorming — hand back and let the orchestrator do it.
- **One question at a time.** No questionnaires.
- **Recommend, don't just enumerate.** Every option set ends with your pick and why.
- **Don't write the spec or code here.** Brainstorming resolves decisions; `system-analyst` formalizes them; `feature-developer` builds them. Stay in your lane.
- **Converge.** The goal is a short brief and a clear handoff, not an exhaustive transcript.
- **Thai.** Talk to the user in Thai (repo rule).
