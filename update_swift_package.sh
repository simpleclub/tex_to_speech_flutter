#!/usr/bin/env bash
# Points the iOS and macOS Swift packages at an xcframework release asset.
#
# Usage: ./update_swift_package.sh <release-tag> <checksum>
#
# The release tag comes from `./build_xcframework.sh --tag`, the checksum from
# the output of `./build_xcframework.sh` for the uploaded zip.
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <release-tag> <checksum>" >&2
  exit 64
fi

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
TAG="$1"
CHECKSUM="$2"

for platform in ios macos; do
  manifest="$ROOT_DIR/tex_to_speech/$platform/tex_to_speech/Package.swift"
  sed -i '' -E \
    -e "s#(releases/download/)[^/]+(/tex_to_speech\.xcframework\.zip)#\1$TAG\2#" \
    -e "s#(checksum: \")[^\"]*(\")#\1$CHECKSUM\2#" \
    "$manifest"
done
