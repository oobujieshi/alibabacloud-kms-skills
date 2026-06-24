#!/bin/bash
set -e

TOOL="envelope-encrypt"
REPO="oobujieshi/alibabacloud-kms-skills-cli"
CACHE_DIR="${HOME}/.cache/alibabacloud-kms-skills"
mkdir -p "$CACHE_DIR"

# Detect platform
case "$(uname -s)" in
  Linux)  OS="linux" ;;
  Darwin) OS="darwin" ;;
  CYGWIN*|MINGW*|MSYS*) OS="windows" ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

case "$(uname -m)" in
  x86_64|amd64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *) echo "Unsupported arch: $(uname -m)" >&2; exit 1 ;;
esac

if [ "$OS" = "windows" ]; then
  SUFFIX="windows-amd64.exe"
else
  SUFFIX="${OS}-${ARCH}"
fi

BIN="$CACHE_DIR/${TOOL}-${SUFFIX}"

# Download if not cached
if [ ! -f "$BIN" ]; then
  echo "Downloading ${TOOL} for ${SUFFIX}..." >&2
  URL="https://github.com/${REPO}/releases/latest/download/${TOOL}-${SUFFIX}"
  if command -v curl >/dev/null 2>&1; then
    curl -sL "$URL" -o "$BIN"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$URL" -O "$BIN"
  else
    echo "Need curl or wget" >&2; exit 1
  fi
  chmod +x "$BIN" 2>/dev/null || true
fi

exec "$BIN" "$@"
