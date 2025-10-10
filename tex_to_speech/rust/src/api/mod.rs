#[flutter_rust_bridge::frb(sync)]
pub fn tex_to_speech(text: &str) -> Result<String, String> {
    let tts_engine = tex_to_speech_core::TexToSpeechBuilder::new()
        .with_language("de")
        .build()
        .map_err(|e| e.to_string())?;

    Ok(tts_engine.tex_to_speech(text).map_err(|e| e.to_string())?)
}
