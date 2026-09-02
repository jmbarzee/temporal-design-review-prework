# The `twf` path (experimental)

An **opt-in, experimental** alternative for Phases 4–5: recover the system into `.twf` (Temporal Workflow Format) — a validated, parseable model the customer keeps, edits, and visualizes — alongside the standard bundle.

## When it pays off

**The test is not "mechanics versus topology." It is: will writing the notation surface something that reading the code will not?**

That question has a size answer. On a small or single-slice target, committing to exact option values and explicit control flow genuinely forces precision that prose lets you skip. On a large multi-slice target it does not fire: each slice ends up modeled at partial fidelity, and the precision lands only on the parts you chose to write down — which you choose *after* you already understand them. Every mechanics finding then comes from reading code, and the recovery is pure overhead.

So: recommend it for a bounded target where the model can be near-complete. For a large monorepo, say plainly that the `.twf` recovery is unlikely to earn its cost and offer `twf graph` alone (below) instead. "Experimental, opt-in" undersells how much of a large run this path consumes — be honest about that when offering it.

Mention the path once, neutrally; if the user prefers the generic path, drop it without argument.

Two honest limits to set expectations against:
- **`twf check` is a grammar gate, not a design reviewer.** Every error it reports is about notation, not about Temporal. It contributes no design findings on its own.
- **`twf graph --json` is the highest-value part of this path, and cheap.** It gives a dispatch and containment listing that works as a call-wiring cross-check, and its routing diagnostics earn their keep: a reported routing mismatch is a real prompt to go back into the code, where the answer is usually an override you had not found yet. That chase also catches values you invented rather than observed. It is not diagram structure — diagrams still come from your research per the diagram guide.

## Step 0 — Verified in Phase 0

Availability (`twf --help`, plus the `temporal-architect` skills — `temporal-architect-design` and its reverse-engineering references) is established in Phase 0, before any code is read. If it is missing and the user wants this path, point them at the public install channels once — the VS Code / Cursor extension `jmbarzee.twf-syntax`, or `npx -y @temporal-architect/twf` — then, if it still isn't working, fall back to the generic path and say so plainly. No penalty; do not spend the flow debugging an install.

## Read the notation before you write

`temporal-architect-design/SKILL.md` says "write before you read the reference docs." That is good *greenfield* advice and **wrong here**: on the reverse path you already know the semantics, and the notation is the only unknown. Skim `notation-examples.md` and the `state:` block conventions first. Skipping it costs several parser round-trips and produces a first draft that a design review then flags wholesale.

## Recovery — delegate, don't reinvent

The mechanics belong to `temporal-architect-design`'s reverse path; follow its `reference/reverse-engineering.md`:

- Single bounded slice → project-discovery subagent → extract to `.twf` → fidelity check.
- Multi-slice scope → slice-mapper subagent proposes the slice map → confirm with the user **at the existing Phase 3 gate**, not as a second confirmation → recover producers-before-consumers → stitch.
- Carry over verbatim: domain slices are **symbols-only** (no invented workers or namespaces); shared deployment topology is authored once in a `deploy` package; **fidelity first** — capture what the code does, anti-patterns included, and never "fix" during extraction. Capturing the design as it really is — surprising parts included — is what the review is *for*.
- Gate the workspace with `twf check` over the whole tree.

### Sort the two kinds of review finding

When the recovered model is reviewed, findings arrive in two categories that must not be confused. This is the most important judgment call on this path:

- **"The code does X, and X is a known shape worth the SA's attention"** → preserve X in the model exactly as found. This is the deliverable.

  **Record it neutrally.** Do not write `ANTI-PATTERN:` headers or any other verdict into the `.twf` — the map-not-review rule in SKILL.md governs every customer-facing artifact, and the `.twf` files are customer-facing. Write `# AS FOUND:` with the mechanism and the exact values, and let the SA judge. A bundle whose report is neutral and whose `.twf` shouts verdicts is tonally incoherent, and the customer notices.
- **"Your model misstates the code"** → a model bug. Fix it immediately, and never let it reach the report as a design finding.

The trap is real: writing an *effective* value into `options:` where the code leaves the option **unset** (so the server applies its default) misstates the code, while omitting it loses the behavior. Record the distinction in a comment and log it as a language gap.

## Outputs (in addition to the standard bundle)

Under `<out>/twf/`:

- The recovered `.twf` workspace. **Flatten it into `twf/` as one package** — `twf/<slice>.twf` plus `twf/topology.twf` — rather than per-domain subdirectories. Cross-file references resolve only within a shared file set, and a recovered bundle is read as a whole; `temporal-architect`'s package-per-domain convention serves a maintained project, not a point-in-time recovery. Note the choice in the report.
- `twf-retro.md` — the **language/toolchain reflection**. A first-class deliverable of this path, not a byproduct.

### Three reflections, three audiences — never merge them

This path produces a reflection that is easy to confuse with two other things. Keep them in separate files with separate readers:

| Artifact | Question it answers | Audience |
|---|---|---|
| `twf/twf-retro.md` | What did the code do that **`.twf` could not express**? | The `temporal-architect` toolchain maintainers |
| `gap-ledger.md` | What could **the reader not determine** about this system? | The SA and the customer's own team |
| *(not in the bundle)* | How well did **this prework skill** perform? | Whoever maintains this skill |

**`twf-retro.md` is about the notation, not about the system and not about this skill.** Each entry: what the code does, its `file:line`, and the construct that was missing or the workaround forced. A parser bug or a rejected-but-valid construct belongs here, with a minimal reproducing probe when you have one — that is the most actionable thing a maintainer can receive.

Two exclusions that matter:
- Something *the reader* could not determine — hidden deployment wiring, config-driven routing, a service with no source — is a **`gap-ledger.md`** entry. It is a fact about access, not about the language.
- Friction with *these prework instructions* is **neither**. Do not put it in the bundle; the bundle is the customer's, and it goes to a Temporal SA who has no stake in this skill's internals. Raise it in conversation if the user asks.

It is fine to say plainly that `twf-retro.md` is optional to share with the SA — its natural destination is a toolchain issue, and the customer may reasonably want to send it upstream themselves.

## Visualizer

Offer to open the visualizer for the customer's own exploration. It is localhost — useful to them, not shareable. The share manifest lists `.twf` files, diagrams, and the report; never a localhost URL.
