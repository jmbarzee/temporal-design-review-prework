# The `twf` toolchain

The temporal-architect toolchain gives this skill the one check prose cannot do for itself: **deterministic validation of wiring** — which worker hosts what, which task queue a call routes to, whether a call can reach a worker at all. It works in two tiers. Recommend the first on every run. Offer the second only for a bounded slice.

## Why it is recommended

Every claim in the report about *where something runs* is an inference from reading code, and nothing else in this skill can check one. The self-consistency pass compares the bundle with itself; the composition pass compares facts with each other. Neither can tell you that an activity you attributed to worker A actually executes on worker B.

That error class is what the toolchain catches. In the first real customer run, a bundle that had **already been sent to the SA** attributed an activity to a shared worker's share of execution volume. Modeling that wiring the way the report described it made `twf graph` raise `IMPLICIT_ROUTING_MISMATCH`: the activity's configurator set no task queue, so it ran on each *calling* workflow's queue instead. No number in the bundle was wrong — the attribution was. Across every evaluated run so far, the routing check has caught a real wiring error, a different one each time.

## Two halves

| Half | What it is | Needed? |
|---|---|---|
| **Parser / CLI** — `twf`, one Go binary | `twf check` and `twf graph`: the deterministic validation | **Yes**, for either tier |
| **Visualizer** — `twf-view`, or the editor extension | an interactive graph of a `.twf` model | No. Optional, for the customer's own exploration |

Say this plainly when you make the offer. A customer who turns down the npm route has not turned down the toolchain: the parser alone is a single binary with several ways to get it.

The binary carries its own grammar reference — `twf spec --list` and `twf spec <slug>` — so the parser is enough to write a model. The `temporal-architect` skills help but are not required.

## Phase 0 — confirm, then help install

Installing needs the network, so the toolchain is raised in **Phase 0** alongside the renderer, while egress is still allowed. Never defer it to a later phase: an opt-in that arrives after the egress window has closed cannot be acted on.

1. **Check:** `twf --version`.
2. **If it is absent, recommend it with the reason above and offer to help install it.** This is a confirm-and-assist, not a yes/no that ends the path. Offer the channels in order of how easy they are to audit:

   | Channel | Command | Pulls from |
   |---|---|---|
   | **Go, pinned** — most auditable | `go install github.com/jmbarzee/temporal-architect/tools/lsp/cmd/twf@v0.14.0` | Go module proxy, verified against the Go checksum database; runs no install scripts |
   | Homebrew | `brew install jmbarzee/twf/twf` | the `jmbarzee/twf` tap |
   | PyPI | `pip install twf-cli` | PyPI |
   | Release binary | `curl -sSL https://raw.githubusercontent.com/jmbarzee/temporal-architect-dist/main/packages/install.sh \| bash` | GitHub release assets |
   | npm | `npx -y @temporal-architect/twf` | npm, including package install scripts |

   Use the newest `tools/lsp/vX.Y.Z` tag in place of `v0.14.0`: `git ls-remote --tags https://github.com/jmbarzee/temporal-architect | grep tools/lsp/`. Go 1.25 or newer is needed for the `go install` route.

3. **If the customer wants to audit before installing, help them do it.** The source is public and MIT-licensed. The parser and CLI can be checked for network and process-execution surface in seconds, from a checkout at the pinned tag:

   ```bash
   grep -rln --include='*.go' -e '"os/exec"' -e '"net"' -e '"net/http"' tools/lsp | grep -v _test.go
   ```

   At `v0.14.0` it returns nothing. Point them at the check rather than asserting the result — it is theirs to verify.

4. **Offer the visualizer as a separate, optional choice:** `brew install jmbarzee/twf/twf-view`, or `go install github.com/jmbarzee/temporal-architect-dist/packages/twf-view@latest` (pin a version if they are auditing). It serves a live graph on a loopback address only.

5. **If every channel is declined,** record it, run the generic path, and say in the report that wiring claims were not machine-checked. An SA reading the bundle should know which kind of evidence they are holding.

## Tier 1 — the wiring cross-check (every run)

This is not a recovery of the system. It is a small model of **what the report claims about wiring**:

- the workers, and the task queue each one polls
- what each worker registers
- the call edges the report asserts — which workflow calls which activity or child, on which queue

Then run `twf check` and `twf graph --json`.

**Model the claim, not your memory of the code.** Write each edge exactly as the report states it, and leave a task queue unset wherever the code leaves it unset. If the report is right, the model checks clean. If it is wrong, `IMPLICIT_ROUTING_MISMATCH` says some call cannot reach a worker that hosts its target. Go back into the code — the answer is usually an override, a default, or a configurator you had not traced — then **fix the report**, and the model with it.

**Size does not gate this tier.** A large repo has more wiring claims, not fewer. Model the ones the report depends on — the focus area's workers and the edges its findings cite — rather than the whole repository.

**Know what the graph answers: how it is wired, never how much it runs.** `twf graph` is a static dispatch-and-containment view. It does not model timers, continue-as-new frequency, fan-out width, or volume. When the review is a cost or optimization question, say so explicitly, so nobody reads a wiring check as a volume check.

The tier-1 model ships as `twf/topology.twf`.

## Tier 2 — behavioral recovery (one bounded slice, experimental)

Recovering workflow *bodies* into `.twf` — control flow, awaits, options, child semantics — is the expensive half. Its test: **will writing the notation surface something that reading the code will not?** On a small slice, committing to exact options and explicit control flow forces precision that prose lets you skip. Across a large multi-slice scope, each slice ends up at partial fidelity and the precision lands only where you already understood. So offer it for **one bounded slice** — a focus area of a few workflows — when the user wants it. Never repo-wide.

Two limits, both observed repeatedly:

- **Structure survives the notation; behavior often does not.** Concurrent fan-out — handlers dispatched in a loop and joined later, or a `promise` declared inside a loop body — can currently be modeled only sequentially, so the model shows a concurrent system as an orderly one, on exactly the mechanisms a review cares about. Mark every such site with a `FIDELITY NOTE`, and keep the report as the source of truth for behavior.
- **An effective value has no in-band form.** Writing a server default into `options:` misstates the call site, and omitting it loses the behavior. Keep it out of the model and carry it in the report as `*(effective: …; unset at call site)*`.

A long `twf-retro.md` is itself a signal: the more the notation fought you, the less the recovery earned. If that happened, say so in the report.

## Writing `.twf` here

- **Read the notation before you write.** On a recovery you already know the semantics; the notation is the only unknown. Run `twf spec --list` and read the sections you need — or, if the `temporal-architect-design` skill is installed, `notation-examples.md`. (That skill's "write before you read the reference docs" advice is for greenfield design, not recovery.)
- **Comments are not accepted inside an `options:` or `default_options:` block** at `v0.14.0`, whether leading or between keys (`expected option key, got COMMENT`). Put provenance comments above the block keyword.
- **If the `temporal-architect-design` skill is installed, follow its reverse path** (`reference/reverse-engineering.md`: slice-mapper → project-discovery → extract → fidelity check). Either way: domain slices are symbols-only, the shared topology is authored once, and fidelity comes first — capture what the code does, and never "fix" it during extraction.
- **Neutral voice inside the model.** Write `# AS FOUND:` with the mechanism and its values; never `ANTI-PATTERN:` or any other verdict. The `.twf` is customer-facing and the map-not-review rule applies to it.
- **A model bug is not a design finding.** If the model misstates the code, fix the model; never report it.

## Outputs

Under `<out>/twf/`, as one flat package — cross-file references resolve only within a shared file set:

| File | Ships to the SA? |
|---|---|
| `topology.twf` — the tier-1 wiring model | **Yes.** It is the one place where worker → registrations → namespace → task queue exists as a single checked structure; reviewers have named it among the most useful files in a bundle. |
| `<slice>.twf` — a tier-2 behavioral model | **Not by default.** First diff the model's comments against `report.md` and fold every fact that exists only in the model into the report. Then list the slice as optional: read without the report, it can give a materially wrong picture of the mechanism under review. |
| `twf-retro.md` — the notation/toolchain reflection | No. Its audience is the toolchain maintainers. |

### Three reflections, three audiences — never merge them

| Artifact | Question it answers | Audience |
|---|---|---|
| `twf/twf-retro.md` | What did the code do that **`.twf` could not express**? | The `temporal-architect` toolchain maintainers |
| `gap-ledger.md` | What could **the reader not determine** about this system? | The SA and the customer's own team |
| *(not in the bundle)* | How well did **this prework skill** perform? | Whoever maintains this skill |

**`twf-retro.md` is about the notation**, not about the system and not about this skill. Each entry: what the code does, its `file:line`, and the construct that was missing or the workaround it forced. A parser bug or a rejected-but-valid construct belongs here with a minimal reproducing probe when you have one — that is the most actionable thing a maintainer can receive. Before it leaves the machine, check it for internal identifiers — ticket IDs in quoted comments, deployed namespace, endpoint and cluster names: it is headed to a different third party than the bundle, possibly a public issue tracker.

Something *the reader* could not determine — hidden deployment wiring, config-driven routing, a service with no source — is a `gap-ledger.md` entry, not a retro entry. Friction with these prework instructions belongs in neither; raise it in conversation if the user asks.

## Visualizer

Whenever a `.twf` model exists, **offer the customer a graph view of it**: `twf-view --open <out>/twf/` serves a live, interactive graph on a loopback address, and editor users can open the extension's visualizer instead. It is for their own exploration — a localhost URL is never a deliverable or a share-manifest entry.
