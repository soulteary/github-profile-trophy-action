# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.1] - 2026-09-13

### Fixed
- A symlink that stays inside the workspace works again. v1.2.0 refused any
  `path` whose final component was a symlink, so `card.svg -> real/card.svg` —
  workspace-relative, exactly what the input documents, and accepted before
  v1.2.0 — started failing for no security gain. A symlink is now followed and
  judged by where it lands, the same containment test v1.2.0 already applied to
  parent directories. What v1.2.0 closed stays closed: a symlink pointing
  outside the workspace, a symlinked parent directory, and a dangling one are
  all still refused.

### Changed
- Every `uses:` example across the six README translations now pins `@v1.2.1`.
  They still pointed at `@v1.1.0`, so a reader copying the documented example
  ran the version from before the path-containment work.

## [1.2.0] - 2026-09-13

### Security
- The `path` input is now confined to the workspace. It was documented as a
  workspace-relative filename, but nothing enforced that: the value went
  straight into `mkdir -p`, the generator's `--output`, and `$GITHUB_OUTPUT`.
  `path: /etc/x.svg` and `path: ../../../x.svg` wrote outside the workspace.
  Absolute paths, paths that climb out with `..`, and paths whose deepest
  existing parent resolves outside the workspace are refused, as is a final
  component that is itself a symlink — a purely lexical check could not see
  `escape -> /tmp/outside`, through which `escape/card.svg` landed at
  `/tmp/outside/card.svg`.
- A line break in `path` can no longer inject step outputs. `$GITHUB_OUTPUT`
  is newline-delimited, so a value containing a newline used to declare
  arbitrary extra outputs that anything reading `steps.*.outputs` would trust.
  These matter most when `path` is fed from workflow context rather than typed
  by hand.

### Fixed
- Path splitting no longer performs pathname expansion. An unquoted `set -- $raw`
  globs as well as splits, so with matching files alongside, `README.*` became
  `README.md/README.txt` and `[a]card.svg` became `acard.svg` — valid Unix
  filenames rewritten according to whatever happened to sit next to them.

### Added
- The resolved output path is logged. Normalisation can rewrite what was asked
  for, and this is the value that reaches the `path` output.
- The repository's first CI: shellcheck, a syntax check, and path-input tests on
  `ubuntu-latest` and `macos-latest`. Until now `index.sh` — the entire action —
  was never executed by any check before a consumer ran it. The macOS leg is not
  redundant: its `/bin/bash` is 3.2, and it caught a bash-4-only construct on its
  first run.

### Changed
- `outputs.path` reports the normalised path, so `./profile/x.svg` comes back as
  `profile/x.svg`.

### Upgrading
A workflow that passed an absolute path, a path climbing out of the workspace,
or a path through a symlink pointing outside it will now fail instead of writing
outside the workspace. The documented contract has always been a
workspace-relative filename. Note that the `v1` alias moves with this release,
so consumers pinned to `@v1` receive this automatically.

## [1.1.0] - 2026-09-13

### Fixed
- `outputs.path` is now actually exposed. The output was declared in
  `action.yml` and documented under "Outputs" in the README, but a composite
  action only publishes an output when the output declares a `value:` and the
  producing step declares an `id:` — neither was present. `index.sh` duly wrote
  `path=` to `$GITHUB_OUTPUT`, but nothing read it, so the output was the empty
  string for every consumer of v1.0.0.
- The `version` input's description claimed "Defaults to latest" while the
  default is `v1.0.0`. The default is deliberate — pinning the upstream binary
  keeps an upstream release from silently changing this action's behaviour — so
  the description was corrected and the value left alone. `latest` remains
  available as an opt-in.
- The SVG sanity check only ever inspected line 1 of the generated file. The
  upstream generator writes a leading blank line and indents the root element,
  so `<svg` lands on line 2 and the check matched none of the 30 artifacts this
  action produced — the warning fired on every successful run. It now scans the
  head of the file, matches `<svg` rather than the bare word `svg` (an error
  body merely mentioning SVG used to pass), and reports the first non-blank
  line instead of the blank one. It remains a warning, not a hard failure.

### Changed
- Regenerated the committed trophy theme examples.

## [1.0.0] - 2026-01-18

### Added
- Initial release: generate GitHub Profile Trophy cards in a workflow by
  downloading the upstream Go binary, with query-string or JSON options, a
  configurable output path, and six translated READMEs.

## Upgrade notes for 1.1.0

`outputs.path` changing from always-empty to populated is a behaviour change,
not a pure fix. A workflow that branches on it will take a different path:

| Expression | v1.0.0 | v1.1.0 |
| --- | --- | --- |
| `steps.<id>.outputs.path == ''` | always true | false once a card is written |
| `steps.<id>.outputs.path != ''` | always false | true once a card is written |
| `steps.<id>.outputs.path` (truthy) | always false | true once a card is written |

The second and third rows are the ones to check before upgrading: a step that
has silently never run will start running.

[Unreleased]: https://github.com/soulteary/github-profile-trophy-action/compare/v1.2.1...main
[1.2.1]: https://github.com/soulteary/github-profile-trophy-action/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/soulteary/github-profile-trophy-action/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/soulteary/github-profile-trophy-action/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/soulteary/github-profile-trophy-action/releases/tag/v1.0.0
