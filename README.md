# design-review-prework

An AI-assistive skill customers run **on their own machine, against their own code**, to prepare the prework bundle for a Temporal design review or optimization session: an external + internal architecture diagram set, a system report, answers to the questions the Solutions Architect will ask, and a specific agenda — instead of "4 boxes and lines."

## How a customer uses it

1. Open your AI coding agent (Claude Code, Cursor, etc.) with this skill available (`skills/design-review-prework/`).
2. Say: *"Help me prepare prework for my Temporal design review."*
3. Answer a short intake (approximate answers are fine), confirm the discovered scope, review the bundle, share it with your Temporal team.

The skill is **read-only** against your code, makes **no network calls** without explicit opt-in, and ends with a share manifest so you can see exactly what you're sending.

Recommended: the [temporal-architect](https://github.com/jmbarzee/temporal-architect) `twf` parser — a single Go binary, installable with a pinned `go install` and no npm — lets the run machine-check every wiring claim in the report (which worker runs what, which queue a call reaches). The skill offers to help install it up front, and to show you the result as an interactive graph. Recovering workflow bodies into `.twf` is a separate, experimental option for one bounded slice.

## Layout

- `skills/design-review-prework/SKILL.md` — the pipeline (7 phases)
- `skills/design-review-prework/reference/` — SA question list, diagram quality guide, twf path, output spec
