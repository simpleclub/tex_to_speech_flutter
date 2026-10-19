import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_rust_bridge/src/platform_utils/_web.dart';
import 'package:web/web.dart' as web;

/// {@macro flutter_rust_bridge.internal}
Future<void> initializeWasmModule({
  required String root,
  String wasmBindgenName = 'wasm_bindgen',
}) async {
  _ensureCrossOriginIsolated();

  // Create the namespace JavaScript object.
  // This namespace object is used by Rust
  // to call functions defined in Dart.
  final rinfBindingsObject = JSObject();
  globalContext['rinfBindings'] = rinfBindingsObject;

  // Prepare to await the module load.
  final loadCompleter = Completer<JSObject>();
  rinfBindingsObject['completeRinfLoad'] = (JSObject bindgen) {
    loadCompleter.complete(bindgen);
  }.toJS;

  final scriptElement = web.HTMLScriptElement()
    ..type = 'module'
    ..innerHTML =
        '''
  import init, * as $wasmBindgenName from "./$root.js";
  globalThis.$wasmBindgenName = $wasmBindgenName;
  rinfBindings.completeRinfLoad(globalThis.$wasmBindgenName);
  delete rinfBindings.completeRinfLoad;
  '''
            .toJS;
  web.document.head!.append(scriptElement);
  final loadResult = await loadCompleter.future;
  web.console.log(loadResult);
  final wasmBindgenInit = loadResult['default'] as JSObject;
  web.console.log(wasmBindgenInit);
  final wasmBindgen = _JSWasmBindgen(wasmBindgenInit);
  await wasmBindgen('${root}_bg.wasm'.toJS).toDart;
}

void _ensureCrossOriginIsolated() {
  switch (crossOriginIsolated) {
    case false:
      web.console.warn(
        'Warning: Buffers cannot be shared due to missing cross-origin headers. Please refer to https://fzyzcjy.github.io/flutter_rust_bridge/manual/miscellaneous/web-cross-origin for details.'
            .toJS,
      );
      return;
    case true:
      return;
    case null:
      web.console.warn(
        'Warning: crossOriginIsolated is null, browser might not support buffer sharing.'
            .toJS,
      );
      return;
  }
}

extension type _JSWasmBindgen(JSObject _) implements JSObject {
  @JS()
  external JSPromise call(JSAny? arg);
}
