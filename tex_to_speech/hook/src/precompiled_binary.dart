import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:code_assets/code_assets.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed25519;
import 'package:hooks/hooks.dart';
import 'package:yaml/yaml.dart';

import 'crate_hash.dart';

/// The Rust library downloaded from the `precompiled_<crate hash>` release
/// that the `Precompile Binaries` workflow publishes.
final class PrecompiledBinary {
  /// Creates the precompiled binary for the target described by [input].
  PrecompiledBinary(this.input);

  /// The input of the running build hook.
  final BuildInput input;

  static const _libraryName = 'tex_to_speech';
  static const _assetName = 'src/rust/frb_generated.io.dart';
  static const _downloadAttempts = 5;
  static const _connectionTimeout = Duration(seconds: 30);
  static const _requestTimeout = Duration(minutes: 5);

  /// Downloads and verifies the binary, unless already cached, and adds it to
  /// [output] as a bundled code asset.
  Future<void> addTo(BuildOutputBuilder output) async {
    final codeConfig = input.config.code;
    if (codeConfig.linkModePreference == LinkModePreference.static) {
      throw UnsupportedError(
        'Precompiled $_libraryName binaries are dynamic libraries, but this '
        'build only allows static linking. Install Rust (https://rustup.rs) '
        'to build from source.',
      );
    }

    final crateDirectory = Directory.fromUri(
      input.packageRoot.resolve('rust/'),
    );
    final crateFiles = CrateHash.files(crateDirectory);
    output.dependencies.addAll([
      for (final file in crateFiles) file.absolute.uri,
    ]);

    final crateHash = CrateHash.compute(crateFiles);
    final targetTriple = _targetTriple(codeConfig);
    final fileName = codeConfig.targetOS.dylibFileName(_libraryName);
    final binary = File.fromUri(
      input.outputDirectoryShared.resolve(
        'precompiled/$crateHash/$targetTriple/$fileName',
      ),
    );
    if (!binary.existsSync()) {
      final settings = _ReleaseSettings.read(crateDirectory);
      await _download(
        settings: settings,
        crateHash: crateHash,
        assetFileName: '${targetTriple}_$fileName',
        destination: binary,
      );
    }

    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: _assetName,
        linkMode: DynamicLoadingBundled(),
        file: binary.uri,
      ),
    );
  }

  Future<void> _download({
    required _ReleaseSettings settings,
    required String crateHash,
    required String assetFileName,
    required File destination,
  }) async {
    final releaseUrl = '${settings.urlPrefix}$crateHash/';
    final binaryUrl = Uri.parse('$releaseUrl$assetFileName');
    final signature = await _get(Uri.parse('$releaseUrl$assetFileName.sig'));
    final data = await _get(binaryUrl);
    if (signature == null || data == null) {
      throw StateError(
        'No precompiled binary at $binaryUrl. The release for crate hash '
        '$crateHash is published by the Precompile Binaries workflow after '
        'the Rust sources land on main. Install Rust (https://rustup.rs) to '
        'build from source instead.',
      );
    }
    if (!ed25519.verify(settings.publicKey, data, signature)) {
      throw StateError('Signature verification failed for $binaryUrl.');
    }

    // Written under a temporary name first, so an interrupted build never
    // leaves a partial binary that later builds would treat as cached. The name
    // is unique per process because concurrent builds share this cache.
    destination.parent.createSync(recursive: true);
    final partial = File('${destination.path}.$pid.partial')
      ..writeAsBytesSync(data);
    partial.renameSync(destination.path);
  }

  /// The body of [url], or `null` when it doesn't exist.
  static Future<Uint8List?> _get(Uri url) async {
    for (var attempt = 1; ; attempt++) {
      // A fresh client per attempt, force-closed afterwards, so a timed-out
      // request can't keep its connection open into the next attempt.
      final client = HttpClient()
        ..findProxy = HttpClient.findProxyFromEnvironment
        ..connectionTimeout = _connectionTimeout;
      try {
        return await _fetch(client, url).timeout(_requestTimeout);
      } on Exception catch (error) {
        final isRetryable = error is IOException || error is TimeoutException;
        if (!isRetryable || attempt == _downloadAttempts) {
          rethrow;
        }
        await Future<void>.delayed(Duration(seconds: attempt));
      } finally {
        client.close(force: true);
      }
    }
  }

  static Future<Uint8List?> _fetch(HttpClient client, Uri url) async {
    final response = await (await client.getUrl(url)).close();
    if (response.statusCode == HttpStatus.notFound) {
      await response.drain<void>();
      return null;
    }
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      throw HttpException('HTTP ${response.statusCode}', uri: url);
    }
    final body = BytesBuilder(copy: false);
    await response.forEach(body.add);
    return body.takeBytes();
  }

  static String _targetTriple(CodeConfig codeConfig) {
    return switch ((codeConfig.targetOS, codeConfig.targetArchitecture)) {
      (OS.android, Architecture.arm64) => 'aarch64-linux-android',
      (OS.android, Architecture.arm) => 'armv7-linux-androideabi',
      (OS.android, Architecture.ia32) => 'i686-linux-android',
      (OS.android, Architecture.x64) => 'x86_64-linux-android',
      (OS.iOS, Architecture.arm64)
          when codeConfig.iOS.targetSdk == IOSSdk.iPhoneSimulator =>
        'aarch64-apple-ios-sim',
      (OS.iOS, Architecture.arm64) => 'aarch64-apple-ios',
      (OS.iOS, Architecture.x64) => 'x86_64-apple-ios',
      (OS.macOS, Architecture.arm64) => 'aarch64-apple-darwin',
      (OS.macOS, Architecture.x64) => 'x86_64-apple-darwin',
      (OS.linux, Architecture.x64) => 'x86_64-unknown-linux-gnu',
      (final os, final architecture) => throw UnsupportedError(
        'No precompiled $_libraryName binaries for $os on $architecture. '
        'Install Rust (https://rustup.rs) to build from source.',
      ),
    };
  }
}

/// Where the precompiled binaries are published and the key they are signed
/// with, as configured in `rust/cargokit.yaml`.
final class _ReleaseSettings {
  _ReleaseSettings({required this.urlPrefix, required this.publicKey});

  factory _ReleaseSettings.read(Directory crateDirectory) {
    final yaml =
        loadYaml(
              File('${crateDirectory.path}/cargokit.yaml').readAsStringSync(),
            )
            as YamlMap;
    final precompiled = yaml['precompiled_binaries'] as YamlMap;
    final publicKeyHex = precompiled['public_key'] as String;
    return _ReleaseSettings(
      urlPrefix: precompiled['url_prefix'] as String,
      publicKey: ed25519.PublicKey([
        for (var i = 0; i < publicKeyHex.length; i += 2)
          int.parse(publicKeyHex.substring(i, i + 2), radix: 16),
      ]),
    );
  }

  final String urlPrefix;
  final ed25519.PublicKey publicKey;
}
