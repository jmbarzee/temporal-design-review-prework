# Diagram guide

The bar: an SA seeing these diagrams for the first time can locate cost, risk, and scale bottlenecks *without asking what the boxes mean*. "4 boxes and lines" fails that bar and can get a review cancelled outright.

Two diagram types are required. They answer different questions; never merge them.

Every diagram must pass `scripts/lint_diagrams.py` (Phase 5), which checks the rules below. **Declare the role on the first line** — `%% role: topology` or `%% role: workflow`. The node cap depends on it, not on the filename.

## Mermaid safe subset

- **Quote every node label.** `api["Order API"]`, never `api[Order API]`. An unquoted label containing a comma, colon, parenthesis, slash, or a line break **fails to parse**, and you will not see the failure without a renderer.
- **Line breaks inside labels use `<br/>`**, inside the quotes: `w1["billing-worker<br/>K8s, 3 replicas"]`. Never a literal newline in a label.
- **Never use HTML entities** (`&lt;`, `&gt;`, `&amp;`). They render literally as `&lt;`. Write a plain word instead: `"WF ID = temporal-sys-scheduler-ID"`, not `"...:&lt;id&gt;"`.
- **Quote every edge label:** `a -- "starts ChargeOrder" --> b`. An unlabeled edge is a question the SA has to ask — if you cannot label it, that is a gap-ledger entry, not a bare arrow.

## The legend must be in the canvas, not in a comment

Comments vanish in the rendered PNG, which is what gets pasted into forms and decks. Put the legend in the diagram as a subgraph of shape samples:

```mermaid
flowchart LR
  subgraph legend ["Legend"]
    l1["activity"]
    l2[["child workflow"]]
    l3{{"signal / timer"}}
    l4(["start / end"])
  end
```

A `sequenceDiagram` cannot contain a `subgraph`, so it uses a note:

```mermaid
sequenceDiagram
    Note over A,B: Legend - solid = call, dashed = poll result
```

Comments still carry provenance (source paths, date).

## Diagram 1 — External architecture (exactly one)

*The system around Temporal.* Answers: where does Temporal sit, what feeds it, what does it call, where could cost, latency, or risk originate?

Must show:
- **Every workflow trigger source** (user-facing service, API, schedule/cron, event or queue consumer)
- **Worker topology:** each worker deployment as its own box, labeled with its task queue(s) and where it runs
- **Temporal itself** as one clearly-marked box — label Cloud or self-hosted
- **Every external system touched by activities**, each labeled with *what it is* ("Postgres — order state", "Stripe API"), never bare "DB"
- **Direction and a verb on every edge** ("starts workflow", "polls task queue", "writes manifest to S3")

Use `flowchart LR` with subgraphs for *your services*, *Temporal*, *workers*, and *external dependencies*.

**Hard cap: 25 nodes** — real components only; subgraph containers and legend samples don't count. Over it, split into `external-architecture-<domain>.mmd` per domain rather than compressing real systems into grouped nodes; an unreadable diagram is a missing diagram. A group node that remains names its members and counts as one node.

## Diagram 2 — Internal workflow shape (one per in-focus workflow *or family*)

*The shape of the orchestration.* Answers: what are the steps, where are the waits, what happens on failure?

Must show, for that workflow: the trigger; major steps in order; each **activity**; **child workflows**; **signals/updates/queries** arriving from outside; **timers and waits**; **retry behavior** where it is deliberate; **failure paths** (compensation, saga rollback, terminal failure); **continue-as-new** if present; the final outcome(s). Draw failure paths as real edges, never a footnote.

Use `flowchart TD`, or a sequence diagram when inter-service back-and-forth is the point.

**Workflow families get one diagram, not one each.** When several workflows form a single chain (a parent plus children whose *inter-workflow* relationships — ParentClosePolicy, await-start-vs-await-result — are the point), draw the family as one diagram named for the family: `<family>-internal.mmd`. Splitting it destroys the very relationship worth reviewing.

**Internal and family diagrams are exempt from the 25-node cap**, and dense labels are welcome: exact timeouts and policy values in the node serve an SA better than a clean diagram that omits them. Past ~40 nodes, reconsider.

## Labels describe; the ledger holds doubt

Labels carry names, roles, and exact values: `"BatchActivity<br/>start_to_close 20 years, retry unbounded"`, never `"BatchActivity (risky timeout!)"`. No warning icons, no red-for-bad, no "⚠" — color and shape distinguish only *kinds* of thing, as the legend declares.

A component you inferred but could not verify gets a gap-ledger entry, not a dashed border or a `?`; the ledger carries the reason and what would close it, which a dashed line cannot.
