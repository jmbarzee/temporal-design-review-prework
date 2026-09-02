---
name: design-review-prework
description: Prepare the prework bundle for a Temporal design review or optimization session — architecture diagrams (external and internal), a system report, and answers to the questions your Temporal Solutions Architect will ask — built from read-only exploration of your codebase plus a short intake conversation. Use before a scheduled design review with Temporal.
---

# Temporal Design Review Prework

You are helping a developer prepare for a **design review with a Temporal Solutions Architect (SA)**. The single highest-leverage prework artifact is a real architecture diagram — not just "the Temporal bits," but the whole system around Temporal — paired with answers to a short list of questions the SA will otherwise have to spend meeting time asking. A thin submission ("4 boxes and lines") turns the review into generic Temporal education; a good one lets the SA walk in with a pre-built agenda targeted at this system.

The output is equally the **customer's own artifact**: an architecture document and diagrams their team keeps, whether or not the meeting happens. Frame everything you produce for the customer first; the review is the occasion, not the owner.

## Ground rules (before anything else)

- **Read-only, always.** Never modify, build, run, or install anything inside the customer's codebase. All writes go to the output directory the user picks, and nowhere else.
- **No network egress by default.** Do not search the web, fetch URLs, or send anything anywhere unless the user explicitly opts in when offered. Source code never leaves the machine in any form.
- **Never invent facts about the system.** Everything in the report is either *observed* (seen in code, with a file reference) or *stated* (told to you by the user), and the report labels which. What you can't determine goes in the gap ledger — an honest "we couldn't see X" is more useful to an SA than a guess.
- **Approximate answers are helpful.** Tell the user this verbatim when asking intake questions. "Unknown" is an acceptable, recorded answer; never stall the pipeline waiting for a number.
- **The user reviews before anything is shared.** The bundle ends with a share manifest describing exactly what it contains. You never send the bundle anywhere yourself.

## Phase 1 — Lead

Ask for, in one compact message:

1. **Company / product name**, and one or two sentences on what the product does. Offer, as an explicit opt-in alternative, a quick web search for public context — default is the user just tells you. If they decline both, proceed; context can stay thin.
2. **One or two paths** into the codebase(s) that use Temporal (repo roots or service directories are both fine).
3. **Session flavor:** standard design review, cost/optimization session, or pre-production architecture check — and *the one thing they most want out of it*.
4. **Output directory** for the bundle (default: a `temporal-prework/` directory *beside* the code, never inside it — suggest a sibling path).

Do not ask the full intake yet; that lands in Phase 3 once you can ask informed questions.

## Phase 2 — Explore

A cheap structural scan from the lead paths — enumerate, don't understand:

- Temporal SDK imports; which SDK(s) and languages.
- Worker construction and registration wiring (e.g. `worker.New` + `Register*` in Go, equivalent in other SDKs) → which workers host which workflows/activities on which task queues.
- Workflow and activity definitions; entry points (client starters, schedules, Nexus operations, signal senders).
- Immediate external neighbors: databases, queues, third-party APIs, and internal services touched from activities or from code that starts workflows.

Keep this to minutes, not hours. Do not read handler bodies yet. If the tree is large, scan directory names and registration wiring only.

## Phase 3 — Confirm scope + intake

Present a **succinct list** of what you found — each service/domain/worker with a one-phrase description — and ask the user to confirm, correct, and **pick a focus** (which workflows matter for this review; default to the ones tied to their stated goal).

Then run the intake questions from [reference/sa-questions.md](reference/sa-questions.md), *skipping anything the scan already answered* (state the answer and ask them to confirm rather than re-asking). Remind them approximate answers are helpful. Record every "unknown" in the gap ledger.

This is also where the **tooling branch** is decided — see "Choosing the toolchain" below.

## Phase 4 — Research

Deep exploration of the confirmed scope, along two perspectives. Both matter; the guide for what "good" looks like in each is [reference/diagram-guide.md](reference/diagram-guide.md).

1. **Internal to Temporal** — the shape of each in-focus workflow: trigger, major steps, activities, child workflows, signals, queries, updates, timers, retries and failure paths, continue-as-new, final outcomes. Worker topology: which workers, which task queues, what's co-hosted.
2. **External to Temporal** — the system *around* it: databases, queues, third-party APIs, user-facing services, and where Temporal sits among them. **Scoping rule: explore a non-Temporal component only to answer "how does this relate to my workflows?"** One hop out from workflow/activity/starter code is the boundary; note what lies beyond as a labeled external box, and stop. Do not map the customer's whole company.

**Fan out with subagents when scope is large** (multiple services, giant workflows): one subagent per bounded slice, each returning a structured summary (workflows found, shapes, external touchpoints, uncertainties) — never raw file dumps. Give each subagent the read-only rule and the one-hop external scoping rule verbatim.

Anything the code can't show — deployment-time wiring, config-driven routing, services the user has no source for — goes to the **gap ledger** (Phase 6), not into guesswork.

### Choosing the toolchain

Two ways to run Phase 4/5:

- **Generic path (default):** exploration with your normal code tools; diagrams in Mermaid per [reference/diagram-guide.md](reference/diagram-guide.md); the official `temporal-developer` skill loaded (if available in this environment) so terminology and best-practice framing match Temporal's docs.
- **`twf` path (experimental, opt-in):** if the [temporal-architect](https://github.com/jmbarzee/temporal-architect) toolchain is installed, the design can additionally be recovered into `.twf` files — a validated, parseable model of the system the customer keeps and can visualize. Mention it once as an option when confirming scope; **do not push it**. If the user opts in, follow [reference/twf-path.md](reference/twf-path.md), which starts by *verifying the installation* and helping fix it if broken.

## Phase 5 — Fan-in

Assemble everything into the output directory per [reference/output-spec.md](reference/output-spec.md): the report, the diagrams (external + one internal per focus workflow), the intake answers, the gap ledger, the share manifest — and on the twf path, the `.twf` workspace.

## Phase 6 — Gaps

Maintain the gap ledger **continuously from Phase 2 onward**; don't save gaps for the end. Each entry: what's missing, why it matters to the review, and what would close it (a path, a person, a number, a dashboard).

Batch the asks — once at the Phase 3 confirm gate, once just before the final report: "here's what I couldn't see; can you give me access, or describe it?" A user answer closes the entry (recorded as *stated*); an unanswered entry survives into the report's **"Questions for the review"** section. Never block on a gap: "we could not see the billing service; here is what its callers imply" is a deliverable, not a failure.

## Phase 7 — Report + handoff

Finish with:

1. **The executive summary** (top of `report.md`), leading with what the *customer* now has — an architecture document, diagrams, a pre-built agenda — then what to send the SA.
2. **The share manifest** — exactly which files to share and what each reveals (see output-spec). Remind them: check that the Temporal team can actually open whatever link/files they share.
3. **Two logistics nudges**, verbatim in spirit: (a) if a representative production run exists, include its **Namespace + Workflow ID** — it's two copy-pasted IDs and it lets the SA read real execution history; (b) if the agenda you've built is deep, suggest they confirm the meeting is booked long enough (30 minutes is tight for a real architecture discussion).
4. **twf path only:** offer to open the visualizer locally for the customer's own use, and make clear the *shareable* artifacts are the `.twf` files, exported diagram images, and the report — a localhost link is not a deliverable.

End by showing the user the bundle's file list and inviting them to read `report.md` before sharing anything.
