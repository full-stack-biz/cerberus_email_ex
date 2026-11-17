# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Hex library (`cerberus_email`): Phoenix function components for responsive HTML email, ported from the Cerberus email framework. No app, no config, no runtime processes — just components.

## Commands

```bash
mix deps.get
mix test                                              # all tests
mix test test/cerberus_email/components_test.exs:42   # single test by line
mix ci          # full gate: compile --warnings-as-errors, format check, test,
                # credo --strict, dialyzer, ex_dna --max-clones 0, reach.check --arch --smells
```

`mix ci` runs in the test env. `ex_dna --max-clones 0` fails on any duplicated code, so factor repeated markup into shared private helpers rather than copy-pasting between components.

## Architecture

- One module per Cerberus template, sharing component names: `Components` (hybrid, 680px, default), `Responsive` and `Fluid` (600px). `CerberusEmail.Markup` (`@moduledoc false`) holds markup shared across templates: head CSS (per-template differences in its `@templates` map, including upstream rule order), button/hero/header/footer/full-bleed pieces. Blocks identical across templates are `defdelegate`d; template-specific blocks are written out per module.
- `email_layout` lives only in `Components` and takes `template` (`:hybrid | :responsive | :fluid`); `Responsive.email_layout/1` and `Fluid.email_layout/1` preset it. Shell structure differs per template (responsive has no wrapper div — its body table is the container).
- Design values live in `CerberusEmail.Theme` (`lib/cerberus_email/theme.ex`). Every component takes `theme` (default `%Theme{}`) and builds all inline styles from it — never hardcode colors/fonts in markup. Function components share no context, so callers pass `theme={@theme}` to each component; composite components forward it to children. Precedence: explicit attr (e.g. `primary_color`) > theme > struct defaults, via private `resolve_theme/2`.
- HEEx does not interpolate inside HTML comments or `<style>`, so anything theme-dependent in MSO conditional comments or head CSS is built as escaped raw strings (`head_styles/1`, `vml_open/3`).
- **Cerberus layout is untouchable.** The library ports `cerberus-hybrid.html`, `cerberus-responsive.html` and `cerberus-fluid.html` from https://github.com/emailmonday/Cerberus (fetch with `gh repo clone emailmonday/Cerberus`) verbatim: same tables, Outlook ghost tables, inline-block divs, widths, padding, `dir`, classes, image sizes, column counts, head CSS. Only colors and fonts may come from the theme. Never merge cells, generalize patterns (e.g. N columns), or invent layout — Cerberus's knowledge comes from testing across email clients, which can't be done here. Don't "modernize" to flex/grid or external CSS.
- After any layout-touching change, run the `cerberus-fidelity` skill (`.claude/skills/cerberus-fidelity/scripts/verify.sh`): it renders every block of each template and diffs structure and head CSS against upstream Cerberus. It must print `ALL IDENTICAL`.
- Tests render HEEx to a string (`Phoenix.HTML.Safe.to_iodata/1`) and assert on the HTML with `=~`.

## Release

git-flow-next: work on `develop` (or `feature/`, `bugfix/` branches); `main` only receives release/hotfix merges tagged `vX.Y.Z`. Follow the `git-flow` skill (`.claude/skills/git-flow/`) for releases: the version (`mix.exs`, README install snippet, `CHANGELOG.md`) is set on the `release/vX.Y.Z` branch, never on `develop` or `main`. Never run `mix hex.publish`. Never add `Co-Authored-By` (or any AI attribution) trailers to commit messages or PRs.
