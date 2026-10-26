#!/bin/zsh
# This script generates an update for the tex_to_speech plugin after changes to any of related subprojects:
# - MathCAT
# - tex_to_speech_core
# - tex_to_speech rust
# - tex_to_speech dart.

# temporarily build local flutter_rust_bridge_codegen from https://github.com/simpleclub-extended/flutter_rust_bridge/tree/chore/priv-release
# until https://github.com/fzyzcjy/flutter_rust_bridge/issues/3477 is resolved and released
# copy the executable to 'tex_to_speech' folder
#
# cargo install flutter_rust_bridge_codegen

pushd tex_to_speech
pushd rust
cargo update
popd

flutter pub get

rm -rf pkg

./flutter_rust_bridge_codegen generate --no-auto-upgrade-dependency
./flutter_rust_bridge_codegen build-web --release -o ..
rm pkg/.gitignore
popd
