use std::io::{self, Read};

use tex_to_speech_core::*;

fn main() -> std::result::Result<(), Box<dyn std::error::Error>> {
    env_logger::init();
    let tts = TexToSpeechBuilder::new().with_language("de").build()?;

    let path = std::env::args().nth(1);
    let input = match path {
        Some(path) => {
            let v = std::fs::read_to_string(path)?;
            v
        }
        None => {
            let mut stdin = io::stdin();
            let mut buf = String::new();
            let _ = stdin.read_to_string(&mut buf)?;

            buf
        }
    };
    let output = tts.tex_to_speech(&input)?;
    println!("TeX spoken: {output:?}");

    Ok(())
}
