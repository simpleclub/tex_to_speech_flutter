// This snippet dispatches the 'wasm_bindgen_registered' event after the wasm_bindgen object is available.
// It's used to notify any listeners that the wasm_bindgen object is now available.
// Used in WASM bridge initialization to signal that the wasm_bindgen object is ready and can be used to start interacting with the WASM module.

let wasmBindgenRegisteredEvent = new Event('wasm_bindgen_registered');
wasmBindgenRegisteredEvent.wasm_bindgen = wasm_bindgen;
window.dispatchEvent(wasmBindgenRegisteredEvent);