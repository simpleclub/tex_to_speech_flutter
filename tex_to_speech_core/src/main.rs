use std::io::{self, BufRead, Write, stdout};

use tex_to_speech_core::*;

fn main() -> std::result::Result<(), Box<dyn std::error::Error>> {
    env_logger::init();
    let tts = TexToSpeechBuilder::new().with_language("de").build()?;
    let stdin = io::stdin();

    let mut results: Vec<output::ConversionOutcome> = Vec::new();
    for line in stdin.lock().lines() {
        match line {
            Ok(line) => {
                let r = tts.tex_to_speech(line.trim());
                let outcome = match r {
                    Ok(speech) => output::ConversionOutcome {
                        tex: line,
                        result: output::ConversionResult::Success { speech: speech },
                    },
                    Err(err) => output::ConversionOutcome {
                        tex: line,
                        result: output::ConversionResult::Failure {
                            error: err.to_string(),
                        },
                    },
                };
                results.push(outcome);
            }
            Err(err) => {
                eprintln!("Failed to read from input: {}", err);
            }
        }
    }

    let buf = { ron::ser::to_string_pretty(&results, ron::ser::PrettyConfig::default())? };
    stdout().write_all(buf.as_bytes())?;
    Ok(())
}

mod output {
    use serde::Serialize;

    #[derive(Debug, Serialize)]
    pub enum ConversionResult {
        Success { speech: String },
        Failure { error: String },
    }

    #[derive(Debug, Serialize)]
    pub struct ConversionOutcome {
        pub tex: String,
        pub result: ConversionResult,
    }
}
