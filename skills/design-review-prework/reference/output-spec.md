# Output bundle spec

Everything lands in the one output directory chosen in Phase 1. Nothing is written anywhere else.

```
<out>/
  report.md                    # the prework report (template below)
  intake.md                    # SA intake answers, each tagged stated|observed|unknown
  gap-ledger.md                # what we couldn't see + questions for the review
  share-manifest.md            # what's in the bundle, what each file reveals
  diagrams/
    external-architecture.mmd  # + .png/.svg render when possible
    <workflow>-internal.mmd    # one per in-focus workflow, + renders
  twf/                         # twf path only
    <domain>/*.twf  deploy/topology.twf  twf-retro.md
```

## report.md template

1. **Executive summary** — 5–10 lines. Lead with what the customer now has (architecture doc, diagrams, agenda); then the 3–5 most review-worthy observations; then what to send the SA. No process narration.
2. **System overview** — a paragraph: the product, where Temporal sits, deployment target, SDK(s), build status.
3. **Workflow inventory** — table: workflow, one-phrase purpose, trigger, worker/task queue, in review focus? (Every workflow found, even out-of-focus ones — one line each.)
4. **Focus workflows** — per in-focus workflow: a short narrative of its shape (trigger → steps → outcome, signals/timers/children/retries/failure paths), pointer to its diagram, and any *observed* design decisions worth SA attention (large payloads, unbounded histories, DIY state, polling activities, fan-out patterns…). Observations are flagged neutrally — "worth discussing," not verdicts. **This tool does not review the design; it prepares the review.**
5. **External architecture** — the systems around Temporal and how each relates to the workflows (one hop out); pointer to the external diagram.
6. **Operational envelope** — the stated scale/growth/cost numbers from intake, unknowns included, marked stated/unknown.
7. **Questions for the review** — the agenda: the user's own questions first, then unresolved gap-ledger entries phrased as questions. This section is the meeting's spine; make every entry specific.
8. **Provenance note** — one line: generated read-only from `<paths>` on `<date>`, facts tagged observed/stated, nothing sent off-machine.

## gap-ledger.md

Per entry: **what's missing → why the review cares → what would close it** (a path, a person, a number, a dashboard). Status: open / answered (with the stated answer) / out of scope. Unresolved entries are copied into report §7 as questions.

## share-manifest.md

A short table — file, contents in one phrase, sensitivity note (e.g. "names internal services", "contains volume numbers", "no source code included"). Close with two reminders: verify the receiving Temporal team can open everything shared, and the bundle contains **no source code** — diagrams and prose only (if any snippet was quoted in the report, list it here explicitly).
