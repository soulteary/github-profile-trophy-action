#!/bin/bash
set -euo pipefail

# Log helpers
log_info() { echo "[INFO] $*"; }
log_warn() { echo "[WARN] $*"; }
log_error() { echo "[ERROR] $*"; }

# Inputs
OPTIONS="${INPUT_OPTIONS:-}"
OUTPUT_PATH="${INPUT_PATH:-}"
REPO_OWNER="${GITHUB_REPOSITORY_OWNER:-}"

# ---- 1. Default output path ----
if [ -z "$OUTPUT_PATH" ]; then
  OUTPUT_PATH="profile/trophy.svg"
fi

# ---- 2. Parse options (query string or JSON) ----
parse_options() {
  local raw="${1:-}"
  if [ -z "$raw" ]; then
    echo ""
    return
  fi
  raw="$(echo "$raw" | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  if [ -z "$raw" ]; then
    echo ""
    return
  fi
  if [ "${raw#\{}" != "$raw" ]; then
    # JSON
    if command -v python3 >/dev/null 2>&1; then
      echo "$raw" | python3 -c "
import json,sys,urllib.parse
try:
    d=json.load(sys.stdin)
    def enc(v):
        if v is None: return None
        if isinstance(v,list): return ','.join(str(x) for x in v)
        if isinstance(v,bool): return str(v).lower()
        return str(v)
    parts=[k+'='+urllib.parse.quote(enc(v)) for k,v in d.items() if enc(v) is not None]
    print('&'.join(parts))
except Exception as e:
    sys.stderr.write('Invalid JSON in options: '+str(e)+'\n')
    sys.exit(1)
" || {
        log_error "Failed to parse JSON options"
        exit 1
      }
    elif command -v node >/dev/null 2>&1; then
      echo "$raw" | node -e "
const d=JSON.parse(require('fs').readFileSync(0,'utf8'));
const pairs=Object.entries(d)
  .filter(([,v])=>v!=null&&v!==undefined)
  .map(([k,v])=>k+'='+encodeURIComponent(Array.isArray(v)?v.join(','):String(v)));
process.stdout.write(pairs.join('&'));
" || {
        log_error "Failed to parse JSON options"
        exit 1
      }
    else
      log_error "Neither python3 nor node available for JSON parsing"
      exit 1
    fi
  else
    # Query string: strip leading ?
    echo "$raw" | sed 's/^?//'
  fi
}

QUERY_STRING="$(parse_options "$OPTIONS")"

# ---- 3. Validate required options and default username ----
get_param() {
  local q="&$1" k="$2"
  echo "$q" | sed -n "s/.*\\&${k}=\\([^&]*\\).*/\1/p"
}

# Username is required for trophy cards
if [ -z "$(get_param "$QUERY_STRING" "username")" ] && [ -n "$REPO_OWNER" ]; then
  log_warn "username not provided; defaulting to repository owner: $REPO_OWNER"
  if [ -n "$QUERY_STRING" ]; then
    QUERY_STRING="${QUERY_STRING}&username=${REPO_OWNER}"
  else
    QUERY_STRING="username=${REPO_OWNER}"
  fi
fi
if [ -z "$(get_param "$QUERY_STRING" "username")" ]; then
  log_error "username is required for the trophy card"
  exit 1
fi

# ---- 4. Download Go binary from GitHub Releases ----
# Determine OS and architecture
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *) log_error "Unsupported architecture: $ARCH"; exit 1 ;;
esac

case "$OS" in
  linux) SUFFIX="linux-${ARCH}" ;;
  darwin) SUFFIX="darwin-${ARCH}" ;;
  *) log_error "Unsupported OS: $OS"; exit 1 ;;
esac

# Version to use (default: latest)
VERSION="${INPUT_VERSION:-latest}"
REPO="${INPUT_REPO:-soulteary/github-profile-trophy}"
BINARY_NAME="github-profile-trophy-${SUFFIX}"
BINARY="$(mktemp)"
trap 'rm -f "$BINARY"' EXIT

log_info "Downloading Go binary (${SUFFIX}) from GitHub Releases..."

if [ "$VERSION" = "latest" ]; then
  # Get latest release
  RELEASE_URL="https://api.github.com/repos/${REPO}/releases/latest"
  log_info "Fetching latest release info from: $RELEASE_URL"
  RELEASE_INFO="$(curl -sL -H "Accept: application/vnd.github.v3+json" "$RELEASE_URL")" || {
    log_error "Failed to fetch latest release info"
    exit 1
  }
  # Parse tag_name using a more robust method
  TAG_NAME="$(echo "$RELEASE_INFO" | grep -o '"tag_name": "[^"]*' | head -1 | cut -d'"' -f4)"
  if [ -z "$TAG_NAME" ]; then
    # Try alternative parsing method
    TAG_NAME="$(echo "$RELEASE_INFO" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1)"
  fi
  if [ -z "$TAG_NAME" ]; then
    log_error "Failed to parse tag_name from release info"
    log_error "Response: ${RELEASE_INFO:0:200}..."
    exit 1
  fi
  log_info "Latest release: $TAG_NAME"
else
  # Ensure version starts with 'v' if not already
  if [ "${VERSION#v}" = "$VERSION" ]; then
    TAG_NAME="v${VERSION}"
  else
    TAG_NAME="$VERSION"
  fi
fi

# Download binary
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${TAG_NAME}/${BINARY_NAME}"
log_info "Downloading from: $DOWNLOAD_URL"

if ! curl -sL -f -o "$BINARY" "$DOWNLOAD_URL"; then
  log_error "Failed to download binary from: $DOWNLOAD_URL"
  log_error "Make sure the release exists and contains the binary for ${SUFFIX}"
  exit 1
fi

# Make binary executable
chmod +x "$BINARY"
log_info "Binary downloaded and ready: $BINARY"

# ---- 5. Create output directory ----
OUTPUT_DIR="$(dirname "$OUTPUT_PATH")"
if [ -n "$OUTPUT_DIR" ] && [ "$OUTPUT_DIR" != "." ]; then
  mkdir -p "$OUTPUT_DIR" || { log_error "Failed to create output directory: $OUTPUT_DIR"; exit 1; }
fi

# ---- 6. Call Go CLI (flag format) ----
# Build args: --username=xxx [--key=value ...] --output=PATH (--output last to override options)
CLI_ARGS=()

if [ -n "$QUERY_STRING" ]; then
  while IFS= read -r pair; do
    [ -z "$pair" ] && continue
    key="${pair%%=*}"
    val="${pair#*=}"
    [ -z "$key" ] && continue
    if [ "$key" = "output" ]; then
      continue
    fi
    CLI_ARGS+=( "--${key}=${val}" )
  done <<< "$(echo "$QUERY_STRING" | tr '&' '\n')"
fi

CLI_ARGS+=( "--output=$OUTPUT_PATH" )

log_info "Generating trophy card -> $OUTPUT_PATH"
if ! "$BINARY" "${CLI_ARGS[@]}"; then
  log_error "Go CLI failed"
  exit 1
fi

# ---- 7. Verify output and set GITHUB_OUTPUT ----
if [ ! -f "$OUTPUT_PATH" ] || [ ! -s "$OUTPUT_PATH" ]; then
  log_error "SVG file was not created or is empty: $OUTPUT_PATH"
  exit 1
fi

if ! head -n 1 "$OUTPUT_PATH" | grep -q -i svg; then
  log_warn "Output may not be valid SVG; first line: $(head -n 1 "$OUTPUT_PATH")"
fi

log_info "Wrote $OUTPUT_PATH"
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "path=$OUTPUT_PATH" >> "$GITHUB_OUTPUT"
fi
