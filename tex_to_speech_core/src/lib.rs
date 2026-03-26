use log::debug;

pub mod errors;

type Result<T> = std::result::Result<T, errors::Error>;

pub struct TexToSpeechBuilder {
    language: Option<String>,
}

impl Default for TexToSpeechBuilder {
    fn default() -> Self {
        Self::new()
    }
}

impl TexToSpeechBuilder {
    pub fn new() -> Self {
        TexToSpeechBuilder { language: None }
    }

    pub fn with_language(mut self, language: &str) -> Self {
        self.language = Some(language.to_owned());
        self
    }

    pub fn build(self) -> Result<TexToSpeech> {
        libmathcat::set_rules_dir("Rules".to_owned())?;
        // fixes issue of resetting language preference on Android devices
        libmathcat::set_preference("CheckRuleFiles".to_owned(), "None".to_owned())?;
        libmathcat::set_preference("TTS".to_owned(), "None".to_owned())?;
        debug!("MathML: rules directory set");
        if let Some(language) = self.language {
            debug!("MathML: language preference set to {}", &language);
            libmathcat::set_preference("Language".to_owned(), language)?;
        }
        Ok(TexToSpeech {})
    }
}

pub struct TexToSpeech;
impl TexToSpeech {
    /// Converts a TeX string to speech.
    pub fn tex_to_speech(&self, input: &str) -> Result<String> {
        let mut storage = pulldown_latex::Storage::new();
        let parser = pulldown_latex::Parser::new(input, &storage);
        if let Some(err) = parser.filter(|v| v.is_err()).next() {
            return Err(errors::Error::ParserError(err.err().unwrap()));
        }
        storage.reset();
        let parser = pulldown_latex::Parser::new(input, &storage);
        let mut mathml = String::new();
        pulldown_latex::push_mathml(&mut mathml, parser, pulldown_latex::RenderConfig::default())?;
        let mathml = mathml.trim();
        debug!("MathML: mathml generated: {}", mathml);
        let mathml = mathml.replace("<<", "&lt;<").replace(">>", ">&gt;");
        self.mathml_to_speech(&mathml)
    }

    /// Converts a MathML string to speech.
    pub fn mathml_to_speech(&self, input: &str) -> Result<String> {
        let _ = libmathcat::set_mathml(input.to_owned())?;
        debug!("MathML: math ml set");
        Ok(libmathcat::get_spoken_text()?)
    }
}

#[cfg(test)]
mod tests {
    use itertools::Itertools as _;
    use rayon::prelude::*;

    use super::*;

    fn assert_tex_to_speech(input: &str, expected: &str) -> Result<()> {
        let tts = TexToSpeechBuilder::new().with_language("de").build()?;
        let result = tts.tex_to_speech(input)?;
        assert_eq!(result, expected);
        Ok(())
    }

    #[test]
    fn test_simple_tex() -> Result<()> {
        assert_tex_to_speech("\\sin x", "sinus von x")
    }

    #[test]
    fn test_tex_example() -> Result<()> {
        assert_tex_to_speech("\\frac{5}{12}", "5 durch 12")
    }

    #[test]
    fn test_fcolorbox() -> Result<()> {
        assert_tex_to_speech("\\fcolorbox{white}{grey}{2.}", "2.")
    }

    #[test]
    fn test_cancel() -> Result<()> {
        assert_tex_to_speech("\\cancel{123}", "123")
    }

    #[test]
    fn test_lt() -> Result<()> {
        assert_tex_to_speech(
            r"-1\lt a\lt 0",
            "negative 1 ist kleiner als a ist kleiner als 0",
        )
    }

    #[test]
    fn test_tex_test_suite1() -> Result<()> {
        let test_suite = include_str!("../assets/tex_test_suite1.txt");
        let lines = test_suite.lines().map(|l| l.trim()).collect_vec();
        let chunk_size = 50;
        let results = lines
            .par_chunks(chunk_size)
            .map(|chunk| {
                let tts = TexToSpeechBuilder::new()
                    .with_language("de")
                    .build()
                    .unwrap();
                chunk
                    .iter()
                    .map(|tex| {
                        // println!("Converting: {}", tex);
                        (tex, tts.tex_to_speech(tex))
                    })
                    .collect_vec()
            })
            .flatten()
            .collect::<Vec<_>>();

        let mut warnings = Vec::new();
        for (tex, result) in results {
            match result {
                Ok(value) if value.contains("PARSE ERROR") => {
                    warnings.push(format!("failed to generate speech for `{}`", tex));
                }
                Err(_err) => {
                    warnings.push(format!("failed to convert TeX `{}`", tex));
                }
                _ => {}
            }
        }

        assert!(
            warnings.is_empty(),
            "{} warnings found: \n{}",
            warnings.len(),
            warnings.join("\n")
        );
        Ok(())
    }
}
