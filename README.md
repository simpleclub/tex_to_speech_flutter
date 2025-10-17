# TeX to Speech plugin

Contains a Flutter plugin for converting LaTeX to speakable text that can be read aloud by a text-to-speech engine.

## Using in Flutter project
Add the following dependency to your `pubspec.yaml` file:
```yaml
dependencies:
  tex_to_speech:
    git:
      url: git@github.com:simpleclub/tex_to_speech_flutter
      ref: 0.0.1
      path: tex_to_speech
```

## Dependencies
The plugin depends on `flutter_rust_bridge` project to create a bindings and glue code between Rust implementation and Dart APIs.

### Rust crates used
  - [`MathCAT`](https://nsoiffer.github.io/MathCAT/) - a library for producing speech text from MathML. It can also have other features (Braille support, text-to-speech) which are not used.
  - [`latex2mathml`](https://docs.rs/latex2mathml/latest/latex2mathml/) - a library for converting LaTeX to MathML. It may limit the number of TeX commands that can be correctly converted. See [Supported LaTeX commands](https://docs.rs/latex2mathml/latest/latex2mathml/#supported-latex-commands) for details.

## Requirements
 - Flutter SDK version 3.x or higher
 - Rust toolchain installed
 - flutter_rust_bridge_codegen [https://cjycode.com/flutter_rust_bridge/quickstart]

## Build process
`flutter_rust_bridge_codegen generate`

### Web
`flutter_rust_bridge_codegen build-web -o ..`

### Troubleshooting
- If you encounter issue with loading the WASM file try running `cargo update` in `tex_to_speech/rust` project directory.
- Check [SETUP_NOTES.md](SETUP_NOTES.md) for informations about steps to setup the project.

## Update process
Follow steps in the [flutter_rust_bridge_codegen](https://cjycode.com/flutter_rust_bridge/quickstart) documentation to update the source code.
After that you can run `generate_update.sh` to prepare the update. Updated sources (and binaries) should be pushed to the repository.
