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
