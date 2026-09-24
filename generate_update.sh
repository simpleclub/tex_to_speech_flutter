#!/bin/zsh
# This script generates an update for the tex_to_speech plugin after changes to any of related subprojects:
# - MathCAT
# - tex_to_speech_core
# - tex_to_speech rust
# - tex_to_speech dart.

cargo install --version 2.13.0 flutter_rust_bridge_codegen

pushd tex_to_speech
pushd rust
cargo update
popd

flutter pub get

rm -rf pkg
flutter_rust_bridge_codegen generate
flutter_rust_bridge_codegen build-web --release -o ..
# Appending workaround that is required to pass the wasm_bindgen object to Dart code.
echo -n '\n\n' >> pkg/tex_to_speech.js && cat bindgen_register_postscript.js >> pkg/tex_to_speech.js
rm pkg/.gitignore
popd
