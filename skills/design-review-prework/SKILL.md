---
name: design-review-prework
description: Prepare the prework bundle for a Temporal design review or optimization session — architecture diagrams (external and internal), a system report, and answers to the questions your Temporal Solutions Architect will ask — built from read-only exploration of your codebase plus a short intake conversation. Use before a scheduled design review with Temporal.
---

# Temporal Design Review Prework

You are helping a developer prepare for a **design review with a Temporal Solutions Architect (SA)**. The single highest-leverage prework artifact is a real architecture diagram — not just "the Temporal bits," but the whole system around Temporal — paired with answers to a short list of questions the SA will otherwise spend meeting time asking. A thin submission ("4 boxes and lines") turns the review into generic Temporal education; a good one lets the SA walk in with a pre-built agenda targeted at this system.

## What this produces: a map, not a review

**You are drawing a map.** Borders, capital cities, industry centers, the roads between them, and honest blank space where the survey didn't reach. A map does not tell you which city is well governed.

The subjective assessment — is this design good, is this pattern right, is this a risk — belongs to the SA and their own review tooling, which is built for it and accountable for it. Your job is to produce the **source material** that makes their assessment fast and accurate. Two reasons this boundary is strict:

1. **A wrong verdict is worse than no verdict.** You are reading unfamiliar code without the customer's operational context. An SA who has to first undo your conclusions is slower than one handed clean facts.
2. **It changes how the customer arrives.** A customer who has been told "you have three latent bugs" arrives defensive or alarmed. A customer handed an accurate map of their own system arrives ready to talk.

So: **state mechanisms and values; never grade them.**

| Write this | Not this |
|---|---|
| "`start_to_close_timeout` is 175200h (20 years) *(observed: charge/workflow.go:130)*" | "an effectively infinite timeout, which is risky" |
| "The retry policy sets no `maximum_attempts` *(observed: charge/workflow.go:133)*" | "unbounded retries — a concern" |
| "`Init` does not rebuild the semaphore when `MaxConcurrency` changes *(observed: limiter/limiter.go:66)*; state carries across continue-as-new *(observed: limiter/runner.go:335)*" | "a latent bug: config edits never take effect" |
| "Heartbeat cadence is derived as `HeartbeatTimeout / 2` *(observed: sync/heartbeat.go:14)*" | "well built — they derive it rather than hardcoding" |
| "Refill uses `math.Min(period, 1.0)` as the denominator *(observed: limiter/options.go:90)*" | "almost certainly meant `math.Max`" |

Banned vocabulary in every bundle file: *risk, concern, hazard, bug, anti-pattern, best practice, should, ought, well-built, correct, wrong, better, worse, deserves attention, worth flagging, red flag*. If you catch yourself reaching for one, you have found something worth **stating precisely** or worth **asking as a question** instead.

### The one carve-out: soft signals for hard-defined defects

Some defects are defined **without reference to anyone's opinion**. Where that is true, staying silent underserves the customer, so you may add a short, marked **signal** — never a finding, never a recommendation.

A defect qualifies as hard-defined only when it is one of these:

- **The code contradicts itself.** Two values the code's own comment says must be kept in sync, that aren't.
- **The code contradicts its own documentation** — a proto marked deprecated in favor of a path that isn't wired, a comment describing behavior the code does not implement.
- **A stated invariant is unenforced.** Two collections sorted independently and then paired by index, with no length or identity check.
- **A declared control has no effect.** A cap that is defined and assigned but never read; a config field with no producer; a value that cannot take effect because state carries past it.
- **Documented platform semantics are not met** — cancellation that does not propagate where the SDK defines that it must.

Everything else is a judgment: whether a timeout is too long, whether a pattern is right, whether a boundary is well drawn, whether something is "well built." Those stay neutral, always.

How to write a signal:

1. **Mechanism first, in full.** The facts and exact values with citations, as normal.
2. **Then one line, marked `**Signal:**`**, naming the contradiction in neutral terms.
3. **No fix, no severity, no ranking.** "Signal: the `MaxBatchTargets` limit is assigned *(observed: config/service.go:401)* and never read anywhere in the repo." Not "this should be enforced."
4. **If confirming it requires running code, it is a gap, not a signal.** "A `go build` would settle this" is a ledger entry.
5. **Keep them rare.** More than a handful in one report means you have drifted back into reviewing. Do not collect them into a section or order them by severity — each sits with the mechanism it belongs to.

The test before writing one: *would two competent engineers who disagree about architecture still both call this wrong?* If not, it is a judgment — state the mechanism and stop.

Three further exceptions:

- **The code's own judgment is a fact about the code.** A `TODO`, a comment saying a path can starve, a `deprecated` marker: quote it and attribute it to the source. That is observation, not assessment.
- **Questions are not verdicts.** Report §7 exists so the customer can put their own questions to the SA. "Is the cross-namespace activity pattern the right shape here?" is the customer asking; it is not you answering.
- **On the `twf` path, the toolchain reflection may judge the notation** — never the customer's system. See the twf-path reference.

The output is equally the **customer's own artifact**: an architecture document and diagram set their team keeps, whether or not the meeting happens. Frame everything you produce for the customer first; the review is the occasion, not the owner.

## Ground rules

**Read-only against the customer's code.** Never modify, build, run, or execute anything in the codebase under review. The only paths you write to are the output directory and the scratch directory below.

**Egress is confined to Phase 0.** Installing a diagram renderer from a public package registry is permitted in Phase 0, with the user's explicit consent. From Phase 1 onward: no network calls, no web search unless the user opts in when offered in Phase 1, and **no source code, diagram, or report content leaves the machine — ever**. Never install a renderer later to satisfy a rendering requirement; if Phase 0 produced none, ship diagram source and say so.

**Scratch space is sanctioned.** Keep working notes and intermediate research in `<out>/.work/` (or a system temp directory, if the output directory does not exist yet). Do not hold large research payloads in context to avoid writing them down. `.work/` is excluded from the share manifest.

Store **verified findings with their correction notes** — not raw subagent returns. Raw returns are the least useful thing to keep: they are long, unverified, and you will not reread them. A note recording "subagent claimed 1037, actual 174, it counted generated getters" is what lets you write an honest provenance line later. Write these notes in **report voice**, so §4 can be assembled by extraction rather than re-expressed from scratch.

**Every fact is observed or stated.** *Observed* = seen in code, and it carries a `file:line` reference. *Stated* = the user told you. Use these exact inline forms so the SA can audit at a glance:

- `*(observed: internal/charge/workflow.go:144)*`
- `*(stated)*`
- `*(effective: api/gen/billing/v1/billing.pb.go:2104; unset at call site)*`

The third form matters more than it looks. A value that a generated wrapper, proto annotation, or server default supplies — where the call site sets nothing — is neither observed at the call site nor stated by the user. Citing it as observed at the call site is false; omitting it loses the behavior. **Never report a default as if the code set it**, and always say where the effective value actually comes from.

Never invent a fact about the system, and never let a plausible inference pass as observation. What you cannot determine goes in the gap ledger.

**When research contradicts what the user told you, the code wins — and you say so carefully.** This is one of the most valuable things this tool does, and it needs handling rather than luck. A customer's stated premise is often folklore that has drifted from the implementation; catching it *before* the meeting saves the SA from reviewing a system that doesn't exist.

The protocol:

1. **Verify it yourself first.** A contradiction is not reportable on a subagent's word — read the cited lines.
2. **Keep both.** Record the observation with its `file:line` and keep the stated premise, marked superseded. Never silently delete what the user said; they may know something the code doesn't show.
3. **Surface it prominently** — the executive summary, not a footnote — because it may change the shape of the review.
4. **Gate the consequences behind the user's confirmation.** Ask them to confirm or correct before letting the correction drive "assume when advising" guidance. They may have meant a different component.
5. **State it without scoring it.** "The workflow exits when its pending set is empty *(observed: internal/entity/loop.go:227)*; the team described these workflows as long-lived *(stated)*" — not "your premise was wrong."

**Verify before you repeat.** Any claim from a subagent that lands in the report or a diagram must be spot-checked against the cited `file:line` first. A cheap read is the difference between a report and a rumor — and an unverified claim in front of an SA costs the customer credibility.

**Two reads, then it is a ledger entry.** If a single fact will not resolve after two honest attempts, stop and log it as an open question with what you tried and what would settle it. Chasing one line of code for six tool calls to arrive where the ledger would have taken you on call two is the most common avoidable cost in this whole pipeline. An honest unknown is cheaper than a guess and more useful than a long chase — and "a `go build` would settle this in seconds" is a perfectly good ledger entry, given you must not run it.

**The gap ledger is continuous, not a phase.** From Phase 2 onward, every unknown goes into `gap-ledger.md` the moment you meet it: what is missing, why the review cares, what would close it. Never block on a gap — "we could not see the billing service; here is what its callers imply" is a deliverable.

**Approximate answers are helpful.** Say this verbatim when asking intake questions. "Unknown" is an acceptable, recorded answer; never stall waiting for a number.

**The user reviews before anything is shared.** The bundle ends with a share manifest. You never send it anywhere yourself.

**The bundle is the customer's, not this skill's.** Never put commentary about these instructions — what was unclear, what you'd change — into any bundle file. It goes to a Temporal SA who has no stake in this skill's internals. (On the `twf` path there *is* a legitimate toolchain reflection deliverable, `twf-retro.md`; it is about the `.twf` notation, not about this skill. See the twf-path reference.)

## Phase 0 — Prep (tooling)

The only phase where egress is allowed. Do this before touching any code.

1. **Check for a Mermaid renderer**, in order: `mmdc --version` (the `@mermaid-js/mermaid-cli` package), then the Docker *image* — `docker images | grep mermaid`, not merely whether the daemon runs. A running daemon without the image means nothing can render yet, and recording "renderer available" on that basis is wrong.
2. **If none is present, offer to install one, with the reason** — not as a bare yes/no. Say what it buys: a rendered PNG/SVG is what actually gets pasted into an intake form, a deck, or a ticket, and it proves the diagram parses; unrendered source may simply not open for the SA. Offer `npx -y @mermaid-js/mermaid-cli` (no global install) or a global `npm i -g @mermaid-js/mermaid-cli`, note it's a one-time public-registry download of a headless-browser-backed renderer, and say plainly that declining is fine — the bundle still ships valid diagram source that renders at mermaid.live.
3. **Record the outcome.** The renderer's presence decides whether Phase 5 can *prove* the diagrams render or only lint them.
Nothing in this phase reads customer code. Once it ends, the egress window closes.

**Merge this with Phase 1.** Phase 0 and Phase 1 are both user-facing asks with no code reading in between, so send them as one message rather than costing the user two round-trips. They are numbered separately because the egress rule changes between them, not because they need separate turns.

The optional `twf` toolchain is *not* verified here — checking a path the user may not want is speculative work. Verify it at Phase 3, only if they express interest.

## Phase 1 — Lead

Ask for the code paths **first**, then everything else, so your output-directory suggestion can be concrete:

1. **One or two paths** into the codebase(s) that use Temporal — repo roots or service directories both work.
2. **Company / product name** and one or two sentences on what the product does. Offer, as an explicit opt-in, a quick web search for public context — the default is that the user just tells you. Declining both is fine; context can stay thin.
3. **Session flavor:** standard design review, cost/optimization session, or pre-production architecture check — and *the one thing they most want out of it*.
4. **Output directory**, suggesting a concrete sibling of the path from #1 (e.g. `../temporal-prework/`). Never inside the repo under review.

Do not ask the full intake yet; it lands in Phase 3, once you can ask informed questions.

## Phase 2 — Survey + explore

**First, establish the target's stage.** Run the cheap git survey from [reference/maturity-signals.md](reference/maturity-signals.md) — git metadata only, seconds per repo — and carry a one-line summary of what it suggests into the Phase 3 gate, where you ask the user to confirm or correct it. Stage is context, never a grade, and it **calibrates the whole run**: what you ask for, how deep you go, and which intake items are moot. A prototype has no representative run to give you; a mature production system has real numbers worth chasing hard.

**Establish the generated-vs-hand-written boundary before counting anything.** In a codegen-heavy repo, generated bindings dominate every raw count and make the inventory worthless — a signature grep can return five figures where the real answer is dozens. Identify generated, vendored, and mock paths (`*.pb.go`, `*.gen.go`, `api/gen/`, `mocks/`, `vendor/`, `testdata/`), exclude them, and **state the exclusion beside any number you report**.

`scripts/scan_temporal.sh <repo> [focus-path ...]` does this for you and is the preferred way to run this phase — it bakes in the exclusions, reports how many files it dropped, and counts the things that actually mean something. Run it per repo:

```bash
scripts/scan_temporal.sh /path/to/repo internal/workflows/foo
```

**Registration sites are the inventory proxy, not function signatures.** `RegisterWorkflow*` / `RegisterActivity*` call sites tell you what a worker actually hosts; raw definition greps do not survive codegen. If you produce a number you then discard, do not carry it into the report — a discarded measurement that needs explaining is worse than no measurement.

**Then a cheap structural scan** from the lead paths — **enumerate, don't understand**:

- Temporal SDK imports; which SDK(s) and languages.
- Worker construction and registration wiring (`worker.New` + `Register*` in Go, equivalents elsewhere) → which workers host which workflows/activities on which task queues.
- Workflow and activity definitions; entry points (client starters, schedules, Nexus operations, signal senders).
- Immediate external neighbors: databases, queues, third-party APIs, internal services touched from activities or from code that starts workflows.

Minutes, not hours. Do not read handler bodies yet.

**Inventory granularity scales with the target.** Under roughly 50 workflows, inventory them individually — that becomes the report's inventory table. Above that, **inventory at domain level** (one row per domain, service, or worker with a count), and say in the report that you did. A per-workflow table of 800 rows is neither possible nor useful, and attempting it is wasted effort.

## Phase 3 — Confirm scope + intake

Present a **succinct list** of what you found — each service/domain/worker with a one-phrase description — and ask the user to confirm, correct, and **pick a focus**.

**At scale, propose rather than enumerate.** When there are dozens of domains, a flat list is unusable. Offer **numbered candidate focus areas** — grouped into coherent end-to-end paths ("the namespace provisioning spine: this CP domain plus that IP domain") — and state an explicit recommendation with your reasoning, including what you would leave out and why. Users pick from a shortlist far more readily than they carve one from an inventory.

Ask the **maturity question** here too, per `reference/maturity-signals.md` — present the git signals, ask where the user places the system on the prototype-to-production spectrum, and ask whether the *focus area* is at the same stage as the repo overall. Their answer wins; if it disagrees with the signals, record both without adjudicating.

Then ask the intake questions from [reference/sa-questions.md](reference/sa-questions.md), **skipping anything the scan already answered, and skipping anything the confirmed stage makes moot** (state the observed answer and ask them to confirm rather than re-asking). Remind them approximate answers are helpful.

Keep this gate to two things: **scope confirmation** and **intake**. If the `twf` path is genuinely available (Phase 0 verified it), mention it in one line here; never spend a labeled section on it.

**Partial answers are the normal case.** If scope is confirmed but intake is only half answered, **proceed to Phase 4** and carry the unanswered items into the Phase 6 gate. Do not stall the pipeline for intake, and do not re-ask an item the user has already declined.

## Phase 4 — Research

Deep exploration of the confirmed scope, along two perspectives. Both matter; [reference/diagram-guide.md](reference/diagram-guide.md) defines what "good" looks like for each.

1. **Internal to Temporal** — the shape of each in-focus workflow: trigger, major steps, activities, child workflows, signals, queries, updates, timers, retries and failure paths, continue-as-new, final outcomes. Plus worker topology: which workers, which task queues, what is co-hosted. Capture **exact values** — timeouts, retry policies, concurrency limits, page sizes — because precise numbers are what let an SA judge quickly. Record the number; do not rate it.
2. **External to Temporal** — the system *around* it: databases, queues, third-party APIs, user-facing services, and where Temporal sits among them. **Scoping rule: explore a non-Temporal component only to answer "how does this relate to my workflows?"** One hop out from workflow/activity/starter code is the boundary; note what lies beyond as a labeled external box and stop. Do not map the customer's whole company.

**When a dependency is the same technology as the system under review, label it explicitly to prevent conflation.** A system that both uses a technology and exposes it as a product feature will have two unrelated surfaces that look identical in a diagram; merging them is a serious error in front of an SA. Name each one for its role ("the platform's own control API" versus "the customer-facing feature of the same name") and keep them as separate nodes.

**Re-test your Phase 2 premise against the first focus slice before fanning out.** A cheap scan produces sweeping generalizations ("this is all proto-generated codegen"), and a wrong one propagates verbatim into every subagent prompt you write. Confirm the premise holds on one slice first; a premise that survives contact is worth handing out, and one that doesn't would have poisoned the whole fan-out. Your own generalizations need verification exactly as much as a subagent's claims do.

**Fan out with subagents when scope is large** (multiple services, giant workflows, more than ~3 focus workflows): one per bounded slice. **Use the ready-made brief in [reference/subagent-prompt.md](reference/subagent-prompt.md)** — copy it verbatim and fill in the slice name, absolute paths, and numbered questions. Do not re-author it per run. It already carries: the read-only rule, the one-hop external scoping rule, the **map-not-review rule and its banned vocabulary**, the set-vs-defaulted rule, generated-code exclusion, evidence labels, the stop rule, "finding nothing is a valid finding", and an **output budget** — a structured summary of conclusions with `file:line` citations, roughly one page, never raw file dumps or exhaustive line-by-line inventories — plus all of the following:

- **A numbered question list** specific to that slice, so returns are comparable and you can tell what went unanswered.
- **Absolute paths**, with an explicit instruction not to use relative ones — a subagent's working directory may not be what you assume.
- **An evidence label on every claim:** `[VERIFIED]` (it read the line and confirmed), `[SUBAGENT]` (reported, not yet checked), `[INFERRED]` (reasoning, not observation). Verification status must survive into your notes, or you cannot tell later what still needs checking.
- **"Reporting that you found nothing is a valid and important finding. Do not manufacture hits."** A trustworthy set of zeros is a real result; a subagent that feels obliged to return findings will produce noise you then have to disprove.

**Any comparative or evaluative statement must carry `[INFERRED]`.** "This is the largest surface of its kind here" is reasoning, not observation, and the label is what keeps it honest. Prefer restating it as the underlying counts.

Then **verify their load-bearing claims** against the cited lines before those claims enter the report.

**Write `.work` slice notes in report voice, not analysis voice.** You will otherwise write every finding twice — once to think, once to publish. Notes written as publishable prose let §4 be assembled by extraction.

Anything the code cannot show — deployment-time wiring, config-driven routing, services with no source available — goes to the gap ledger, not into guesswork.

### Choosing the toolchain

- **Generic path (default):** your normal code tools, Mermaid diagrams per the diagram guide. If you hit an unfamiliar Temporal primitive and need doc-aligned framing for it, consult the official `temporal-developer` skill for that primitive specifically. Do not load it wholesale as preparation — it is written for someone building an app, not reviewing one.
- **`twf` path (experimental, opt-in):** only if Phase 0 verified the toolchain. It pays off when the review's questions are about **mechanics** — exact option values, control flow, child-workflow semantics — and much less when they are about topology or scale. See [reference/twf-path.md](reference/twf-path.md).

## Phase 5 — Fan-in + validate

Assemble the bundle per [reference/output-spec.md](reference/output-spec.md).

**Then gate the diagrams. This step is mandatory and not optional judgment:**

```bash
python3 scripts/lint_diagrams.py <out>/diagrams/*.mmd
```

Fix everything it reports and re-run until it passes. A broken diagram is the worst failure this tool can produce: the customer cannot tell, and they hand a Temporal SA files that do not open.

If Phase 0 produced a renderer, **also render every diagram and require success** — that is the real proof, and the rendered images ship in the bundle. If it did not, note in the share manifest that the `.mmd` files render at mermaid.live.

## Phase 6 — Gap gate (one ask, after research)

Cheap structural scanning produces few gaps; research produces most of them. So there is **one** batched ask, here — after Phase 4, before the report is final.

Put to the user the gaps they can actually close, prioritizing **code-fact questions** ("is this cap enforced anywhere?", "who sends this signal?") over metrics they have already said they don't have. A user answer closes the entry as *stated*; anything unanswered survives into the report's "Questions for the review."

Do not re-ask what was already declined, and do not skip this gate on the assumption that the user has nothing to add — code-fact questions are answerable even when every scale number came back "unknown."

## Phase 7 — Report + handoff

1. **Executive summary** at the top of `report.md`, leading with what the *customer* now has, then the system's defining characteristics — the facts an SA will orient on fastest — then what to send the SA. Characteristics, not concerns.
2. **The share manifest** — which files to share and what each reveals. Remind them to check the Temporal team can actually open what they send.
3. **One logistics nudge on meeting length** if the agenda you built is deep: 30 minutes is tight for a real architecture discussion.
4. **The representative-run nudge, conditionally.** A Namespace + Workflow ID is the highest-leverage, lowest-effort addition — *if it exists*. If the user declined it for a **structural** reason (no single nameable cluster, multi-tenant, pre-production), it is already recorded; **do not nudge again**. Only repeat the ask if they simply hadn't got to it.
5. **twf path only:** offer to open the visualizer for the customer's own exploration, and be clear the shareable artifacts are the `.twf` files, the diagrams, and the report — a localhost URL is not a deliverable.

Close by showing the bundle's file list and inviting them to read `report.md` before sharing anything.
