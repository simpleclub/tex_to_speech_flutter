use tex_to_speech_core::*;

fn main() -> std::result::Result<(), Box<dyn std::error::Error>> {
    println!("Hello, TeXToSpeech!");
    let tex = r"x = \frac{ - b \pm \sqrt{ b^2 - 4 a c } }{ 2 a }";
    println!("TeX: {}", tex);
    let tts = TexToSpeechBuilder::new().with_language("de").build()?;
    let output = tts.tex_to_speech(tex)?;
    println!("TeX spoken: {output:?}");

    Ok(())
}
