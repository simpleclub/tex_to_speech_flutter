/// Names, locates and verifies the precompiled tex_to_speech binaries.
///
/// The build hook uses this to download a binary, and the precompile
/// workflow's `build_tool` uses it to publish one, so both agree on the
/// release name and signing key.
library;

export 'src/crate_hash.dart';
export 'src/release_settings.dart';
