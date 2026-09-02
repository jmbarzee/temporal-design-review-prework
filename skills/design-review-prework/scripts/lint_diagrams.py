#!/usr/bin/env python3
"""Offline Mermaid flowchart linter for prework diagrams.

Stdlib only, no network. Catches the mistakes that make a diagram fail to
render or read badly -- the failure the customer cannot see for themselves.

Usage:  python3 lint_diagrams.py diagrams/*.mmd
Exit 0 = clean, 1 = problems found.
"""
import re
import sys

OPENERS = [
    ("[[", "]]"), ("[(", ")]"), ("([", "])"), ("((", "))"),
    ("{{", "}}"), ("[", "]"), ("(", ")"), ("{", "}"), (">", "]"),
]
NODE_START = re.compile(r'(?<![\w`"])([A-Za-z][\w]*)\s*(\[\[|\[\(|\(\[|\(\(|\{\{|\[|\(|\{)')
CHAIN_KINDS = ("sequenceDiagram", "stateDiagram")


def mask_quoted(src):
    """Replace quoted-string contents with filler so label text is never
    mistaken for a node declaration. Preserves length and newlines."""
    out=[]; in_q=False
    for ch in src:
        if ch == '"':
            in_q = not in_q; out.append(ch)
        elif in_q:
            out.append("\n" if ch == "\n" else "\x00")
        else:
            out.append(ch)
    return "".join(out)


def strip_comments(src):
    """Blank out %% comment lines but keep line numbering intact."""
    out = []
    for line in src.split("\n"):
        out.append("" if line.lstrip().startswith("%%") else line)
    return "\n".join(out)


def find_labels(src):
    """Yield (line_no, node_id, opener, raw_label) for each node declaration."""
    scan = mask_quoted(src)
    for m in NODE_START.finditer(scan):
        node_id, opener = m.group(1), m.group(2)
        closer = next((c for o, c in OPENERS if o == opener), None)
        if closer is None:
            continue
        i = m.end()
        depth = 1
        # scan forward honouring quotes
        in_q = False
        label_start = i
        while i < len(src):
            ch = src[i]
            if ch == '"':
                in_q = not in_q
            elif not in_q:
                if src.startswith(opener, i):
                    depth += 1
                elif src.startswith(closer, i):
                    depth -= 1
                    if depth == 0:
                        break
            i += 1
        raw = src[label_start:i]
        yield src[:m.start()].count("\n") + 1, node_id, opener, raw


def lint(path):
    raw_src = open(path, encoding="utf-8").read()
    src = strip_comments(raw_src)
    issues = []
    add = lambda ln, msg: issues.append((ln, msg))

    kind = re.search(r'^\s*(flowchart|graph|sequenceDiagram|stateDiagram\w*)', src, re.M)
    if not kind:
        add(0, "no diagram type declaration (need e.g. 'flowchart TD')")
    kind_name = kind.group(1) if kind else ""

    node_ids = set()
    for ln, node_id, opener, label in find_labels(src):
        node_ids.add(node_id)
        stripped = label.strip()
        quoted = stripped.startswith('"') and stripped.endswith('"') and stripped.count('"') == 2
        if not quoted:
            label = mask_quoted(label).replace("\x00", "")
            if "\n" in label:
                add(ln, f'{node_id}: unquoted label spans a newline -> WILL NOT RENDER; wrap in "..."')
            bad = re.search(r'[(),;:#&<>|/]', label)
            if bad:
                add(ln, f'{node_id}: unquoted label contains {bad.group(0)!r} -> wrap in "..."')
    # entities + raw angle brackets anywhere
    for i, line in enumerate(src.split("\n"), 1):
        for ent in ("&lt;", "&gt;", "&amp;", "&quot;"):
            if ent in line:
                add(i, f"{ent} renders literally as text -> use a plain word instead")
                break
    # unquoted edge labels:  -- text -->  /  |text|
    for i, line in enumerate(src.split("\n"), 1):
        m = re.search(r'--+\s*([^-|>"\n][^->\n]*?)\s*--+>', line)
        if m and not m.group(1).strip().startswith('"'):
            add(i, f'unquoted edge label {m.group(1).strip()!r} -> use -- "text" -->')
    # unlabeled edges are questions the SA has to ask
    plain = len(re.findall(r'--+>(?!\|)', src)) - len(re.findall(r'--\s*"[^"]*"\s*--+>', src))
    # legend
    if "egend" not in raw_src:
        add(0, "no legend -- every diagram needs one (a %% comment is fine)")
    # size: topology diagrams cap at 25; workflow-chain diagrams are exempt
    n = len(node_ids)
    exempt = kind_name in CHAIN_KINDS or re.search(r'(?i)workflow|chain|internal', path.split("/")[-1])
    if n > 25 and not exempt:
        add(0, f"{n} nodes: over the 25-node cap for a topology diagram -> split it")
    elif n > 40:
        add(0, f"{n} nodes: very large even for a workflow diagram -> consider splitting")
    return sorted(set(issues)), n, plain


def main(paths):
    bad = False
    for p in paths:
        try:
            issues, n, plain = lint(p)
        except OSError as e:
            print(f"=== {p}\n   cannot read: {e}")
            bad = True
            continue
        name = p.split("/")[-1]
        print(f"=== {name}  ({n} nodes)")
        if not issues:
            print("   OK")
        for ln, msg in issues:
            where = f"L{ln}" if ln else "  -"
            print(f"   {where:<5} {msg}")
            bad = True
        if plain > 0:
            print(f"   note  {plain} unlabeled edge(s): label every edge with a verb, or log a gap")
    print()
    print("FAIL: fix the above, then re-run." if bad else "PASS: all diagrams clean.")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]) if len(sys.argv) > 1 else (print(__doc__) or 2))
