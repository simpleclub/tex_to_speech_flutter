# TeX to Speech plugin

Contains a Flutter plugin for converting LaTeX to speakable text that can be read aloud by a text-to-speech engine.

## Requirements
 - Flutter SDK version 3.x or higher
 - Rust toolchain installed
 - flutter_rust_bridge_codegen https://cjycode.com/flutter_rust_bridge/quickstart

## Build process
`flutter_rust_bridge_codegen generate`

### Web
`flutter_rust_bridge_codegen build-web -o ../lib`

### Troubleshooting
- If you encounter issue with loading the WASM file try running `cargo update` in `tex_to_speech/rust` project directory.

## Update process
Follow steps in the [flutter_rust_bridge_codegen](https://cjycode.com/flutter_rust_bridge/quickstart) documentation to update the source code.
After that you can run `generate_update.sh` to prepare the update. Updated sources (and binaries) should be pushed to the repository.
