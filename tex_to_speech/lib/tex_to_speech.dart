library;

import 'dart:async' show Completer;

import 'src/rust/api.dart' as rust_api;
import 'src/rust/frb_generated.dart' show TexToSpeechFlutterBridge;

class TexToSpeechFlutter {
  static Completer<void>? _initCompleter;
  static Future<void> init() {
    _initCompleter ??= Completer();
    if (!_initCompleter!.isCompleted) {
      TexToSpeechFlutterBridge.init().then(
        (_) => _initCompleter!.complete(),
        onError: (error, stackTrace) =>
            _initCompleter!.completeError(error, stackTrace),
      );
    }
    return _initCompleter!.future;
  }

  static String texToSpeech(String text) {
    if (!_initCompleter!.isCompleted) {
      throw Exception('TexToSpeechFlutter not initialized');
    }
    return rust_api.texToSpeech(text: text);
  }

  static Future<String> texToSpeechAsync(String text) async {
    await init();
    return rust_api.texToSpeech(text: text);
  }
}
