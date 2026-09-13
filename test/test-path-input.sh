#!/usr/bin/env bash
#
# Exercises the `path` input validation in index.sh.
#
# Hermetic by construction: every case here is decided in the "Default and
# validate output path" section, which runs before the first curl. A path that
# is accepted falls through to the username check and stops there, so no case
# needs a token or network access.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${ROOT}/index.sh"
# github-readme-stats-action requires a card type; github-profile-trophy-action
# has only one and ignores INPUT_CARD entirely, so setting it unconditionally is
# inert there. Passing it through an array instead would mean expanding an empty
# one, which is an "unbound variable" error under `set -u` before bash 4.4 --
# i.e. on every macOS runner. That is not hypothetical: it is what this exact
# file did on its first CI run.

fails=0
pass() { printf '  ok       %s\n' "$1"; }
fail() { printf '  FAIL     %s\n     %s\n' "$1" "$2"; fails=$((fails + 1)); }

run_with_path() {
  env -u GITHUB_REPOSITORY_OWNER -u GITHUB_OUTPUT -u INPUT_OPTIONS \
    INPUT_CARD=stats INPUT_PATH="$1" \
    bash "$SCRIPT" 2>&1
}

# --- paths that must be refused, before anything else runs ----------------
reject() {
  local label="$1" path="$2" want="$3" out
  out="$(run_with_path "$path")"
  if [ -z "$out" ]; then fail "$label" "no output"; return; fi
  case "$out" in
    *"$want"*) ;;
    *) fail "$label" "expected \"$want\", got: ${out//$'\n'/ | }"; return ;;
  esac
  # Reaching the username check would mean validation let the path through.
  case "$out" in
    *"username is required"*) fail "$label" "ran past path validation"; return ;;
  esac
  pass "$label"
}

echo "rejected:"
reject "absolute path"            "/etc/evil.svg"          "must be relative to the workspace"
reject "climbs out of workspace"  "../../../etc/evil.svg"  "must stay inside the workspace"
reject "climbs out mid-path"      "a/../../evil.svg"       "must stay inside the workspace"
reject "bare .."                  ".."                     "must stay inside the workspace"
reject "resolves to nothing"      "."                      "must stay inside the workspace"
reject "newline injects output"   "$(printf 'a.svg\nfoo=bar')" "must not contain a line break"
reject "carriage return"          "$(printf 'a.svg\rfoo=bar')" "must not contain a line break"

# --- paths that must be accepted -----------------------------------------
# An accepted path reaches the username check, which exits without network.
accept() {
  local label="$1" path="$2" out
  out="$(run_with_path "$path")"
  case "$out" in
    *"path must"*) fail "$label" "wrongly refused: ${out//$'\n'/ | }"; return ;;
    *"username is required"*|*"repo is required"*|*"id is required"*) pass "$label" ;;
    *) fail "$label" "unexpected: ${out//$'\n'/ | }" ;;
  esac
}

# --- glob characters are filenames, not patterns -------------------------
# An unquoted expansion globs as well as splits, so without `set -f` these get
# rewritten based on whatever happens to sit in the workspace.
glob_safe() {
  local label="$1" path="$2" out
  out="$(run_with_path "$path")"
  case "$out" in
    *"path must"*|*"resolves outside"*) fail "$label" "wrongly refused: ${out//$'\n'/ | }"; return ;;
  esac
  # Assert on the resolved path the action reports, not on a later step: an
  # unfixed glob turns "README.*" into "README.md/README.txt" and
  # "[a]card.svg" into "acard.svg", both of which are otherwise accepted
  # silently and produce an identical downstream error.
  case "$out" in
    *"Resolved output path: $path"*) pass "$label" ;;
    *) fail "$label" "not resolved verbatim: ${out//$'\n'/ | }" ;;
  esac
}

# These two groups need a scratch workspace: they create decoy files whose
# names the glob would otherwise match, and a symlink pointing out of it.
# Never run them in the repository root -- "README.*" would clobber the real one.
scratch="$(mktemp -d)"
outside="$(mktemp -d)"
trap 'rm -rf "$scratch" "$outside"' EXIT
cd "$scratch" || exit 1
: > "README.md"; : > "README.txt"; : > "acard.svg"

echo "glob characters preserved:"
glob_safe "asterisk"        "README.*"
glob_safe "bracket class"   "[a]card.svg"
glob_safe "question mark"   "card?.svg"

# --- symlinks are judged by where they land, not by being symlinks ---
echo "symlink containment:"
ln -sfn "$outside" escape
out="$(run_with_path "escape/card.svg")"
case "$out" in
  *"resolves outside the workspace through a symlink"*) pass "symlinked parent escapes" ;;
  *) fail "symlinked parent escapes" "not refused: ${out//$'\n'/ | }" ;;
esac
: > "$outside/card.svg"
ln -sfn "$outside/card.svg" direct.svg
out="$(run_with_path "direct.svg")"
case "$out" in
  *"resolves outside the workspace through a symlink"*) pass "symlinked target escapes" ;;
  *) fail "symlinked target escapes" "not refused: ${out//$'\n'/ | }" ;;
esac
# A symlink that stays inside satisfies the documented contract and must work:
# refusing it would break valid workflows for no security gain.
mkdir -p real && : > real/card.svg
ln -sfn real/card.svg inside.svg
out="$(run_with_path "inside.svg")"
case "$out" in
  *"resolves outside"*|*"path must"*) fail "symlink staying inside" "wrongly refused: ${out//$'\n'/ | }" ;;
  *"Resolved output path: inside.svg"*) pass "symlink staying inside" ;;
  *) fail "symlink staying inside" "unexpected: ${out//$'\n'/ | }" ;;
esac
cd "$ROOT" || exit 1

echo "accepted:"
accept "plain file"               "card.svg"
accept "nested"                   "profile/card.svg"
accept "leading ./"               "./profile/card.svg"
accept "redundant separators"     "out//nested/./card.svg"
accept "interior .. that stays in" "a/b/../card.svg"

echo
if [ "$fails" -ne 0 ]; then
  echo "${fails} test(s) failed"
  exit 1
fi
echo "all path-input tests passed"
