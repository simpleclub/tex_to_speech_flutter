import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

/// The hash that identifies a crate's precompiled binaries.
abstract final class CrateHash {
  /// The files whose content makes up the hash of the crate in
  /// [crateDirectory], in hashing order.
  static List<File> files(Directory crateDirectory) {
    final files =
        Directory(path.join(crateDirectory.path, 'src'))
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    for (final name in ['Cargo.toml', 'Cargo.lock', 'build.rs']) {
      final file = File(path.join(crateDirectory.path, name));
      if (file.existsSync()) {
        files.add(file);
      }
    }
    return files;
  }

  /// The hex-encoded hash of [files].
  static String compute(List<File> files) {
    final bytes = BytesBuilder(copy: false);
    for (final file in files) {
      // Hashed line by line so checkouts with converted line endings match.
      for (final line in const LineSplitter().convert(
        file.readAsStringSync(),
      )) {
        bytes.add(utf8.encode(line));
      }
    }
    final digest = sha256.convert(bytes.takeBytes()).bytes.sublist(0, 16);
    return [
      for (final byte in digest) byte.toRadixString(16).padLeft(2, '0'),
    ].join();
  }
}
