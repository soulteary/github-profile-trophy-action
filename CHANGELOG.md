# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/soulteary/github-profile-trophy-action/compare/v1.1.0...main
[1.1.0]: https://github.com/soulteary/github-profile-trophy-action/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/soulteary/github-profile-trophy-action/releases/tag/v1.0.0
