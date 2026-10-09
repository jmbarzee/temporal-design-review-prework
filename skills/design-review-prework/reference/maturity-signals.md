# Reading the target's maturity

Advice right for a speculative prototype is wrong for seasoned production, and the reverse; an SA who guesses the stage wrong spends the meeting recalibrating. Stage is **context, not a grade**: never let "early" imply "sloppy" or "mature" imply "correct."

## The cheap git survey

Once per repo, right after the paths are known. Git metadata only — no source, no network.

```bash
R=<repo path>
git -C "$R" log --max-parents=0 --format=%cs -1 | head -1   # first commit (age)
git -C "$R" log -1 --format=%cs                             # last commit (alive?)
git -C "$R" rev-list --count HEAD                           # total commits
git -C "$R" rev-list --count --since="90 days ago" HEAD      # recent cadence
git -C "$R" shortlog -sn HEAD | wc -l                        # contributors
git -C "$R" tag | wc -l                                      # tags / releases
```

Then, cheaply, for the focus area only:

```bash
git -C "$R" rev-list --count --since="90 days ago" HEAD -- <focus path>   # churn where it matters
ls -d "$R"/.github/workflows "$R"/.gitlab-ci.yml 2>/dev/null              # CI present?
```

Plus a test-density ratio (test files against source files in the target language) and, if it is quick, a count of `TODO`/`FIXME` markers in the focus paths.

On a large monorepo, scope `find`-based counts to the focus directories and skip vendored paths. Drop any slow command — no single signal is worth minutes.

## What the signals suggest

Read them together; no single number decides. These are correlations, not definitions.

| Signal pattern | Suggests |
|---|---|
| Months old, one or two contributors, few or no tags, thin tests, no CI | Prototype / spike |
| A year or two old, small team, some CI, tests appearing, active recent commits | Active development |
| Multi-year, steady cadence, many tags/releases, CI, substantial tests, many contributors | Mature production |
| Multi-year but last commit long ago, low recent cadence | Maintenance mode or inherited/legacy |
| High recent churn concentrated in the focus paths | The focus area is actively moving — say so; the design may change before the meeting |

A mismatch is itself worth recording: a ten-year-old repo whose focus directory is three weeks old is a mature platform growing a new limb, and the review is about the limb.

## Ask the user — their answer wins

The survey informs the question; it does not replace it:

> "Where would you put this on the spectrum from speculative prototype to seasoned production? The git history suggests <one-line summary of signals> — does that match how you'd describe it? And is the *specific area we're reviewing* at the same stage as the repo overall?"

The focus area's stage, not the repo's, calibrates the review. Record the answer as `*(stated)*` and the signals as observations; **if they disagree, record both without adjudicating** — "the history shows five years and 300 contributors; the team describes the reviewed workflows as early-stage."

## How stage calibrates the rest of the run

**Prototype / spike**
- Do not ask for a representative run, production metrics, or incident history — they do not exist, and asking signals you weren't listening. Mark the representative-run item resolved-by-stage.
- Scale numbers are *intentions*, not measurements. Record them as stated targets, and say so.
- The map is mostly about intended shape; expect blank space and do not treat it as a gap in the customer's diligence.
- Note explicitly in the report that the design is expected to change — an SA reviewing a moving target will pitch differently.

**Active development**
- Mixed: some paths run somewhere, others are stubs. Ask *per focus area* whether it has ever run, rather than once for the whole system.
- Watch for placeholder implementations, and record them as observed stubs rather than as omissions.

**Mature production**
- Chase the quantitative items hard — a representative Namespace + Workflow ID, real volumes, dashboards, incident history. Here they exist, and they are the highest-value content in the bundle.
- Historical constraints are real: version gates, migration paths, and compatibility branches are load-bearing. Record them as-is, with dates where the code carries them.
- Expect deliberate decisions that look surprising. Note the mechanism and quote any code comment that records the reason, rather than reading it as an accident.

**Maintenance / inherited**
- Institutional knowledge is likely gone. Expect the user to answer "unknown" more often, and treat that as a fact about the situation, not a failure of the intake.
- The gap ledger is the most valuable artifact here; weight effort toward it.
