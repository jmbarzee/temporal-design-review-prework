# Output bundle spec

Everything lands in the output directory chosen in Phase 1:

```
<out>/
  report.md                    # the prework report (template below)
  intake.md                    # SA intake answers, tagged *(stated)* / *(observed: path:line)* / unknown
  gap-ledger.md                # what we couldn't see + questions for the review
  share-manifest.md            # what's in the bundle, what each file reveals
  diagrams/
    external-architecture.mmd  # + .png/.svg when Phase 0 produced a renderer
    external-architecture-<domain>.mmd  # ...or split by domain when over the 25-node cap
    <family>-internal.mmd      # one per in-focus workflow or workflow family
  .work/                       # scratch notes. Not shared.
  twf/                         # when the toolchain is installed; one flat package
    topology.twf               #   tier-1 wiring model: ships to the SA
    <slice>.twf                #   tier-2 behavioral model: optional, not by default
    twf-retro.md               #   notation reflection: for the toolchain maintainers
```

**Bundle filenames can collide with agent-harness guards.** A heuristic may refuse writes to `report.md`; create the file another way, and never rename the deliverable.

## report.md template

1. **Executive summary** — 5–10 lines. Lead with what the customer now has (architecture doc, diagrams, agenda); then the 3–5 **defining characteristics** of the system, stated as facts an SA will orient on fastest; then where the research concentrated beside the customer's stated concerns from intake, each labeled for what it is and any divergence said plainly; then what to send the SA. No process narration.

   A defining characteristic is structural: "provisioning is driven by long-lived entity workflows that carry state across continue-as-new; cross-plane calls are activities that start and poll a workflow in another namespace." Not "the cross-plane coupling is concerning."
2. **System overview** — the product, where Temporal sits, deployment target, SDK(s), build status. **State each deployment/topology fact once, here** — §5 references it rather than repeating it. When a `twf/` model ships, list here the **edges the graph omits** ([twf-path.md](twf-path.md#tier-1--the-wiring-cross-check-every-run)).
3. **Workflow inventory** — table: workflow, one-phrase purpose, trigger, worker/task queue, in focus? Every workflow found, including out-of-focus ones, one line each.
4. **Focus workflows** — per in-focus workflow or family: a short narrative of its shape (trigger → steps → outcome, signals/timers/children/retries/failure paths), a pointer to its diagram, and a **mechanism-and-values** subsection.

   Mechanism-and-values is the highest-value part of the report for an SA. Record, with `file:line`:

   - every timeout, retry policy, and backoff actually configured (and note where a default is inherited rather than set)
   - concurrency limits, page sizes, rate limits, and whether each is hardcoded or configuration-driven
   - what rides in workflow input, memo, search attributes, and heartbeat details
   - how progress survives failure (continue-as-new, heartbeat checkpoints, external state)
   - what state is carried across continue-as-new, and which parts of it are unbounded
   - child-workflow lifetime relationships (parent close policy, await-start vs await-result)
   - where the code's own comments record intent, a caveat, or a `TODO` — quoted and attributed

   A `**Signal:**` line (SKILL.md, "Signals") goes immediately after the mechanism it belongs to.
5. **External architecture** — the systems around Temporal and how each relates to the workflows (one hop out); pointer to the external diagram. Do not restate §2's deployment facts.
6. **Operational envelope** — the stated scale, growth, and cost numbers from intake, unknowns included, each marked stated or unknown. Add an "assume when advising" line for anything the SA should not guess at (e.g. "self-hosted, DB varies — don't assume one backend").
7. **Questions for the review** — the agenda: the user's own questions first, then unresolved gap-ledger entries phrased as questions. Make every entry specific.

   Evaluative *questions* are welcome here, because the customer is asking them: "Is the cross-namespace activity pattern the right shape at our scale?" A question that smuggles in your verdict is not — "shouldn't these unbounded retries be capped?" is a finding wearing a question mark. Ask "what retry ceiling would you recommend, given the activity runs up to 20 years?" and let the numbers carry it.

   Draft these as a list marked **CANDIDATE**, have the user keep, edit, or drop each, then finalize and remove every marker.
8. **Provenance note** — one line: generated read-only from `<paths>` on `<date>`, facts tagged observed/stated, nothing sent off-machine.

## gap-ledger.md

Per entry: **what's missing → why the review cares → what would close it** (a path, a person, a number, a dashboard), its likely owner, and its related entries (see the composition pass). Status: open / answered (with the stated answer) / out of scope. Unresolved entries become report §7 questions.

Rank the ledger by **what an answer would change in the SA's advice**, not by category. A gap whose answer would move the recommendation belongs at the top: workflow lifetime alone is inert, but lifetime combined with signal rate is what determines whether history grows without bound — so the missing signal rate outranks a missing start rate. Say why an entry is ranked where it is, in one clause, without asserting what the answer will turn out to be.

The ledger is the map's blank space: honest, bounded, and labeled. "We could not see the billing service; here is what its callers imply about its interface" is cartography. "The billing service is probably a bottleneck" is not.

## Correcting a bundle that was already sent

If a later pass changes anything in a bundle the customer already sent — usually a wiring check catching a misattribution — send a **correction**, never a silent replacement: a reviewer who read the first version needs the diff. List each affected file and claim, what it said, what it says now, how the error was caught, and whether any number moved, and say plainly when nothing else changed. Fix the bundle files to match, and record the correction in the provenance note.

## share-manifest.md

A table — file, contents in one phrase, sensitivity note ("names internal services", "contains volume numbers", "no source code included"). Then:

- State whether diagrams ship as rendered images or as `.mmd` source only (source renders at mermaid.live).
- Remind the user to verify the receiving Temporal team can open everything shared.
- Confirm the bundle contains **no source code** — diagrams and prose only. If any snippet was quoted in the report, list it here explicitly.
- Note that `.work/` is scratch and is not part of the bundle.
