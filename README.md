# TeX to Speech plugin

Contains a Flutter plugin for converting LaTeX to speakable text that can be read aloud by a text-to-speech engine.

## Using in Flutter project
Add the following dependency to your `pubspec.yaml` file:
```yaml
dependencies:
  tex_to_speech:
    git:
      url: git@github.com:simpleclub/tex_to_speech_flutter
      ref: 0.0.5
      path: tex_to_speech
```

## Dependencies
The plugin depends on `flutter_rust_bridge` project to create a bindings and glue code between Rust implementation and Dart APIs.

### Rust crates used
  - [`MathCAT`](https://nsoiffer.github.io/MathCAT/) - a library for producing speech text from MathML. It can also have other features (Braille support, text-to-speech) which are not used.
  - [`pulldown_latex`](https://docs.rs/pulldown-latex/latest/pulldown_latex/index.html) - a library for converting LaTeX to MathML. It may limit the number of TeX commands that can be correctly converted. See [Unsupported Plain-TeX & LaTeX behavior](https://github.com/carloskiki/pulldown-latex/tree/main?tab=readme-ov-file#unsupported-plain-tex--latex-behavior) for details.

## Requirements
 - Flutter SDK version 3.x or higher
 - Rust toolchain installed
 - flutter_rust_bridge_codegen [https://cjycode.com/flutter_rust_bridge/quickstart]

## Build process
`flutter_rust_bridge_codegen generate`

### Web
`flutter_rust_bridge_codegen build-web --release -o ..`

### iOS and macOS
The plugin supports both CocoaPods and Swift Package Manager:
- **CocoaPods** (`ios/tex_to_speech.podspec`, `macos/tex_to_speech.podspec`) builds the library with Cargokit, which downloads precompiled binaries from the `precompiled_*` releases.
- **Swift Package Manager** (`ios/tex_to_speech/Package.swift`, `macos/tex_to_speech/Package.swift`) uses a prebuilt dynamic `tex_to_speech.xcframework` from the `xcframework_*` releases, so apps don't need a Rust toolchain.

On every push to `main`, the `Swift Package xcframework` workflow checks whether the Rust sources changed. If they did, it builds the xcframework, publishes it as a release and opens a pull request that points both `Package.swift` files at it. Merge that pull request before tagging a version.

To do the same locally (needs the `aarch64-apple-ios`, `aarch64-apple-ios-sim`, `x86_64-apple-ios`, `aarch64-apple-darwin` and `x86_64-apple-darwin` Rust targets):
```sh
./build_xcframework.sh                        # Builds build/xcframework/tex_to_speech.xcframework.zip and prints its checksum.
./build_xcframework.sh --tag                  # Prints the release tag for the committed Rust sources.
./update_swift_package.sh <tag> <checksum>    # Points both Package.swift files at the release.
```

### Troubleshooting
- If you encounter issue with loading the WASM file try running `cargo update` in `tex_to_speech/rust` project directory.
- Check [SETUP_NOTES.md](SETUP_NOTES.md) for informations about steps to setup the project.

## Update process
Follow steps in the [flutter_rust_bridge_codegen](https://cjycode.com/flutter_rust_bridge/quickstart) documentation to update the source code.
After that you can run `generate_update.sh` to prepare the update. Updated sources (and binaries) should be pushed to the repository.
