pub mod errors;

type Result<T> = std::result::Result<T, errors::Error>;

pub struct TexToSpeechBuilder {
    language: Option<String>,
}

impl TexToSpeechBuilder {
    pub fn new() -> Self {
        TexToSpeechBuilder { language: None }
    }

    pub fn language(mut self, language: &str) -> Self {
        self.language = Some(language.to_owned());
        self
    }

    pub fn build(self) -> Result<TexToSpeech> {
        libmathcat::set_rules_dir("Rules".to_owned())?;
        if let Some(language) = self.language {
            libmathcat::set_preference("Language".to_owned(), language)?;
        }
        Ok(TexToSpeech {})
    }
}

pub struct TexToSpeech;
impl TexToSpeech {
    /// Converts a TeX string to speech.
    pub fn tex_to_speech(&self, input: &str) -> Result<String> {
        let mathml = latex2mathml::latex_to_mathml(input, latex2mathml::DisplayStyle::Inline)?;
        self.mathml_to_speech(&mathml)
    }

    /// Converts a MathML string to speech.
    pub fn mathml_to_speech(&self, input: &str) -> Result<String> {
        let _ = libmathcat::set_mathml(input.to_owned())?;
        Ok(libmathcat::get_spoken_text()?)
    }
}
