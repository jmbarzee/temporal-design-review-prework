# The `twf` path (experimental)

An **opt-in, experimental** alternative for Phases 4–5: recover the system into `.twf` (Temporal Workflow Format) — a validated, parseable model the customer keeps, edits, and visualizes — alongside the standard bundle.

## When it pays off

Recommend it only when the review's questions are about **mechanics**: exact option values, control flow, child-workflow lifetime semantics, retry and timeout specifics. Writing near-executable notation forces precision that prose lets you skip, and that precision is where its findings come from.

It pays off much less when the review is about **topology or scale** — there, the Mermaid diagrams and the operational envelope carry the value, and the `.twf` becomes a curiosity riding along with the report. Mention the path once, neutrally; if the user prefers the generic path, drop it without argument.

Two honest limits to set expectations against:
- **`twf check` is a grammar gate, not a design reviewer.** Every error it reports is about notation, not about Temporal. It contributes no design findings on its own.
- **`twf graph --json` gives a dispatch and containment listing**, useful as a call-wiring cross-check. It is not diagram structure — the diagrams still come from your research per the diagram guide.

## Step 0 — Verified in Phase 0

Availability (`twf --help`, plus the `temporal-architect` skills — `temporal-architect-design` and its reverse-engineering references) is established in Phase 0, before any code is read. If it is missing and the user wants this path, point them at the public install channels once — the VS Code / Cursor extension `jmbarzee.twf-syntax`, or `npx -y @temporal-architect/twf` — then, if it still isn't working, fall back to the generic path and say so plainly. No penalty; do not spend the flow debugging an install.

## Read the notation before you write

`temporal-architect-design/SKILL.md` says "write before you read the reference docs." That is good *greenfield* advice and **wrong here**: on the reverse path you already know the semantics, and the notation is the only unknown. Skim `notation-examples.md` and the `state:` block conventions first. Skipping it costs several parser round-trips and produces a first draft that a design review then flags wholesale.

## Recovery — delegate, don't reinvent

The mechanics belong to `temporal-architect-design`'s reverse path; follow its `reference/reverse-engineering.md`:

- Single bounded slice → project-discovery subagent → extract to `.twf` → fidelity check.
- Multi-slice scope → slice-mapper subagent proposes the slice map → confirm with the user **at the existing Phase 3 gate**, not as a second confirmation → recover producers-before-consumers → stitch.
- Carry over verbatim: domain slices are **symbols-only** (no invented workers or namespaces); shared deployment topology is authored once in a `deploy` package; **fidelity first** — capture what the code does, anti-patterns included, and never "fix" during extraction. The anti-patterns are what the review is *for*.
- Gate the workspace with `twf check` over the whole tree.

### Sort the two kinds of review finding

When the recovered model is reviewed, findings arrive in two categories that must not be confused. This is the most important judgment call on this path:

- **"The code has an anti-pattern"** → preserve it in the model and report it. This is the deliverable.
- **"Your model misstates the code"** → a model bug. Fix it immediately, and never let it reach the report as a design finding.

The trap is real: writing an *effective* value into `options:` where the code leaves the option **unset** (so the server applies its default) misstates the code, while omitting it loses the behavior. Record the distinction in a comment and log it as a language gap.

## Outputs (in addition to the standard bundle)

Under `<out>/twf/`:

- The recovered `.twf` workspace (per-domain packages plus `deploy/topology.twf`).
- `twf-retro.md` — a **language-gap ledger only**: things the code does that `.twf` could not express, each with its code location and the missing construct. This feeds the toolchain and is optional to share. Things the *reader* could not determine (hidden wiring, missing access) belong in `gap-ledger.md`, never here.

## Visualizer

Offer to open the visualizer for the customer's own exploration. It is localhost — useful to them, not shareable. The share manifest lists `.twf` files, diagrams, and the report; never a localhost URL.
