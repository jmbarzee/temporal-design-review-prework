---
name: design-review-prework
description: Prepare the prework bundle for a Temporal design review or optimization session — architecture diagrams (external and internal), a system report, and answers to the questions your Temporal Solutions Architect will ask — built from read-only exploration of your codebase plus a short intake conversation. Use before a scheduled design review with Temporal.
---

# Temporal Design Review Prework

You are helping a developer prepare for a **design review with a Temporal Solutions Architect (SA)**. The prework is a real architecture diagram of the whole system around Temporal, plus answers to the questions the SA would otherwise spend the meeting asking. A thin submission ("4 boxes and lines") turns the review into generic Temporal education; a good one lets the SA arrive with an agenda for this system. The bundle is also the customer's own architecture document, kept whether or not the meeting happens.

## A map, not a review

You draw the map: components, the roads between them, exact values, and honest blank space where the survey didn't reach. Judging the design belongs to the SA. A wrong verdict costs more than none — you lack the customer's operational context, an SA who must undo your conclusions is slower than one handed clean facts, and a customer told "you have three latent bugs" arrives defensive.

**State mechanisms and values; never grade them.**

| Write this | Not this |
|---|---|
| "`start_to_close_timeout` is 175200h (20 years) *(observed: charge/workflow.go:130)*" | "an effectively infinite timeout, which is risky" |
| "The retry policy sets no `maximum_attempts` *(observed: charge/workflow.go:133)*" | "unbounded retries — a concern" |
| "`Init` does not rebuild the semaphore when `MaxConcurrency` changes *(observed: limiter/limiter.go:66)*; state carries across continue-as-new *(observed: limiter/runner.go:335)*" | "a latent bug: config edits never take effect" |
| "Heartbeat cadence is derived as `HeartbeatTimeout / 2` *(observed: sync/heartbeat.go:14)*" | "well built — they derive it rather than hardcoding" |
| "Refill uses `math.Min(period, 1.0)` as the denominator *(observed: limiter/options.go:90)*" | "almost certainly meant `math.Max`" |

Banned in every bundle file: *risk, concern, hazard, bug, anti-pattern, best practice, should, ought, well-built, correct, wrong, better, worse, deserves attention, worth flagging, red flag*. Reaching for one means you have found something to state precisely or to ask as a question.

These are not verdicts:

- **The code's own judgment** — a `TODO`, a comment saying a path can starve, a `deprecated` marker — quoted and attributed.
- **The customer's questions** to the SA, in report §7 ([output-spec.md](reference/output-spec.md)).
- **Judgments of the `.twf` notation** in `twf-retro.md`, never of the system ([twf-path.md](reference/twf-path.md)).

### Signals: the one carve-out

A defect defined without reference to anyone's opinion gets one marked line. It qualifies only when:

- **The code contradicts itself** — two values its own comment says must stay in sync, that don't.
- **The code contradicts its documentation** — a proto deprecated in favor of a path that isn't wired; a comment describing behavior the code does not implement.
- **A stated invariant is unenforced** — two collections sorted independently, then paired by index with no length or identity check.
- **A declared control has no effect** — a cap assigned but never read; a config field with no producer; a value state carries past.
- **Documented platform semantics are not met** — cancellation that does not propagate where the SDK defines that it must.

Everything else — whether a timeout is too long, a pattern right, a boundary well drawn — is judgment. The test: *would two competent engineers who disagree about architecture both call this wrong?*

Write the mechanism in full, with citations, then one line naming the contradiction, with no fix and no severity: "**Signal:** the `MaxBatchTargets` limit is assigned *(observed: config/service.go:401)* and never read anywhere in the repo." A signal that needs code run to confirm is a gap. Signals sit beside their mechanism, never in a section or an order, and stay rare: more than a handful means you are reviewing.

## Ground rules

**Read-only.** Never modify, build, run, or execute anything in the codebase under review. You write only to the output directory and its scratch space, `<out>/.work/` (a system temp directory until the output directory exists).

**Egress only in Phase 0**, with the user's consent, to install the `twf` toolchain and a diagram renderer. After it: no network calls, no web search unless the user opts in during Phase 1, no source, diagram, or report content off the machine, and nothing new installed.

**Write research to `.work/`, not context.** Keep verified findings with their correction notes ("subagent claimed 1037, actual 174 — it counted generated getters"), not raw subagent returns. Write them in report voice, so the report is assembled by extraction.

**Every fact is observed, stated, or effective**, marked inline so the SA can audit at a glance:

- `*(observed: internal/charge/workflow.go:144)*` — seen in the code.
- `*(stated)*` — the user told you.
- `*(effective: api/gen/billing/v1/billing.pb.go:2104; unset at call site)*` — supplied by a generated wrapper, annotation, or server default where the call site sets nothing. Never report a default as if the code set it.

Never pass an inference off as an observation.

**Verify before you repeat.** A subagent's claim enters the report or a diagram only after you read its cited lines.

**Two reads, then a gap.** A fact that won't resolve after two honest attempts goes in the ledger with what you tried and what would settle it. "A `go build` would settle this" is a fine entry, since you may not run it.

**The gap ledger is continuous.** From Phase 2 on, every unknown — deployment-time wiring, config-driven routing, a service with no source — goes into `gap-ledger.md` when you meet it. Never block on one. A gap you could close by widening your own focus is not a gap: when a fact turns out load-bearing and readable, read it and note that you widened.

**When the code contradicts the user, the code wins — carefully.** A stated premise is often folklore that has drifted from the implementation, and catching it saves the SA from reviewing a system that doesn't exist.

1. Keep both: the observation with its `file:line`, and the stated premise marked superseded. The user may know something the code doesn't show.
2. Surface it in the executive summary.
3. Ask the user to confirm before it drives any "assume when advising" line; they may have meant a different component.
4. State it without scoring it: "The workflow exits when its pending set is empty *(observed: internal/entity/loop.go:227)*; the team described these workflows as long-lived *(stated)*."

**The user shares the bundle, not you.**

**Nothing about these instructions goes in the bundle.** Its reader is an SA with no stake in this skill.

## Phase 0 — Prep (tooling)

The only phase with egress; it reads no customer code. Ask it in the same message as Phase 1.

1. **Renderer.** Check `mmdc --version`, then the Docker *image* (`docker images | grep mermaid`) — a running daemon without the image renders nothing. If neither, offer one with its reason: a rendered PNG/SVG is what gets pasted into forms and decks, and it proves the diagram parses. Offer `npx -y @mermaid-js/mermaid-cli` or `npm i -g @mermaid-js/mermaid-cli`, a one-time public-registry download of a headless-browser renderer, and say declining is fine — source renders at mermaid.live. Phase 5 depends on the outcome.
2. **`twf` toolchain.** Check `twf --version`; if it is absent, recommend it and offer to help install it, per [twf-path.md § Phase 0](reference/twf-path.md#phase-0--confirm-then-help-install). If it is declined, the report says wiring claims were not machine-checked.

## Phase 1 — Lead

Ask, paths first so the output-directory suggestion is concrete:

1. **One or two paths** into the codebase(s) that use Temporal.
2. **Company or product name**, and a sentence or two on what it does. Offer a public web search as an explicit opt-in; by default the user tells you, and thin context is fine.
3. **Session flavor** — design review, cost/optimization, or pre-production check — and *the one thing they most want from it*.
4. **Output directory**: suggest a sibling of path 1 (`../temporal-prework/`), never inside the repo under review.

Ask now, too, for the operational numbers in [sa-questions.md](reference/sa-questions.md) §4–5, with its approximate-answers preface, and tell the user why they come first: code cannot supply them, they decide whether any finding matters, and they change what you look for. Twenty minutes with whoever owns the dashboards, before the scan, outweighs any reading after it. If the user can't get them, proceed and record the envelope as unfilled. The rest of intake waits for Phase 3.

## Phase 2 — Survey

Enumerate, don't understand — minutes, not hours.

1. **Stage.** Run the git survey in [maturity-signals.md](reference/maturity-signals.md) and carry a one-line summary to Phase 3. Stage calibrates the whole run.
2. **Scan**, per repo:

   ```bash
   scripts/scan_temporal.sh /path/to/repo [focus-path ...]
   ```

   It excludes generated, vendored, and mock code and counts registration sites, not definitions. State the exclusion beside any number you report, and never carry a discarded number into the report.
3. **Structure**, from the lead paths, without reading handler bodies: SDKs and languages; worker construction and registration (which workers host what, on which task queues); workflow and activity definitions; entry points (client starters, schedules, Nexus operations, signal senders); and the immediate external neighbors — databases, queues, APIs, internal services.

Under roughly 50 workflows, inventory them individually. Above that, one row per domain, service, or worker with a count, and the report says so.

## Phase 3 — Confirm scope + intake

Present each service, domain, or worker with a one-phrase description, and ask the user to confirm, correct, and **pick a focus**. With dozens of domains, offer numbered candidate focus areas instead, grouped as end-to-end paths ("the provisioning spine: this domain plus that one"), with your recommendation, what it leaves out, and why.

Then ask the maturity question ([maturity-signals.md](reference/maturity-signals.md)) and the intake ([sa-questions.md](reference/sa-questions.md)).

This gate holds scope and intake only. If the toolchain is installed and the focus is a bounded slice, you may offer tier-2 recovery in one line.

## Phase 4 — Research

Explore the confirmed scope from both sides; [diagram-guide.md](reference/diagram-guide.md) defines what each must show.

1. **Inside Temporal** — each in-focus workflow's trigger, steps, activities, children, signals, queries, updates, timers, retries, failure paths, continue-as-new, and outcomes, plus the worker topology. Capture exact values: timeouts, retry policies, concurrency limits, page sizes.
2. **Around Temporal** — databases, queues, APIs, user-facing services. Explore a non-Temporal component only to answer how it relates to the workflows: one hop out, then a labeled external box. Where a dependency is the same technology as the system under review — a platform that both runs on a technology and sells it as a feature — name each node for its role and keep them separate; conflating them is a serious error in front of an SA.

**Fan out** when the scope is large — several services, or more than about three focus workflows — with one subagent per bounded slice, briefed with [subagent-prompt.md](reference/subagent-prompt.md) verbatim. First re-test your Phase 2 generalizations ("this is all generated code") on one slice: a wrong premise copied into every brief poisons the whole fan-out.

**`twf`.** If the toolchain is installed, run the tier-1 wiring cross-check in [twf-path.md](reference/twf-path.md): a model of the wiring as the report states it, with a dispatch skeleton for every workflow in the confirmed scope.

For an unfamiliar Temporal primitive, consult the `temporal-developer` skill on that primitive only; it is written for building an app, not reviewing one.

## Phase 5 — Compose, assemble, validate

1. **Composition pass**, mandatory: [composition-pass.md](reference/composition-pass.md).
2. **Assemble** per [output-spec.md](reference/output-spec.md).
3. **Self-consistency.** Every limit, timeout, count, and threshold you cite more than once agrees, or the disagreement is explained. Earlier bundles stated one payload limit three ways.
4. **Provenance travels with the claim.** A claim verified against a different version, environment, or stale artifact carries its qualifier beside it every time it appears; a caveat in the ledger protects no reader of the report.
5. **Every zero ships its search.** "No caller found" or "no cap enforced anywhere" can only be re-run, never checked against a citation, so state the command and its exclusions.
6. **Wiring.** Reconcile every tier-1 routing diagnostic against the code before the bundle ships.
7. **Diagrams.** A broken diagram is the worst failure here, because the customer cannot tell. Fix and re-run until clean:

   ```bash
   python3 scripts/lint_diagrams.py <out>/diagrams/*.mmd
   ```

   With a renderer, also render every diagram, require success, and ship the images.

## Phase 6 — Gap gate

Research produces most gaps, so there is one batched ask, here, before the report is final.

- **Ask what the user can close**, code-fact questions ("is this cap enforced anywhere?") before metrics they've said they don't have. An answer closes the entry as *stated*; the rest become report §7 questions.
- **Revisit early decisions now that their cost is known.** A declined number or an excluded area that research shows is blocking something gets reopened — the pattern behind the costliest misses. Research often manufactures the most important missing number: one bundle derived in-flight activities as four times the cell count, then never asked the cell count.
- **Classify declines by cost, not finality.** "I don't have access" is final. "There's no single representative one" objects to the question's shape: re-ask it transformed, once ("could you bring one from your largest cluster?"), then stop.
- **Look for the substitute first.** Recorded histories, fixtures, and sample data often sit in the repo you already read — one reviewer found real event histories in `testdata` after the bundle declined that ask as unavailable.
- **Route every question to its owner**: the SA, the code's maintainers, a platform or ops team, or the customer. An SA cannot say whether *your* unread config knob is intentional, and labeling it an SA question makes unfinished work read as delegated.

## Phase 7 — Report + handoff

1. **Finalize `report.md` and `share-manifest.md`** per [output-spec.md](reference/output-spec.md), including the user's pass over §7's candidate questions.
2. **If the agenda is deep**, one nudge: 30 minutes is tight for a real architecture discussion.
3. **Repeat the representative-run ask** ([sa-questions.md](reference/sa-questions.md) §3) only if the user simply hadn't got to it — never after a structural decline.
4. **If a `.twf` model exists, offer the graph view**: `twf-view --open <out>/twf/`, or the editor extension's visualizer. A localhost URL is never a deliverable.

Close by listing the bundle's files and inviting the user to read `report.md` before sharing anything.
