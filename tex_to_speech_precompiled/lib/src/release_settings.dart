import 'package:ed25519_edwards/ed25519_edwards.dart' as ed25519;

/// Where the `Precompile Binaries` workflow publishes the precompiled binaries,
/// and the key that verifies their signatures.
abstract final class ReleaseSettings {
  /// The release download URL, without the crate hash and file name.
  static const urlPrefix =
      'https://github.com/simpleclub/tex_to_speech_flutter/releases/download/precompiled_';

  /// The hex-encoded public half of the key pair that signs the binaries.
  ///
  /// `dart run build_tool gen-key` creates a new pair. The private half is the
  /// `RELEASE_PRIVATE_KEY` repository secret.
  static const publicKeyHex =
      'e21211ad0e57469e8e0d630938d328f862b9abc7ab119ba04e98c33412d45da4';

  /// The key that verifies the signature of a downloaded binary.
  static ed25519.PublicKey get publicKey => ed25519.PublicKey([
    for (var i = 0; i < publicKeyHex.length; i += 2)
      int.parse(publicKeyHex.substring(i, i + 2), radix: 16),
  ]);
}
