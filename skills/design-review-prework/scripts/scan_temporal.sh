#!/usr/bin/env bash
# Phase 2 enumeration for a Temporal codebase. Read-only, no network.
#
# Counts what actually matters and EXCLUDES GENERATED CODE, which otherwise
# dominates every number in a codegen-heavy repo and makes the inventory
# worthless. Prints the exclusions it applied so the report can state them.
#
# Usage: scan_temporal.sh <repo-path> [focus-subpath ...]
set -uo pipefail
R="${1:?usage: scan_temporal.sh <repo-path> [focus-subpath ...]}"; shift || true
cd "$R" 2>/dev/null || { echo "cannot enter $R" >&2; exit 1; }

# Paths whose contents are generated, vendored, or test doubles. Anything matching
# is excluded from every count below, and the exclusion is reported.
EXCL='/vendor/|/node_modules/|\.pb\.go$|\.pb\.gw\.go$|_generated\.go$|\.gen\.go$|/api/gen/|/gen/|/mocks?/|_mock\.go$|/testdata/|\.pb\.validate\.go$'

src() { git ls-files 2>/dev/null | grep -Ev "$EXCL" | grep -E "$1" || true; }
n()   { [ -z "${1:-}" ] && { printf 0; return; }; printf '%s' "$(grep -c . <<<"$1")"; }
hits(){ [ -z "${2:-}" ] && { printf 0; return; }; printf '%s' "$(grep -lE "$1" $2 2>/dev/null | wc -l | tr -d ' ')"; }
cnt() { [ -z "${2:-}" ] && { printf 0; return; }; printf '%s' "$(grep -hoE "$1" $2 2>/dev/null | wc -l | tr -d ' ')"; }

GO=$(src '\.go$'); PY=$(src '\.py$'); TS=$(src '\.tsx?$'); JAVA=$(src '\.java$')
ALLGEN=$(git ls-files 2>/dev/null | grep -E "$EXCL" | grep -E '\.(go|py|tsx?|java)$' || true)

echo "== repo: $R"
echo "-- excluded as generated/vendored/mocks: $(n "$ALLGEN") files"
echo "   pattern: $EXCL"
echo
echo "-- first-party source files (generated excluded)"
printf "   go=%s python=%s ts=%s java=%s\n" "$(n "$GO")" "$(n "$PY")" "$(n "$TS")" "$(n "$JAVA")"
echo
echo "-- Temporal SDK presence (files importing an SDK)"
printf "   go-sdk=%s python-sdk=%s ts-sdk=%s java-sdk=%s\n" \
  "$(hits 'go\.temporal\.io/sdk' "$GO")" "$(hits '^import temporalio|from temporalio' "$PY")" \
  "$(hits '@temporalio/' "$TS")" "$(hits 'io\.temporal\.' "$JAVA")"
echo
echo "-- worker construction (the topology seams; expect few)"
printf "   worker.New=%s\n" "$(cnt 'worker\.New[A-Za-z]*\(' "$GO $TS $PY")"
echo
echo "-- REGISTRATION sites (the reliable workflow/activity inventory proxy)"
printf "   RegisterWorkflow*=%s  RegisterActivity*=%s\n" \
  "$(cnt 'Register[A-Za-z]*Workflow[A-Za-z]*\(' "$GO $TS $PY $JAVA")" \
  "$(cnt 'Register[A-Za-z]*Activit[yi][A-Za-z]*\(' "$GO $TS $PY $JAVA")"
echo "   NOTE: registration sites are the inventory proxy. Raw function-signature"
echo "         greps are NOT -- in a codegen-heavy repo they are dominated by"
echo "         generated bindings and produce a meaningless count."
echo
echo "-- workflow starts (trigger surface)"
printf "   ExecuteWorkflow=%s SignalWithStart=%s ExecuteChild=%s\n" \
  "$(cnt 'ExecuteWorkflow\(' "$GO $TS $PY")" \
  "$(cnt 'SignalWithStartWorkflow\(' "$GO $TS $PY")" \
  "$(cnt 'ExecuteChildWorkflow\(' "$GO $TS $PY")"
echo
echo "-- durability / lifetime mechanics"
printf "   ContinueAsNew=%s GetVersion=%s Patched=%s SetUpdateHandler=%s heartbeat=%s\n" \
  "$(cnt 'NewContinueAsNewError\(|continue_as_new|ContinueAsNew\(' "$GO $TS $PY")" \
  "$(cnt 'workflow\.GetVersion\(' "$GO $TS $PY")" \
  "$(cnt 'workflow\.Patched\(|\.patched\(' "$GO $TS $PY")" \
  "$(cnt 'SetUpdateHandler\(|update_handler' "$GO $TS $PY")" \
  "$(cnt 'RecordHeartbeat\(|heartbeat\(' "$GO $TS $PY")"
echo
echo "-- task queue literals (dedup, top 15)"
grep -hoE '"[a-z0-9][a-z0-9._-]*(-tq|-task-?queue|TaskQueue)"' $GO 2>/dev/null | sort -u | head -15 | sed 's/^/   /'
echo
for F in "$@"; do
  echo "-- focus: $F"
  FF=$(git ls-files "$F" 2>/dev/null | grep -Ev "$EXCL" | grep -E '\.(go|py|tsx?|java)$' || true)
  printf "    first-party files=%s  registrations=%s  churn(90d commits)=%s\n" \
    "$(n "$FF")" "$(cnt 'Register[A-Za-z]*(Workflow|Activit)[A-Za-z]*\(' "$FF")" \
    "$(git rev-list --count --since='90 days ago' HEAD -- "$F" 2>/dev/null || echo '?')"
done
echo
echo "Report the exclusion count alongside any inventory number."
