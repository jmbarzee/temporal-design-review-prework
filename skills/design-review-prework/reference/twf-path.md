# The `twf` path (experimental)

An **opt-in, experimental** alternative for Phases 4–5: recover the system into `.twf` (Temporal Workflow Format) — a validated, parseable model the customer keeps, edits, and visualizes — alongside the standard report. Offer it once, neutrally, at the Phase 3 confirm gate; if the user prefers the generic path, drop it without argument. If they opt in, everything below applies.

## Step 0 — Verify the installation (never assume)

Check, in order:

1. `twf --help` succeeds on PATH.
2. The **temporal-architect skills** are present (Claude Code plugin `temporal-architect@temporal-architect`, `~/.cursor/skills/temporal-architect-*`, or a checkout's `skills/` tree). The needed one here is `temporal-architect-design` and its reverse-engineering references.

If either is missing, offer to help install via **public channels only** — VS Code / Cursor extension `jmbarzee.twf-syntax`; Claude Code `/plugin marketplace add jmbarzee/temporal-architect-dist` + `/plugin install temporal-architect@temporal-architect`; `npx -y @temporal-architect/twf`; `brew install jmbarzee/twf/twf`; `pip install twf-cli` — and after installing, **recommend restarting the prework in a fresh chat** so the skills load cleanly (offer to write a one-paragraph resume note into the output directory first: lead answers + confirmed scope, so nothing is lost).

If verification fails and the user doesn't want to install, fall back to the generic path — say so plainly, no penalty.

## Recovery — delegate, don't reinvent

The mechanics are owned by `temporal-architect-design`'s **reverse path**; follow its `reference/reverse-engineering.md` rather than improvising:

- Single bounded slice → project-discovery subagent → extract to `.twf` → fidelity check.
- Multi-slice scope → slice-mapper subagent proposes the slice map → **confirm with the user** (merge this with the Phase 3 confirm gate — one confirmation, not two) → recover producers-before-consumers → stitch.
- Discipline that carries over verbatim: domain slices are **symbols-only** (no invented workers/namespaces); the shared deployment topology is authored once in a `deploy` package; **fidelity first** — capture what the code does, anti-patterns included, never "fix" during extraction (the anti-patterns are exactly what the design review is for).
- Gate the workspace with `twf check` over the whole tree; iterate to clean or explain remaining diagnostics in the retro.

## Outputs (in addition to the standard bundle)

Under `<out>/twf/`:

- The recovered `.twf` workspace (per-domain packages + `deploy/topology.twf`).
- `twf-retro.md` — **language-gap ledger only**: things the code does that `.twf` could not express, each with the code location and what construct was missing. This feeds the toolchain; keep it separate from the customer's gap ledger. Things the *reader* couldn't determine (hidden wiring, missing access) go to the shared `gap-ledger.md`, never here.

Diagrams on this path: derive structure from `twf graph --json` (topology) and the `.twf` itself (workflow shape), then still render Mermaid per the diagram guide — the SA receiving the bundle may have no twf tooling. The `.twf` files ride along as a bonus artifact, with one line in the report explaining what they are and where the toolchain lives.

## Visualizer

Offer to open the visualizer **for the customer's own exploration** (via the editor extension's `twf.visualize`, or the dist `twf-serve` if installed). It runs on localhost: useful to *them*, not shareable prework. The share manifest lists `.twf` files, rendered diagram images, and the report — never a localhost URL.
