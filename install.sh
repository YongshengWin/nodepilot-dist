#!/usr/bin/env sh
set -eu

ROLE=${1:-}
REPOSITORY=${NODEPILOT_GITHUB_REPOSITORY:-YongshengWin/nodepilot-dist}
VERSION=${NODEPILOT_VERSION:-}
case "$VERSION" in
  *[!A-Za-z0-9._-]*) echo "NODEPILOT_VERSION is invalid" >&2; exit 1 ;;
esac
if [ -n "${NODEPILOT_RELEASE_BASE_URL:-}" ]; then
  BASE_URL=$NODEPILOT_RELEASE_BASE_URL
elif [ -n "$VERSION" ]; then
  BASE_URL="https://github.com/$REPOSITORY/releases/download/$VERSION"
else
  BASE_URL="https://github.com/$REPOSITORY/releases/latest/download"
fi

case "$ROLE" in
  server|control) INTERNAL_ROLE=server ;;
  node|agent) INTERNAL_ROLE=node ;;
  *) echo "usage: install.sh server|node" >&2; exit 1 ;;
esac
if [ "$(uname -s)" != Linux ]; then
  echo "NodePilot server roles support Linux only" >&2
  exit 1
fi
case "$(uname -m)" in
  x86_64|amd64) ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  *) echo "unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac
if [ "$(id -u)" -ne 0 ]; then
  echo "Run this installer as root" >&2
  exit 1
fi
for command in curl tar; do
  command -v "$command" >/dev/null 2>&1 || { echo "$command is required" >&2; exit 1; }
done

work=$(mktemp -d "${TMPDIR:-/tmp}/nodepilot-install.XXXXXX")
trap 'rm -rf -- "$work"' 0 1 2 15
asset="nodepilot-linux-$ARCH.tar.gz"
curl -fL --retry 5 --retry-all-errors --connect-timeout 15 --proto '=https' --tlsv1.2 "$BASE_URL/$asset" -o "$work/$asset"
curl -fL --retry 5 --retry-all-errors --connect-timeout 15 --proto '=https' --tlsv1.2 "$BASE_URL/SHA256SUMS" -o "$work/SHA256SUMS"
expected=$(awk -v asset="$asset" '$2 == asset || $2 == "*" asset {print $1}' "$work/SHA256SUMS")
if [ -z "$expected" ]; then
  echo "release checksum is missing for $asset" >&2
  exit 1
fi
if command -v sha256sum >/dev/null 2>&1; then
  actual=$(sha256sum "$work/$asset" | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
  actual=$(shasum -a 256 "$work/$asset" | awk '{print $1}')
else
  echo "sha256sum or shasum is required" >&2
  exit 1
fi
if [ "$actual" != "$expected" ]; then
  echo "release checksum verification failed" >&2
  exit 1
fi

paths="$work/archive-paths"
tar -tzf "$work/$asset" > "$paths"
while IFS= read -r member; do
  case "$member" in
    ''|/*|../*|*/../*|*/..)
      echo "release archive contains an unsafe path" >&2
      exit 1
      ;;
  esac
done < "$paths"

mkdir "$work/package"
tar -xzf "$work/$asset" -C "$work/package"
special=$(find "$work/package" ! -type f ! -type d -print -quit)
if [ -n "$special" ]; then
  echo "release archive contains a special file or symbolic link" >&2
  exit 1
fi
set -- "$work"/package/nodepilot-*
if [ "$#" -ne 1 ] || [ ! -d "$1" ]; then
  echo "release archive has an unexpected layout" >&2
  exit 1
fi
"$1/scripts/install-role.sh" "$INTERNAL_ROLE" "$1"
