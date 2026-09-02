---
name: design-review-prework
description: Prepare the prework bundle for a Temporal design review or optimization session — architecture diagrams (external and internal), a system report, and answers to the questions your Temporal Solutions Architect will ask — built from read-only exploration of your codebase plus a short intake conversation. Use before a scheduled design review with Temporal.
---

# Temporal Design Review Prework

You are helping a developer prepare for a **design review with a Temporal Solutions Architect (SA)**. The single highest-leverage prework artifact is a real architecture diagram — not just "the Temporal bits," but the whole system around Temporal — paired with answers to a short list of questions the SA will otherwise spend meeting time asking. A thin submission ("4 boxes and lines") turns the review into generic Temporal education; a good one lets the SA walk in with a pre-built agenda targeted at this system.

The output is equally the **customer's own artifact**: an architecture document and diagram set their team keeps, whether or not the meeting happens. Frame everything you produce for the customer first; the review is the occasion, not the owner.

## Ground rules

**Read-only against the customer's code.** Never modify, build, run, or execute anything in the codebase under review. The only paths you write to are the output directory and the scratch directory below.

**Egress is confined to Phase 0.** Installing a diagram renderer from a public package registry is permitted in Phase 0, with the user's explicit consent. From Phase 1 onward: no network calls, no web search unless the user opts in when offered in Phase 1, and **no source code, diagram, or report content leaves the machine — ever**. Never install a renderer later to satisfy a rendering requirement; if Phase 0 produced none, ship diagram source and say so.

**Scratch space is sanctioned.** Keep working notes, raw subagent returns, and intermediate research in `<out>/.work/` (or a system temp directory). Do not hold large research payloads in context to avoid writing them down. `.work/` is excluded from the share manifest.

**Every fact is observed or stated.** *Observed* = seen in code, and it carries a `file:line` reference. *Stated* = the user told you. Use these exact inline forms so the SA can audit at a glance:

- `*(observed: service/worker/batcher/workflow.go:144)*`
- `*(stated)*`

Never invent a fact about the system, and never let a plausible inference pass as observation. What you cannot determine goes in the gap ledger.

**Verify before you repeat.** Any claim from a subagent that lands in the report or a diagram must be spot-checked against the cited `file:line` first. A cheap read is the difference between a report and a rumor — and an unverified claim in front of an SA costs the customer credibility.

**The gap ledger is continuous, not a phase.** From Phase 2 onward, every unknown goes into `gap-ledger.md` the moment you meet it: what is missing, why the review cares, what would close it. Never block on a gap — "we could not see the billing service; here is what its callers imply" is a deliverable.

**Approximate answers are helpful.** Say this verbatim when asking intake questions. "Unknown" is an acceptable, recorded answer; never stall waiting for a number.

**The user reviews before anything is shared.** The bundle ends with a share manifest. You never send it anywhere yourself.

**The bundle is the customer's, not this skill's.** Never put commentary about these instructions — what was unclear, what you'd change — into any bundle file. It goes to a Temporal SA who has no stake in this skill's internals. (On the `twf` path there *is* a legitimate toolchain reflection deliverable, `twf-retro.md`; it is about the `.twf` notation, not about this skill. See the twf-path reference.)

## Phase 0 — Prep (tooling)

The only phase where egress is allowed. Do this before touching any code.

1. **Check for a Mermaid renderer**, in order: `mmdc --version` (the `@mermaid-js/mermaid-cli` package), then `docker` (image `minlag/mermaid-cli`).
2. **If none is present, offer to install one, with the reason** — not as a bare yes/no. Say what it buys: a rendered PNG/SVG is what actually gets pasted into an intake form, a deck, or a ticket, and it proves the diagram parses; unrendered source may simply not open for the SA. Offer `npx -y @mermaid-js/mermaid-cli` (no global install) or a global `npm i -g @mermaid-js/mermaid-cli`, note it's a one-time public-registry download of a headless-browser-backed renderer, and say plainly that declining is fine — the bundle still ships valid diagram source that renders at mermaid.live.
3. **Record the outcome.** The renderer's presence decides whether Phase 5 can *prove* the diagrams render or only lint them.
4. **Optional, experimental:** if the user might want the `twf` path (see below), verify it here too — `twf --help` plus the `temporal-architect` skills. Do not raise it as a question yet; just know the answer so Phase 3's offer is accurate.

Nothing in this phase reads customer code. Once it ends, the egress window closes.

## Phase 1 — Lead

Ask for the code paths **first**, then everything else, so your output-directory suggestion can be concrete:

1. **One or two paths** into the codebase(s) that use Temporal — repo roots or service directories both work.
2. **Company / product name** and one or two sentences on what the product does. Offer, as an explicit opt-in, a quick web search for public context — the default is that the user just tells you. Declining both is fine; context can stay thin.
3. **Session flavor:** standard design review, cost/optimization session, or pre-production architecture check — and *the one thing they most want out of it*.
4. **Output directory**, suggesting a concrete sibling of the path from #1 (e.g. `../temporal-prework/`). Never inside the repo under review.

Do not ask the full intake yet; it lands in Phase 3, once you can ask informed questions.

## Phase 2 — Explore

A cheap structural scan from the lead paths — **enumerate, don't understand**:

- Temporal SDK imports; which SDK(s) and languages.
- Worker construction and registration wiring (`worker.New` + `Register*` in Go, equivalents elsewhere) → which workers host which workflows/activities on which task queues.
- Workflow and activity definitions; entry points (client starters, schedules, Nexus operations, signal senders).
- Immediate external neighbors: databases, queues, third-party APIs, internal services touched from activities or from code that starts workflows.

Minutes, not hours. Do not read handler bodies yet. This scan doubles as the report's full workflow inventory, so note every workflow you see, including ones that will fall out of focus.

## Phase 3 — Confirm scope + intake

Present a **succinct list** of what you found — each service/domain/worker with a one-phrase description — and ask the user to confirm, correct, and **pick a focus**.

Then ask the intake questions from [reference/sa-questions.md](reference/sa-questions.md), **skipping anything the scan already answered** (state the observed answer and ask them to confirm rather than re-asking). Remind them approximate answers are helpful.

Keep this gate to two things: **scope confirmation** and **intake**. If the `twf` path is genuinely available (Phase 0 verified it), mention it in one line here; never spend a labeled section on it.

**Partial answers are the normal case.** If scope is confirmed but intake is only half answered, **proceed to Phase 4** and carry the unanswered items into the Phase 6 gate. Do not stall the pipeline for intake, and do not re-ask an item the user has already declined.

## Phase 4 — Research

Deep exploration of the confirmed scope, along two perspectives. Both matter; [reference/diagram-guide.md](reference/diagram-guide.md) defines what "good" looks like for each.

1. **Internal to Temporal** — the shape of each in-focus workflow: trigger, major steps, activities, child workflows, signals, queries, updates, timers, retries and failure paths, continue-as-new, final outcomes. Plus worker topology: which workers, which task queues, what is co-hosted.
2. **External to Temporal** — the system *around* it: databases, queues, third-party APIs, user-facing services, and where Temporal sits among them. **Scoping rule: explore a non-Temporal component only to answer "how does this relate to my workflows?"** One hop out from workflow/activity/starter code is the boundary; note what lies beyond as a labeled external box and stop. Do not map the customer's whole company.

**Fan out with subagents when scope is large** (multiple services, giant workflows, more than ~3 focus workflows): one per bounded slice. Give each subagent, verbatim: the read-only rule, the one-hop external scoping rule, and an **output budget** — a structured summary of conclusions with `file:line` citations, roughly one page, never raw file dumps or exhaustive line-by-line inventories. Then **verify their load-bearing claims** against the cited lines before those claims enter the report.

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

1. **Executive summary** at the top of `report.md`, leading with what the *customer* now has, then the most review-worthy observations, then what to send the SA.
2. **The share manifest** — which files to share and what each reveals. Remind them to check the Temporal team can actually open what they send.
3. **One logistics nudge on meeting length** if the agenda you built is deep: 30 minutes is tight for a real architecture discussion.
4. **The representative-run nudge, conditionally.** A Namespace + Workflow ID is the highest-leverage, lowest-effort addition — *if it exists*. If the user declined it for a **structural** reason (no single nameable cluster, multi-tenant, pre-production), it is already recorded; **do not nudge again**. Only repeat the ask if they simply hadn't got to it.
5. **twf path only:** offer to open the visualizer for the customer's own exploration, and be clear the shareable artifacts are the `.twf` files, the diagrams, and the report — a localhost URL is not a deliverable.

Close by showing the bundle's file list and inviting them to read `report.md` before sharing anything.
