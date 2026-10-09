# Model-shape check; reference/twf-path.md says what each line means.
#   twf graph --json <out>/twf/ | jq -r -f scripts/twf_model_shape.jq
# Counted per definition, not per deployment: a workflow hosted on two workers is one node.
( [.graph.edges[] | select(.kind != "containment" and .kind != "nexusRoute")
    | {f: (.from | split("/")[0]), t: (.to | split("/")[0]), k: .kind}] | unique ) as $e
| def depth($n; $seen):
    if ($seen | index([$n])) then 0
    else ([$e[] | select(.f == $n) | .t] | unique
          | if length == 0 then 0 else (map(depth(.; $seen + [$n])) | max) + 1 end)
    end;
( [.graph.nodes[].id | split("/")[0]] | unique ) as $defs
| ( [$e[].t] | unique ) as $called
| ( [$e[] | select(.k == "workflowCall" or .k == "signalSend" or .k == "nexusCall")] ) as $x
| "cross-workflow edges: \($x | length)" + ([$x | group_by(.k)[] | "  \(.[0].k)=\(length)"] | join("")),
  "call depth per workflow (longest call chain below it; 0 = hollow):",
  ( $defs[] | select(startswith("workflow:")) | "  \(depth(.; []))  \(.)" ),
  "registered activities nothing calls:",
  ( $defs[] | select(startswith("activity:")) | select(. as $a | $called | index([$a]) | not) | "  \(.)" )
