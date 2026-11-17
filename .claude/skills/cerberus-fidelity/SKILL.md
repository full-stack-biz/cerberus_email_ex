---
name: cerberus-fidelity
description: >-
  Verify that this library's email markup is still Cerberus verbatim by rendering every block
  of each template and diffing layout structure and head CSS against upstream
  emailmonday/Cerberus. Use after any change to lib/cerberus_email (components, markup,
  responsive, fluid, theme), when porting or updating Cerberus blocks, when upstream Cerberus
  changes, or when asked to "verify Cerberus fidelity", "check against Cerberus", "diff with
  upstream", or "did layout drift". Not a substitute for real email-client testing.
---

# Cerberus fidelity check

## Why this exists

Cerberus's value is cross-email-client testing that cannot be reproduced here (no access to
Outlook, Gmail apps, Yahoo, ...). So the library's rule is: **layout is Cerberus verbatim;
only colors and fonts come from the theme.** Unit tests only assert fragments; this check
proves the *whole* rendered email still matches upstream structurally. Run it before calling
any layout-touching change done.

## Quick start

From the project root:

```bash
.claude/skills/cerberus-fidelity/scripts/verify.sh
```

Expected output (tag counts change only if upstream changes):

```
hybrid      structdiff  IDENTICAL layout structure
hybrid      cssdiff     IDENTICAL head CSS
responsive  structdiff  IDENTICAL layout structure
...
ALL IDENTICAL
```

Exit 0 = all identical. Exit 1 = drift; the diff is printed under the failing line.
Upstream is cloned once (via `gh`) into `tmp/cerberus-fidelity/Cerberus` (gitignored);
delete that directory to re-fetch the latest upstream.

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/verify.sh [work_dir]` | Orchestrates: clone upstream if missing → render 3 templates → run both diffs. Use this. |
| `scripts/render.exs <template> <out.html>` | `mix run` it to render every block of `hybrid`/`responsive`/`fluid` in upstream block order. |
| `scripts/structdiff.py <upstream> <ported>` | Body layout diff. Unwraps `<!--[if mso]>` comments (Outlook markup counts). Per tag compares name, attributes (minus `src`/`alt`/`href`) and inline style properties minus colors/fonts. Skips text tags (`p`, `h1`, `ul`, ...). |
| `scripts/cssdiff.py <upstream> <ported>` | `<head>` CSS diff, rule by rule in order, comments stripped, hex colors and `font-family` masked. |

Run Python with `-I` (isolated mode), as `verify.sh` does. After editing `verify.sh`, run
`shellcheck -o all .claude/skills/cerberus-fidelity/scripts/verify.sh` (must be clean,
including optional style checks). If you
change the diff scripts, confirm they still catch drift: temporarily alter one width in a
component, expect `DIFFERENCES FOUND`, then revert.

## Interpreting a diff

| Diff shows | Meaning | Action |
|-----------|---------|--------|
| Changed width/padding/`dir`/class/attribute | Layout drift from Cerberus | Fix the component to match upstream exactly. Never change upstream expectations to fit the code. |
| Missing/extra tags in one block | Block structure differs (e.g. merged cells, missing optional row) | Port the upstream block verbatim; optional upstream rows become optional slots (see fluid `:after_button`). |
| `&#39;` vs `'` inside a `style` | HEEx escaped literal quotes (e.g. `url('...')`) | Pre-escape values with `Markup.escape/1` and pass the style through `Markup.raw_style/1`. |
| CSS rule order differs | Reset rule order per template | Adjust the order flags in `Markup`'s `@templates` map. |
| Tag counts differ, no layout diff in your area | `render.exs` block list out of sync with upstream | Update `render.exs` to render every upstream block, in upstream order. |

## When upstream Cerberus changes

1. Delete `tmp/cerberus-fidelity/Cerberus`, re-run `verify.sh`.
2. Diffs now show upstream's changes. Port them into the components verbatim (colors/fonts
   via theme only), and add any new upstream blocks to `render.exs`.
3. Re-run until `ALL IDENTICAL`, then `mix ci`.

## Limits

- Proves markup equals upstream; does **not** prove rendering. Real-client testing (Litmus,
  Email on Acid) is still needed for releases — the rendered `tmp/cerberus-fidelity/*.html`
  files are ready to send there.
- Ignores colors, fonts, text content, URLs by design (those are theme/content).
- Requires `gh` (authenticated), `python3`, and a compiled project (`mix deps.get`).
