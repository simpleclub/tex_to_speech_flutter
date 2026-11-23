# TeX to Speech

Contains a Flutter package for converting LaTeX to speakable text that can be read aloud by a text-to-speech engine.

## Using in Flutter project
Add the following dependency to your `pubspec.yaml` file:
```yaml
dependencies:
  tex_to_speech:
    git:
      url: git@github.com:simpleclub/tex_to_speech_flutter
      ref: 0.0.7
      path: tex_to_speech
```

## Dependencies
The package depends on `flutter_rust_bridge` project to create a bindings and glue code between Rust implementation and Dart APIs.

### Rust crates used
  - [`MathCAT`](https://nsoiffer.github.io/MathCAT/) - a library for producing speech text from MathML. It can also have other features (Braille support, text-to-speech) which are not used.
  - [`pulldown_latex`](https://docs.rs/pulldown-latex/latest/pulldown_latex/index.html) - a library for converting LaTeX to MathML. It may limit the number of TeX commands that can be correctly converted. See [Unsupported Plain-TeX & LaTeX behavior](https://github.com/carloskiki/pulldown-latex/tree/main?tab=readme-ov-file#unsupported-plain-tex--latex-behavior) for details.

## Native build
The Rust library is built by a [build hook](https://docs.flutter.dev/platform-integration/bind-native-code) (`tex_to_speech/hook/build.dart`) for Android, iOS, macOS, Linux and Windows. It works the same way with CocoaPods and Swift Package Manager, since Flutter bundles the library itself.

- **Rust installed** (`rustup` on the `PATH` or in `~/.cargo/bin`): the hook builds the crate from source with the toolchain pinned in `tex_to_speech/rust/rust-toolchain.toml`, which rustup installs on first use.
- **Rust not installed**: the hook downloads the precompiled binary for the current crate hash from the `precompiled_<hash>` release and verifies its signature. The `Precompile Binaries` workflow publishes these releases on every push to `main`. Precompiled binaries exist for Android, iOS, macOS and Linux x64.

To force either behavior, set the user define in the app's `pubspec.yaml`, or in the workspace root `pubspec.yaml` for a pub workspace (Flutter reads user defines only from there):
```yaml
hooks:
  user_defines:
    tex_to_speech:
      use_precompiled_binaries: true
```

## Requirements
 - Flutter SDK version 3.38 or higher
 - Rust toolchain installed, for working on the crate
 - flutter_rust_bridge_codegen [https://cjycode.com/flutter_rust_bridge/quickstart]

## Build process
`flutter_rust_bridge_codegen generate`

### Web
`flutter_rust_bridge_codegen build-web --release -o ..`

### Troubleshooting
- If you encounter issue with loading the WASM file try running `cargo update` in `tex_to_speech/rust` project directory.
- Check [SETUP_NOTES.md](SETUP_NOTES.md) for informations about steps to setup the project.

## Update process
Follow steps in the [flutter_rust_bridge_codegen](https://cjycode.com/flutter_rust_bridge/quickstart) documentation to update the source code.
After that you can run `generate_update.sh` to prepare the update. Updated sources (and binaries) should be pushed to the repository.
