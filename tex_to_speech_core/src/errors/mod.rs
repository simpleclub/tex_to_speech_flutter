use thiserror::*;

#[derive(Debug, Error)]
pub enum Error {
    #[error("TeX to MathML conversion failed: {0}")]
    TeX2MathMLConversionError(#[from] latex2mathml::LatexError),

    #[error("Speech generation failed: {0}")]
    SpeechGenerationError(#[from] libmathcat::errors::Error),
}
