# Output bundle spec

Everything lands in the output directory chosen in Phase 1. Nothing is written anywhere else, except scratch work under `<out>/.work/`.

```
<out>/
  report.md                    # the prework report (template below)
  intake.md                    # SA intake answers, tagged *(stated)* / *(observed: path:line)* / unknown
  gap-ledger.md                # what we couldn't see + questions for the review
  share-manifest.md            # what's in the bundle, what each file reveals
  diagrams/
    external-architecture.mmd  # + .png/.svg when Phase 0 produced a renderer
    <workflow>-internal.mmd    # one per in-focus workflow...
    <family>-internal.mmd      # ...or one per workflow family (see diagram guide)
  .work/                       # scratch: raw subagent returns, notes. Not shared.
  twf/                         # twf path only
    <domain>/*.twf  deploy/topology.twf  twf-retro.md
```

## report.md template

1. **Executive summary** — 5–10 lines. Lead with what the customer now has (architecture doc, diagrams, agenda); then the 3–5 **defining characteristics** of the system, stated as facts an SA will orient on fastest; then what to send the SA. No process narration, and no verdicts — see SKILL.md "What this produces: a map, not a review."

   A defining characteristic is structural: "provisioning is driven by long-lived entity workflows that carry state across continue-as-new; cross-plane calls are activities that start and poll a workflow in another namespace." Not "the cross-plane coupling is concerning."*
2. **System overview** — the product, where Temporal sits, deployment target, SDK(s), build status. **State each deployment/topology fact once, here** — §5 references it rather than repeating it.
3. **Workflow inventory** — table: workflow, one-phrase purpose, trigger, worker/task queue, in focus? Every workflow found, including out-of-focus ones, one line each.
4. **Focus workflows** — per in-focus workflow or family: a short narrative of its shape (trigger → steps → outcome, signals/timers/children/retries/failure paths), a pointer to its diagram, and a **mechanism-and-values** subsection.

   The mechanism-and-values subsection is the highest-value part of the report for an SA, and it is purely descriptive. Record, with `file:line`:

   - every timeout, retry policy, and backoff actually configured (and note where a default is inherited rather than set)
   - concurrency limits, page sizes, rate limits, and whether each is hardcoded or configuration-driven
   - what rides in workflow input, memo, search attributes, and heartbeat details
   - how progress survives failure (continue-as-new, heartbeat checkpoints, external state)
   - what state is carried across continue-as-new, and which parts of it are unbounded
   - child-workflow lifetime relationships (parent close policy, await-start vs await-result)
   - where the code's own comments record intent, a caveat, or a `TODO` — quoted and attributed

   State each of these as a fact. Do not grade it, do not rank it by severity, and do not credit it. Crediting good design is the same boundary violation as flagging bad design — both are the SA's call. **This tool prepares the review; it does not perform it.**
5. **External architecture** — the systems around Temporal and how each relates to the workflows (one hop out); pointer to the external diagram. Do not restate §2's deployment facts.
6. **Operational envelope** — the stated scale, growth, and cost numbers from intake, unknowns included, each marked stated or unknown. Add an "assume when advising" line for anything the SA should not guess at (e.g. "self-hosted, DB varies — don't assume one backend").
7. **Questions for the review** — the agenda: the user's own questions first, then unresolved gap-ledger entries phrased as questions. Make every entry specific.

   This is the one section where evaluative *questions* are welcome, because the customer is asking them, not you answering them. "Is the cross-namespace activity pattern the right shape at our scale?" is exactly right. What is still not allowed is a question that smuggles in your verdict — "shouldn't these unbounded retries be capped?" is a finding wearing a question mark. Ask "what retry ceiling would you recommend here, given the activity runs up to 20 years?" and let the numbers carry it.

   The report has to be written before the user can pick their agenda, so draft these as an explicitly marked **CANDIDATE** list, ask the user to keep/edit/drop, then finalize the section and **remove every CANDIDATE marker**. A bundle shipped with markers still in it is unfinished.
8. **Provenance note** — one line: generated read-only from `<paths>` on `<date>`, facts tagged observed/stated, nothing sent off-machine.

## gap-ledger.md

Per entry: **what's missing → why the review cares → what would close it** (a path, a person, a number, a dashboard). Status: open / answered (with the stated answer) / out of scope. Unresolved entries are copied into report §7 as questions.

Distinguish the two kinds, because they route differently at the Phase 6 gate: **code-fact gaps** ("is this cap enforced anywhere?") are usually answerable by the user and worth asking; **metric gaps** the user has already declined are not worth re-asking.

Rank the ledger by **what an answer would change in the SA's advice**, not by category. A gap whose answer would move the recommendation belongs at the top: workflow lifetime alone is inert, but lifetime combined with signal rate is what determines whether history grows without bound — so the missing signal rate outranks a missing start rate. Say why an entry is ranked where it is, in one clause, without asserting what the answer will turn out to be.

The ledger is the map's blank space: honest, bounded, and labeled. "We could not see the billing service; here is what its callers imply about its interface" is cartography. "The billing service is probably a bottleneck" is not.

## share-manifest.md

A table — file, contents in one phrase, sensitivity note ("names internal services", "contains volume numbers", "no source code included"). Then:

- State whether diagrams ship as rendered images or as `.mmd` source only (source renders at mermaid.live).
- Remind the user to verify the receiving Temporal team can open everything shared.
- Confirm the bundle contains **no source code** — diagrams and prose only. If any snippet was quoted in the report, list it here explicitly.
- Note that `.work/` is scratch and is not part of the bundle.
