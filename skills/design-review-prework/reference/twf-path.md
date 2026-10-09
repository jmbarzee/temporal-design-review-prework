# The `twf` toolchain

The temporal-architect toolchain gives this skill the one check prose cannot do for itself: **deterministic validation of wiring** — which worker hosts what, which task queue a call routes to, whether a call can reach a worker at all. Recommend tier 1 on every run; offer tier 2 only for a bounded slice.

## Why it is recommended

Every claim about *where something runs* is an inference from reading code, and nothing else in this skill can check one: the self-consistency and composition passes compare the bundle with itself. In the first real customer run, a bundle **already sent to the SA** attributed an activity to a shared worker's share of execution volume. Modeling that wiring the way the report described it made `twf graph` raise `IMPLICIT_ROUTING_MISMATCH`: the activity's configurator set no task queue, so it ran on each *calling* workflow's queue instead. No number in the bundle was wrong — the attribution was. Across every evaluated run so far, the routing check has caught a real wiring error, a different one each time.

## Two halves

| Half | What it is | Needed? |
|---|---|---|
| **Parser / CLI** — `twf`, one Go binary | `twf check` and `twf graph`: the deterministic validation | **Yes**, for either tier |
| **Visualizer** — `twf-view`, or the editor extension | an interactive graph of a `.twf` model | No. Optional, for the customer's own exploration |

Say so when you make the offer: a customer who declines npm has not declined the toolchain. The binary carries its own grammar reference (`twf spec --list`, `twf spec <slug>`), so the parser alone is enough to write a model; the `temporal-architect` skills help but are not required.

## Phase 0 — confirm, then help install

1. **Check:** `twf --version`.
2. **If it is absent, recommend it with the reason above and offer to help install it** — a confirm-and-assist, not a yes/no that ends the path. Offer the channels in order of how easy they are to audit:

   | Channel | Command | Pulls from |
   |---|---|---|
   | **Go, pinned** — most auditable | `go install github.com/jmbarzee/temporal-architect/tools/lsp/cmd/twf@v0.14.0` | Go module proxy, verified against the Go checksum database; runs no install scripts |
   | Homebrew | `brew install jmbarzee/twf/twf` | the `jmbarzee/twf` tap |
   | PyPI | `pip install twf-cli` | PyPI |
   | Release binary | `curl -sSL https://raw.githubusercontent.com/jmbarzee/temporal-architect-dist/main/packages/install.sh \| bash` | GitHub release assets |
   | npm | `npx -y @temporal-architect/twf` | npm, including package install scripts |

   Use the newest `tools/lsp/vX.Y.Z` tag in place of `v0.14.0`: `git ls-remote --tags https://github.com/jmbarzee/temporal-architect | grep tools/lsp/`. Go 1.25 or newer is needed for the `go install` route.

3. **If the customer wants to audit first, help.** The source is public and MIT-licensed; from a checkout at the pinned tag, the parser's network and process-execution surface checks in seconds:

   ```bash
   grep -rln --include='*.go' -e '"os/exec"' -e '"net"' -e '"net/http"' tools/lsp | grep -v _test.go
   ```

   At `v0.14.0` it returns nothing. Point them at the check rather than asserting the result.

4. **Offer the visualizer as a separate choice:** `go install github.com/jmbarzee/temporal-architect-dist/packages/twf-view@latest` (an auditing customer pins a commit, `@<sha>`). It serves a live graph on a loopback address only.

## Tier 1 — the wiring cross-check (every run)

Not a recovery of behavior: a small model of **what the report claims about wiring**, in which **the calls do the work**.

**Its scope is the review's** — every domain confirmed at the Phase 3 gate that the report treats beyond an inventory row, reduced-depth domains included. Only the user narrows it: ask, and record the answer. If the toolchain arrives after the bundle is written, the model checks the report as it stands. It holds:

- the workers, and the task queue each one polls
- what each worker registers
- a **dispatch skeleton** for each workflow in scope: a body holding only its outgoing calls, in order — `activity`, child `workflow`, `nexus`, signal sends — with each task-queue option exactly as the code sets it, and unset where the code leaves it unset

**Without the skeleton the model is hollow, and checks clean however wrong the wiring is.** A call edge exists only as a statement inside a workflow body, so workers and registrations alone give `twf graph` nothing to route. The same misattributed activity passes clean in a registration-only model and raises `IMPLICIT_ROUTING_MISMATCH` once the caller's body holds the one `activity` line the code makes. Control-flow fidelity is tier 2; every call the report's findings depend on is tier 1.

To write a call, its target must be defined. When a call targets something you will not otherwise model, give it a one-line stub definition and register it where the report says it runs: that registration *is* the claim under test. An unwritten call is an unchecked one.

**Trees deepen only through workflow-to-workflow edges** — child workflows, Nexus operations, signals; activities are leaves. A model with none is correct only if the code has none, so the skeleton carries them:

- **Never flatten a child workflow into an activity stub**, even a convenient one. A comment saying "falls back to a child workflow" means the model needs a `workflow` call there.
- **Never let one workflow stand in for a domain.** An out-of-focus domain may get stub bodies, but each workflow an edge reaches is defined under its own name and keeps its own outgoing workflow edges. A stand-in collapses exactly the coupling the graph exists to show, and a reader of the visualizer cannot see the `#` comment that admits it.

Then run `twf check` and `twf graph`, and **check the model's shape**, which a clean `twf check` cannot tell you:

```bash
twf graph --json twf/ | jq -r -f scripts/twf_model_shape.jq
```

It reports three things:

| Line | Meaning | What to do |
|---|---|---|
| **cross-workflow edges**, by kind | Edges between workflows: child calls, signals, Nexus calls | Reconcile against the scan (below). Zero against a nonzero scan means the model has flattened the system. |
| **call depth 0** for a workflow in scope | Hollow: no calls modeled, so the routing check tested nothing | Add its dispatch skeleton. (A `0` that comes with a routing diagnostic is the check working: the call exists but cannot reach its target.) |
| **a registered activity nothing calls** | A wiring claim the model does not test | Call it from the workflows the report says use it — or say plainly that this claim is unchecked. |

**Reconcile the edges against the code.** `scan_temporal.sh` counts cross-workflow call sites and lists them, `file:line`, for each focus path — pass it every path in scope. Every site in scope, and every one the report cites, lands in exactly one place: an edge in the model, or a row in the report's **edges the graph omits** list — kind, source and target workflow, `file:line` — placed beside any mention of the graph, so nobody reads the graph as the complete coupling. These are the sites `.twf` cannot express yet:

| In the code | Why the graph cannot show it |
|---|---|
| a signal to a workflow the caller did not start, addressed by ID | a `signal` send goes only through the handle of a child the sender started |
| a workflow started, signalled, updated or awaited from an activity | activity bodies hold no workflow calls |
| an update or cancel sent to another workflow | no cross-workflow update or cancel form |

A client start from a process entry point — a CLI, an HTTP or webhook handler — is a trigger, not an edge: it belongs in the workflow inventory, not the omitted list.

**Model the claim, not your memory of the code.** Write each edge exactly as the report states it, and leave a task queue unset wherever the code leaves it unset. If the report is right, the model checks clean. If it is wrong, `IMPLICIT_ROUTING_MISMATCH` says some call cannot reach a worker that hosts its target. Go back into the code — the answer is usually an override, a default, or a configurator you had not traced — then **fix the report**, and the model with it.

**Size does not gate this tier.** A large repo has more wiring claims, not fewer; the model stays bounded by the review's scope.

**The graph answers how it is wired, never how much it runs.** It models no timers, continue-as-new frequency, fan-out width, or volume. In a cost or optimization review, say so, so nobody reads a wiring check as a volume check.

The tier-1 model — topology plus the dispatch skeletons — ships as `twf/topology.twf`.

## Tier 2 — behavioral recovery (one bounded slice, experimental)

Recovering workflow *bodies* — control flow, awaits, options, child semantics — is the expensive half. Its test: **will writing the notation surface something reading the code will not?** On a small slice, committing to exact options forces precision prose lets you skip; across a large scope, every slice lands at partial fidelity and the precision only where you already understood. So: **one bounded slice** of a few workflows, when the user wants it, never repo-wide.

Two limits, both observed repeatedly:

- **Structure survives the notation; behavior often does not.** Concurrent fan-out — handlers dispatched in a loop and joined later, or a `promise` declared inside a loop body — can currently be modeled only sequentially, so the model shows a concurrent system as an orderly one, on exactly the mechanisms a review cares about. Mark every such site with a `FIDELITY NOTE`, and keep the report as the source of truth for behavior.
- **An effective value has no in-band form.** Writing a server default into `options:` misstates the call site, and omitting it loses the behavior. Keep it out of the model and carry it in the report as `*(effective: …; unset at call site)*`.

A long `twf-retro.md` is itself a signal: the more the notation fought you, the less the recovery earned. If that happened, say so in the report.

## Writing `.twf` here

- **Read the notation before you write** — on a recovery it is the only unknown. Run `twf spec --list` and read the sections you need, or the `temporal-architect-design` skill's `notation-examples.md` if installed. (That skill's "write before you read" advice is for greenfield design.)
- **Comments are not accepted inside an `options:` or `default_options:` block** through `v0.14.0`, whether leading or between keys (`expected option key, got COMMENT`). Put provenance comments above the block keyword.
- **If the `temporal-architect-design` skill is installed, follow its reverse path** (`reference/reverse-engineering.md`). Either way, workers and namespaces are declared once, in `topology.twf`, and domain files declare none (the design skill's "symbols-only" — not stub bodies or one representative per domain). Capture what the code does; never "fix" it during extraction.
- **Neutral voice inside the model.** The `.twf` is customer-facing: write `# AS FOUND:` with the mechanism and its values, never `ANTI-PATTERN:` or any other verdict.
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
| *(not in the bundle; raise in conversation if the user asks)* | How well did **this prework skill** perform? | Whoever maintains this skill |

**`twf-retro.md` is about the notation**, not about the system and not about this skill. Each entry: what the code does, its `file:line`, and the construct that was missing or the workaround it forced. A parser bug or a rejected-but-valid construct belongs here with a minimal reproducing probe when you have one — that is the most actionable thing a maintainer can receive. Before it leaves the machine, check it for internal identifiers — ticket IDs in quoted comments, deployed namespace, endpoint and cluster names: it is headed to a different third party than the bundle, possibly a public issue tracker.
