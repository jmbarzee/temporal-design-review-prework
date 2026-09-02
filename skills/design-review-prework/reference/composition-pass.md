# The composition pass

Four independent SAs reviewed bundles produced by earlier versions of this skill. All four reported the same defect, and it is the most important thing in this file:

> Their highest-severity findings were **products of facts already in the bundle**, sitting in different sections. One pair was two sentences in the same paragraph.

Per-slice research produces facts. Nothing composes them, so the reader does the multiplication — and a reader with less context than you will sometimes not do it at all. This pass closes that gap **without grading anything**.

It is mechanical. It requires no judgment about severity, and it asserts nothing.

## Run it after research, before writing the report

Take your full observation set and ask these questions across it. Every one is a lookup, not an opinion.

1. **Which stated *limit* does each stated *unboundedness* consume?** An unbounded retry, an uncapped list, an unbounded fan-out, an unlimited attempt count — pair each with every ceiling it draws down: a concurrency guard, a slot count, a history or payload limit, a rate limit, a single-slot exclusivity rule.
2. **Which facts touch the same resource?** The same task queue, worker, slot pool, table, external API, or namespace. Co-tenancy is invisible per-site and obvious in aggregate.
3. **Which facts touch the same lifecycle?** Anything that mints a new run — continue-as-new, retry, reset — crossed with anything keyed on run identity (an idempotency token, a workflow ID, carried state, a cached value).
4. **Which facts touch the same failure path?** A cancellation, a timeout, or a parent close, crossed with what observes it — or with what reports success anyway.
5. **Which config values cannot take effect?** Anything pinned by a side effect or carried across continue-as-new, crossed with anything an operator might edit expecting it to apply.
6. **Which gap-ledger entries are the same gap?** Two entries about one payload, one measurement, or one mechanism are one cluster. Give the ledger a **related entries** column.

## How to record a composition

A linked pair, with both citations, the shared resource, and **no verdict**:

> **Composed observation.** The batch activity's retry policy sets no `maximum_attempts` *(observed: internal/charge/workflow.go:133)*. The frontend permits one concurrent batch operation per namespace *(observed: config/service.go:388)*. **Shared resource:** the namespace's single batch-operation slot.

Stop there. Do not add "so a stuck job blocks the namespace" — that is the reviewer's call, and it is exactly the sentence that turns a map into a review. The pair is the deliverable; the consequence is theirs.

Put these in their own report section, titled **"Observations that may bear on each other."** Order them by nothing in particular — ordering is ranking.

## Give every finding a falsifier

An SA called this "the best single thing in the bundle" when one finding happened to have it:

> One line per observation naming **what measurement would confirm or kill it.**

"A workflow list in the infra namespace filtered to this type would turn this from a code-reading inference into a measurement, or rule it out." That sentence lets the customer generate their own pre-meeting task list, and it closes half the reviewer's "checks I could not complete" section before they write it. Add one to every composed observation and every mechanism-and-values entry that rests on an inference.

## Do not reframe the customer's stated question

This one is a prohibition, and it came from a near-miss: a bundle deleted the customer's stated central worry on the strength of a call-site count, and the reviewer nearly accepted it *because the reframe was flattering*.

- **Never** overwrite, retire, or answer the customer's stated concern from `intake.md`. It survives into the report verbatim.
- If your research produces counter-evidence, **present it as counter-evidence and say what you did not measure**: "the other mechanism has more call sites; we did not measure operations per hour."
- Let the customer and the SA resolve it in the room. A question you pre-argued is a question nobody re-examines.

**Findings set the agenda, not worries — and worries are never deleted.** Both belong in the report: the customer's stated concerns *and* the areas the research actually concentrated in, each labeled for what it is. If they diverge, say so plainly; that divergence is useful, and hiding it costs the meeting.

## Selection must be auditable

Choosing five items to highlight out of forty is a severity call. Either:

- keep the **full** observation set and let the reviewer select, or
- state the selection criterion explicitly ("the five that touch customer-visible paths"), so the reader knows what was dropped and why.

Ranking silently while calling the output "neutral observations" is the worst of the available positions. Say what you did.
