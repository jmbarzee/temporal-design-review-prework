# design-review-prework

An AI-assistive skill customers run **on their own machine, against their own code**, to prepare the prework bundle for a Temporal design review or optimization session: an external + internal architecture diagram set, a system report, answers to the questions the Solutions Architect will ask, and a specific agenda — instead of "4 boxes and lines."

## How a customer uses it

1. Open your AI coding agent (Claude Code, Cursor, etc.) with this skill available (`skills/design-review-prework/`).
2. Say: *"Help me prepare prework for my Temporal design review."*
3. Answer a short intake (approximate answers are fine), confirm the discovered scope, review the bundle, share it with your Temporal team.

The skill is **read-only** against your code, makes **no network calls** without explicit opt-in, and ends with a share manifest so you can see exactly what you're sending.

Optional, experimental: if the [temporal-architect](https://github.com/jmbarzee/temporal-architect) toolchain is installed, the run can additionally recover your system into validated `.twf` files you keep and visualize.

## Layout

- `skills/design-review-prework/SKILL.md` — the pipeline (7 phases)
- `skills/design-review-prework/reference/` — SA question list, diagram quality guide, twf path, output spec
