#!/bin/zsh
# This script generates an update for the tex_to_speech plugin after changes to any of related subprojects:
# - MathCAT
# - tex_to_speech_core
# - tex_to_speech rust
# - tex_to_speech dart.

cargo install flutter_rust_bridge_codegen

pushd tex_to_speech
pushd rust
cargo update
popd

flutter pub get

rm -rf pkg
flutter_rust_bridge_codegen generate
flutter_rust_bridge_codegen build-web -o ..
rm pkg/.gitignore
popd
