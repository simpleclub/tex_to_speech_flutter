/// This is copied from Cargokit (which is the official way to use it currently)
/// Details: https://fzyzcjy.github.io/flutter_rust_bridge/manual/integrate/builtin

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:toml/toml.dart';

class ManifestException {
  ManifestException(this.message, {required this.fileName});

  final String? fileName;
  final String message;

  @override
  String toString() {
    if (fileName != null) {
      return 'Failed to parse package manifest at $fileName: $message';
    } else {
      return 'Failed to parse package manifest: $message';
    }
  }
}

class CrateInfo {
  CrateInfo({required this.packageName, required this.toolchain});

  final String packageName;

  /// The Rust toolchain pinned by the crate's `rust-toolchain.toml`, or
  /// `stable` when it pins none.
  final String toolchain;

  static CrateInfo parseManifest(
    String manifest, {
    final String? fileName,
    String toolchain = 'stable',
  }) {
    final toml = TomlDocument.parse(manifest);
    final package = toml.toMap()['package'];
    if (package == null) {
      throw ManifestException('Missing package section', fileName: fileName);
    }
    final name = package['name'];
    if (name == null) {
      throw ManifestException('Missing package name', fileName: fileName);
    }
    return CrateInfo(packageName: name, toolchain: toolchain);
  }

  static CrateInfo load(String manifestDir) {
    final manifestFile = File(path.join(manifestDir, 'Cargo.toml'));
    final manifest = manifestFile.readAsStringSync();
    return parseManifest(
      manifest,
      fileName: manifestFile.path,
      toolchain: _pinnedToolchain(manifestDir) ?? 'stable',
    );
  }

  static String? _pinnedToolchain(String manifestDir) {
    final file = File(path.join(manifestDir, 'rust-toolchain.toml'));
    if (!file.existsSync()) {
      return null;
    }
    final toolchain =
        TomlDocument.parse(file.readAsStringSync()).toMap()['toolchain'];
    return toolchain is Map ? toolchain['channel'] as String? : null;
  }
}
