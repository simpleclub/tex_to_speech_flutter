use std::io::{self, BufRead, Write, stdout};

use log::debug;
use tex_to_speech_core::*;

fn main() -> std::result::Result<(), Box<dyn std::error::Error>> {
    env_logger::init();
    let tts = TexToSpeechBuilder::new().with_language("de").build()?;
    let stdin = io::stdin();

    let results = stdin
        .lock()
        .lines()
        .filter_map(|line| line.ok())
        .map(|line| {
            let r = tts.tex_to_speech(line.trim());
            (line, r)
        })
        .map(|(tex, result)| match result {
            Ok(speech) => output::ConversionOutcome {
                tex: tex,
                result: output::ConversionResult::Success { speech: speech },
            },
            Err(e) => output::ConversionOutcome {
                tex: tex,
                result: output::ConversionResult::Failure {
                    error: e.to_string(),
                },
            },
        })
        .collect::<Vec<_>>();
    let buf = { ron::ser::to_string_pretty(&results, ron::ser::PrettyConfig::default())? };
    stdout().write_all(buf.as_bytes())?;
    stdout().write_all("\n".as_bytes())?;
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
