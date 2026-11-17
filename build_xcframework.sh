#!/usr/bin/env bash
# Builds the Rust library as a dynamic `tex_to_speech.xcframework` for the
# Swift Package Manager integration (see `tex_to_speech/ios/tex_to_speech/Package.swift`).
#
# Usage:
#   ./build_xcframework.sh          Builds build/xcframework/tex_to_speech.xcframework.zip
#                                   and prints its Swift package checksum.
#   ./build_xcframework.sh --tag    Prints the release tag for the committed Rust sources.
#
# The framework is dynamic and named `tex_to_speech` because the
# flutter_rust_bridge loader opens `tex_to_speech.framework/tex_to_speech` on
# iOS and macOS.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$ROOT_DIR/tex_to_speech"
MANIFEST="$PLUGIN_DIR/rust/Cargo.toml"
OUT_DIR="$ROOT_DIR/build/xcframework"
LIB_NAME="tex_to_speech"
BUNDLE_ID="com.simpleclub.tex-to-speech"
IOS_MIN_VERSION="13.0"
MACOS_MIN_VERSION="10.15"

# Every path whose content ends up in the binary. The tag changes whenever one
# of them changes, so a release asset is never replaced under a pinned checksum.
HASH_INPUTS=(tex_to_speech/rust tex_to_speech_core third_party/MathCAT build_xcframework.sh)

release_tag() {
  local trees=""
  for input in "${HASH_INPUTS[@]}"; do
    trees+="$(git -C "$ROOT_DIR" rev-parse "HEAD:$input")"
  done
  echo "xcframework_$(printf '%s' "$trees" | shasum -a 256 | cut -c1-16)"
}

if [[ "${1:-}" == "--tag" ]]; then
  release_tag
  exit 0
fi

VERSION="$(sed -n 's/^version: *//p' "$PLUGIN_DIR/pubspec.yaml")"

build_target() {
  local target="$1"
  case "$target" in
    *-apple-darwin) MACOSX_DEPLOYMENT_TARGET="$MACOS_MIN_VERSION" \
      cargo build --release --locked --manifest-path "$MANIFEST" --target "$target" ;;
    *) IPHONEOS_DEPLOYMENT_TARGET="$IOS_MIN_VERSION" \
      cargo build --release --locked --manifest-path "$MANIFEST" --target "$target" ;;
  esac
}

dylib_path() {
  echo "$PLUGIN_DIR/rust/target/$1/release/lib$LIB_NAME.dylib"
}

write_info_plist() {
  local path="$1" platform="$2" min_version_key="$3" min_version="$4"
  cat > "$path" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>$LIB_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$LIB_NAME</string>
  <key>CFBundlePackageType</key>
  <string>FMWK</string>
  <key>CFBundleShortVersionString</key>
  <string>$VERSION</string>
  <key>CFBundleSupportedPlatforms</key>
  <array>
    <string>$platform</string>
  </array>
  <key>CFBundleVersion</key>
  <string>$VERSION</string>
  <key>$min_version_key</key>
  <string>$min_version</string>
</dict>
</plist>
EOF
}

# iOS frameworks are flat bundles.
make_ios_framework() {
  local slice_dir="$1" platform="$2"
  shift 2
  local framework="$slice_dir/$LIB_NAME.framework"
  mkdir -p "$framework"
  lipo -create "$@" -output "$framework/$LIB_NAME"
  install_name_tool -id "@rpath/$LIB_NAME.framework/$LIB_NAME" "$framework/$LIB_NAME"
  strip -x "$framework/$LIB_NAME"
  write_info_plist "$framework/Info.plist" "$platform" MinimumOSVersion "$IOS_MIN_VERSION"
}

# macOS frameworks must be versioned bundles to be signed and embedded.
make_macos_framework() {
  local slice_dir="$1"
  shift
  local framework="$slice_dir/$LIB_NAME.framework"
  local version_dir="$framework/Versions/A"
  mkdir -p "$version_dir/Resources"
  lipo -create "$@" -output "$version_dir/$LIB_NAME"
  install_name_tool -id "@rpath/$LIB_NAME.framework/Versions/A/$LIB_NAME" "$version_dir/$LIB_NAME"
  strip -x "$version_dir/$LIB_NAME"
  write_info_plist "$version_dir/Resources/Info.plist" MacOSX LSMinimumSystemVersion "$MACOS_MIN_VERSION"
  ln -s A "$framework/Versions/Current"
  ln -s "Versions/Current/$LIB_NAME" "$framework/$LIB_NAME"
  ln -s Versions/Current/Resources "$framework/Resources"
}

TARGETS=(aarch64-apple-ios aarch64-apple-ios-sim x86_64-apple-ios aarch64-apple-darwin x86_64-apple-darwin)
for target in "${TARGETS[@]}"; do
  build_target "$target"
done

rm -rf "$OUT_DIR"
SLICES_DIR="$OUT_DIR/slices"
make_ios_framework "$SLICES_DIR/ios" iPhoneOS "$(dylib_path aarch64-apple-ios)"
make_ios_framework "$SLICES_DIR/ios-simulator" iPhoneSimulator \
  "$(dylib_path aarch64-apple-ios-sim)" "$(dylib_path x86_64-apple-ios)"
make_macos_framework "$SLICES_DIR/macos" \
  "$(dylib_path aarch64-apple-darwin)" "$(dylib_path x86_64-apple-darwin)"

XCFRAMEWORK="$OUT_DIR/$LIB_NAME.xcframework"
xcodebuild -create-xcframework \
  -framework "$SLICES_DIR/ios/$LIB_NAME.framework" \
  -framework "$SLICES_DIR/ios-simulator/$LIB_NAME.framework" \
  -framework "$SLICES_DIR/macos/$LIB_NAME.framework" \
  -output "$XCFRAMEWORK"
rm -rf "$SLICES_DIR"

ZIP="$XCFRAMEWORK.zip"
(cd "$OUT_DIR" && ditto -c -k --sequesterRsrc --keepParent "$LIB_NAME.xcframework" "$ZIP")

echo "Built $ZIP"
echo "checksum: $(cd "$OUT_DIR" && swift package compute-checksum "$ZIP")"
