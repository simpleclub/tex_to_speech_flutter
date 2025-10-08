use thiserror::*;

#[derive(Debug, Error)]
pub enum Error {
    #[error("TeX to MathML conversion failed")]
    TeX2MathMLConversionError(#[from] latex2mathml::LatexError),

    #[error("Speech generation failed")]
    SpeechGenerationError(#[from] libmathcat::errors::Error),
}
