# The composition pass

Four SAs reviewed bundles from earlier versions of this skill, and all four reported the same defect: their highest-severity findings were **products of facts already in the bundle**, in different sections — one pair two sentences apart in the same paragraph. Per-slice research produces facts; nothing composes them, and a reader with less context than you may never do the multiplication.

This pass composes them **without grading anything**. Run it after research, before writing the report, by asking these questions across the full observation set. Each is a lookup, not an opinion.

1. **Which stated *limit* does each stated *unboundedness* consume?** An unbounded retry, an uncapped list, an unbounded fan-out, an unlimited attempt count — pair each with every ceiling it draws down: a concurrency guard, a slot count, a history or payload limit, a rate limit, a single-slot exclusivity rule.
2. **Which facts touch the same resource?** The same task queue, worker, slot pool, table, external API, or namespace. Co-tenancy is invisible per-site and obvious in aggregate.
3. **Which facts touch the same lifecycle?** Anything that mints a new run — continue-as-new, retry, reset — crossed with anything keyed on run identity (an idempotency token, a workflow ID, carried state, a cached value).
4. **Which facts touch the same failure path?** A cancellation, a timeout, or a parent close, crossed with what observes it — or with what reports success anyway.
5. **Which config values cannot take effect?** Anything pinned by a side effect or carried across continue-as-new, crossed with anything an operator might edit expecting it to apply.
6. **Which gap-ledger entries are the same gap?** Two entries about one payload, one measurement, or one mechanism are one cluster; record it in each entry's **related entries**.

## How to record a composition

A linked pair, with both citations, the shared resource, and **no verdict**:

> **Composed observation.** The batch activity's retry policy sets no `maximum_attempts` *(observed: internal/charge/workflow.go:133)*. The frontend permits one concurrent batch operation per namespace *(observed: config/service.go:388)*. **Shared resource:** the namespace's single batch-operation slot.

Stop there. "So a stuck job blocks the namespace" is the reviewer's sentence, and the one that turns a map into a review.

These go in their own report section, **"Observations that may bear on each other,"** in no particular order — ordering is ranking.

## Give every finding a falsifier

Every composed observation, and every mechanism-and-values entry that rests on an inference, gets one line naming **what measurement would confirm or kill it**: "A workflow list in the infra namespace filtered to this type would turn this inference into a measurement, or rule it out." It hands the customer a pre-meeting task list; an SA called the one finding that had it "the best single thing in the bundle."


## Do not reframe the customer's stated question

A bundle once deleted the customer's central worry on the strength of a call-site count, and the reviewer nearly accepted it *because the reframe was flattering*.

- **Never** overwrite, retire, or answer the customer's stated concern from `intake.md`; it survives into the report verbatim.
- Present counter-evidence as counter-evidence, with what you did not measure: "the other mechanism has more call sites; we did not measure operations per hour."
- Leave it for the room. A question you pre-argued is one nobody re-examines.

## Selection must be auditable

Highlighting five items out of forty is a severity call. Keep the **full** set and let the reviewer select, or state the criterion ("the five that touch customer-visible paths") so the reader knows what was dropped. Never rank silently while calling the output neutral.
