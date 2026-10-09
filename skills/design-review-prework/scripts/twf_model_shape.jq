# Shape of a .twf model, from `twf graph --json`. Read-only; no network.
#
#   twf graph --json <out>/twf/ | jq -r -f scripts/twf_model_shape.jq
#
# Reports three things a clean `twf check` cannot:
#   - workflow-to-workflow edges: child workflows, Nexus, signals. Zero means every
#     tree is one level deep -- each workflow calls only activities, which are leaves.
#   - call depth per workflow: 0 = hollow (no calls modeled, so the routing check
#     tested nothing); 1 = activities only; 2+ = real workflow chains.
#   - registered activities nothing calls: each is a wiring claim the model does not test.
#
[.graph.edges[] | select(.kind != "containment")
  | {f: (.from | split("/")[0]), t: (.to | split("/")[0]), k: .kind}] as $e
| def depth($n; $seen):
    if ($seen | index([$n])) then 0
    else ([$e[] | select(.f == $n) | .t] | unique
          | if length == 0 then 0 else (map(depth(.; $seen + [$n])) | max) + 1 end)
    end;
( [.graph.nodes[].id | split("/")[0]] | unique ) as $defs
| ( [$e[].t] | unique ) as $called
| "workflow-to-workflow edges: \([$e[] | select(.t | startswith("workflow:"))] | length)",
  "call depth per workflow (0 = hollow, 1 = activities only):",
  ( $defs[] | select(startswith("workflow:")) | "  \(depth(.; []))  \(.)" ),
  "registered activities nothing calls:",
  ( $defs[] | select(startswith("activity:")) | select(. as $a | $called | index([$a]) | not) | "  \(.)" )
