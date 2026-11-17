import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:flutter_rust_bridge_hooks/flutter_rust_bridge_hooks.dart';

import 'src/precompiled_binary.dart';

/// Builds the Rust library from source when rustup is installed, otherwise
/// downloads the precompiled binary for the current crate hash.
///
/// Apps can force either path through this package's user define:
///
/// ```yaml
/// hooks:
///   user_defines:
///     tex_to_speech:
///       use_precompiled_binaries: true
/// ```
void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) {
      return;
    }
    if (_usePrecompiledBinaries(input)) {
      await PrecompiledBinary(input).addTo(output);
    } else {
      await const FlutterRustBridgeNativeAssetsBuilder().run(
        input: input,
        output: output,
      );
    }
  });
}

bool _usePrecompiledBinaries(BuildInput input) {
  final define = input.userDefines['use_precompiled_binaries'];
  if (define is bool) {
    return define;
  }
  return !_isRustupInstalled();
}

/// Whether rustup can be found where `native_toolchain_rust` looks for it.
bool _isRustupInstalled() {
  final environment = Platform.environment;
  final executable = Platform.isWindows ? 'rustup.exe' : 'rustup';
  final home = environment[Platform.isWindows ? 'USERPROFILE' : 'HOME'];
  final directories = [
    ...?environment['PATH']?.split(Platform.isWindows ? ';' : ':'),
    if (home != null)
      '$home${Platform.pathSeparator}.cargo${Platform.pathSeparator}bin',
  ];
  return directories.any(
    (directory) =>
        File('$directory${Platform.pathSeparator}$executable').existsSync(),
  );
}
