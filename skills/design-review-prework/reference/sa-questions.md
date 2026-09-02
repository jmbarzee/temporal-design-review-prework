# What the SA needs answered

These are the questions a Temporal Solutions Architect prepares against. Every one answered in prework is meeting time recovered for actual recommendations. Ask them at the Phase 3 confirm gate, **skipping anything the code scan already answered** (state the observed answer, ask for confirmation instead). Preface the intake with: *"Approximate answers are helpful — order of magnitude is enough, and 'unknown' is a fine answer."*

Record every answer in `intake.md`, tagged **stated** (user said it) or **observed** (seen in code, with the file reference). Every "unknown" also becomes a gap-ledger entry.

## 1. Use case, in the customer's own words
- What business problem does this system solve? (Not the technical shape — the *why*.)
- Where does Temporal fit in the overall product?

## 2. SDK and build status
- Which SDK(s)? (usually observable — confirm)
- How built-out is it? Planning / early-stage with placeholders / running in staging / production. Nuance welcome ("workflow logic built and tested, external calls still stubbed" is a great answer).

## 3. A representative run (highest-leverage, lowest-effort item)
- If any workflow already runs in a real namespace: **Namespace + Workflow ID** (and optionally Run ID) of one representative execution. Two copy-pasted IDs let the SA read real event history — retry counts, event counts, payload sizes, timing — which no diagram can show.
- Pre-production? Skip without friction; note "pre-production" in the report.

## 4. Scale and the operational envelope
The right Temporal advice genuinely changes with order of magnitude. Ask for rough numbers:
- Peak workflow start rate (per second/minute/day — whatever unit they think in)
- Expected concurrent executions
- Longest expected single-execution duration (seconds? days? months?)
- Largest payload passed through a workflow or activity
- Signal/update volume per execution, if signals are used
- Anticipated growth (users / triggers / volume) over the next year

## 5. Deployment target
- Temporal Cloud or self-hosted? (If self-hosted: which database, and is a Cloud comparison of interest?)
- Where do workers run (Kubernetes, VMs, serverless, platform)?
- Any worker/SDK metrics or dashboards already set up?

## 6. Cost and volume — **optimization-flavored sessions only**
- Current infra costs around Temporal (DB + compute; workers can be excluded)
- Action/event volume breakdown by workload or namespace, if known
- Rough unit economics (value per workflow trigger) and any self-hosting cost estimate — these turn a cost conversation into a decision instead of an explanation

## 7. Risks, incidents, constraints
- Known pain points or bottlenecks; any incident that involved this system
- SLAs / latency expectations; compliance or data-residency requirements
- Retry/timeout/failure-handling decisions they're unsure about

## 8. The agenda question (always ask, always last)
- "What specific questions do you want answered in this session? What's the *one thing* you want out of it?"

Specific beats general: "are our fan-out and child-workflow patterns optimal, and can some collapse into batched activities or continue-as-new iterators?" gives the SA an agenda; "is our design good?" gives them nothing. If the user's answer is generic, offer to draft 3–5 specific candidate questions from what the research surfaced, and let them pick.
