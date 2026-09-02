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

1. **Executive summary** — 5–10 lines. Lead with what the customer now has (architecture doc, diagrams, agenda); then the 3–5 most review-worthy observations; then what to send the SA. No process narration.
2. **System overview** — the product, where Temporal sits, deployment target, SDK(s), build status. **State each deployment/topology fact once, here** — §5 references it rather than repeating it.
3. **Workflow inventory** — table: workflow, one-phrase purpose, trigger, worker/task queue, in focus? Every workflow found, including out-of-focus ones, one line each.
4. **Focus workflows** — per in-focus workflow or family: a short narrative of its shape (trigger → steps → outcome, signals/timers/children/retries/failure paths), a pointer to its diagram, and *observed* design decisions worth SA attention (large payloads, unbounded histories, DIY state, polling activities, fan-out patterns). Flag these neutrally — "worth discussing," never a verdict. **This tool prepares the review; it does not perform it.**
5. **External architecture** — the systems around Temporal and how each relates to the workflows (one hop out); pointer to the external diagram. Do not restate §2's deployment facts.
6. **Operational envelope** — the stated scale, growth, and cost numbers from intake, unknowns included, each marked stated or unknown. Add an "assume when advising" line for anything the SA should not guess at (e.g. "self-hosted, DB varies — don't assume one backend").
7. **Questions for the review** — the agenda: the user's own questions first, then unresolved gap-ledger entries phrased as questions. Make every entry specific.

   The report has to be written before the user can pick their agenda, so draft these as an explicitly marked **CANDIDATE** list, ask the user to keep/edit/drop, then finalize the section and **remove every CANDIDATE marker**. A bundle shipped with markers still in it is unfinished.
8. **Provenance note** — one line: generated read-only from `<paths>` on `<date>`, facts tagged observed/stated, nothing sent off-machine.

## gap-ledger.md

Per entry: **what's missing → why the review cares → what would close it** (a path, a person, a number, a dashboard). Status: open / answered (with the stated answer) / out of scope. Unresolved entries are copied into report §7 as questions.

Distinguish the two kinds, because they route differently at the Phase 6 gate: **code-fact gaps** ("is this cap enforced anywhere?") are usually answerable by the user and worth asking; **metric gaps** the user has already declined are not worth re-asking.

## share-manifest.md

A table — file, contents in one phrase, sensitivity note ("names internal services", "contains volume numbers", "no source code included"). Then:

- State whether diagrams ship as rendered images or as `.mmd` source only (source renders at mermaid.live).
- Remind the user to verify the receiving Temporal team can open everything shared.
- Confirm the bundle contains **no source code** — diagrams and prose only. If any snippet was quoted in the report, list it here explicitly.
- Note that `.work/` is scratch and is not part of the bundle.
