---
name: git-flow
description: >-
  Branch, release and hotfix cerberus_email with git-flow-next (git flow 2.x): feature and bugfix
  branches from develop, release/vX.Y.Z from develop into main tagged vX.Y.Z, hotfix/vX.Y.Z from
  main. Use when asked to "release", "cut a release", "tag a version", "bump the version",
  "hotfix", "start a feature", "git flow", "finish the release", or to commit or merge to main or
  develop.
---

# git-flow (git-flow-next) in cerberus_email

`main` has only releases: each commit on it from v0.2.0 on is a release or hotfix merge, tagged
`vX.Y.Z`. `develop` is the development branch. Never commit to `main` directly.

cerberus_email is a Hex package. There is no CI that publishes: the operator runs
`mix hex.publish` from the tagged `main`. Never run `mix hex.publish` (with or without
`--dry-run`, `--replace`, `--revert`) or `mix hex.owner`: publishing is the operator's.
A published version is not re-used: a fix is the next version.

Remote: `origin` = `git@github.com:full-stack-biz/cerberus_email_ex.git`.

## Check the tool first

```bash
git flow version          # must print "2.1.0 (git-flow-next)", not 0.4.1
git flow config list      # develop → main with "Auto-update: enabled"
```

Homebrew installs both `git-flow` (0.4.1, nvie) and `git-flow-next` as the binary `git-flow`.
When `git flow version` prints 0.4.1, stop and tell the operator: `brew unlink git-flow && brew link git-flow-next`.

git-flow was initialized after v0.1.2 (`git flow init --preset=classic --defaults --main main --develop develop --tag ""`,
local `.git/config`; not committed, so a fresh clone must run the same command). `develop` was
created from `main` at v0.1.2; v0.1.1 and v0.1.2 were tagged on `main` directly, before git-flow.

No tag prefix is configured (`gitflow.prefix.versiontag` unset). The `v` is part of the name
given to `start`: `git flow release start v0.2.0` makes `release/v0.2.0` and tags `v0.2.0`,
matching `v0.1.1`, `v0.1.2` (`git for-each-ref --sort=creatordate --format='%(refname:short) %(creatordate:short)' refs/tags`;
zsh expands an unquoted `refs/tags/v*` as a file glob and fails).

## Release

The operator names the version. Do every step only when the operator asks for it.

```bash
git switch develop
mix ci                                     # must pass before starting
.claude/skills/cerberus-fidelity/scripts/verify.sh   # must print ALL IDENTICAL
git flow release start vX.Y.Z --no-fetch
# on the release branch: set version: "X.Y.Z" in mix.exs:9, the README install line
# {:cerberus_email, "~> X.Y"}, and CHANGELOG.md's "## [X.Y.Z] - YYYY-MM-DD" section; commit
git flow release finish vX.Y.Z --no-fetch -m "vX.Y.Z <summary>"
```

What a release changes:

| File | At a release |
|---|---|
| `mix.exs:9` `version` | `X.Y.Z`; the only version in the source |
| `README.md` install snippet | `{:cerberus_email, "~> X.Y"}` when the minor or major changes |
| `CHANGELOG.md` | a `## [X.Y.Z] - YYYY-MM-DD` section above the previous one (keepachangelog.com 1.1.0: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`), and its compare link in the list at the end: `[X.Y.Z]: https://github.com/full-stack-biz/cerberus_email_ex/compare/v<previous>...vX.Y.Z`. No `[Unreleased]` section |

There is no `CHANGELOG.md` before v0.2.0: the v0.2.0 release creates it (header line
`# Changelog`, the keepachangelog note, the `## [0.2.0]` section, the compare link from v0.1.2).
Earlier versions get no back-filled sections unless the operator asks.

The entries come from the diff, not from commit subjects: `git diff --stat=200 main..release/vX.Y.Z -- lib mix.exs`,
then the full message (`git log -1 --format=%B`) and the diff of each commit that touches those
files. Write entries as what a user of the library sees (the component, attr, slot, theme field
or rendered markup), and for a fix what failed before. A test-only, docs-only or skill-only
commit is not an entry. Visual changes to rendered email are `Changed` even without an API change.

`finish` merges release/vX.Y.Z into main, tags `vX.Y.Z` on main, merges main into develop
(auto-update), and deletes the release branch. It does not push. Then, only when the operator says
push:

```bash
git push origin main develop vX.Y.Z    # one git command: the branches and the tag together
```

`develop` does not exist on origin until that first push. After it, check: `git tag -n1 vX.Y.Z`
(on main's merge commit), `git merge-base --is-ancestor vX.Y.Z develop`. Then tell the operator
the tag is pushed; they publish to Hex.

## Hotfix

```bash
git flow hotfix start vX.Y.Z --no-fetch    # from main
# fix, set mix.exs version, CHANGELOG section, commit
git flow hotfix finish vX.Y.Z --no-fetch -m "vX.Y.Z <summary>"
```

## Feature or bugfix

```bash
git flow feature start <name> --no-fetch    # from develop
git flow feature finish <name> --no-fetch   # merges into develop, no tag
git flow bugfix start <name> --no-fetch     # same, bugfix/ prefix
```

## Rules

| Rule | Why |
|---|---|
| Do not commit, tag, push or finish without the operator's request | global CLAUDE.md |
| Never run `mix hex.publish` or `mix hex.owner` | publishing to Hex is the operator's |
| A git write command runs alone, without a pipe | operator's rule |
| `mix ci` and the cerberus-fidelity check pass before a release starts; there are no git hooks to run them | `.git/hooks` has only samples |
| Never `git merge` main into develop by hand after a finish | auto-update did it |
| A tag without `v` breaks the series and the CHANGELOG compare links | every tag is `vX.Y.Z` |

`finish` checks that the topic branch and its parent are not behind or diverged from origin; it
fails otherwise. `--force` skips the check: do not pass it without the operator.
