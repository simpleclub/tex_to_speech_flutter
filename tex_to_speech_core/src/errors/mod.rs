use thiserror::*;

#[derive(Debug, Error)]
pub enum Error {
    #[error("TeX to MathML conversion failed: {0}")]
    TeX2MathMLConversionError(#[from] std::io::Error),

    #[error("Parser error: {0}")]
    ParserError(#[from] pulldown_latex::ParserError),

    #[error("Speech generation failed: {0}")]
    SpeechGenerationError(#[from] libmathcat::errors::Error),
}
