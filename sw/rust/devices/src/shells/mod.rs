mod xilinx_u55n_xdma_std;

use crate::{cores::cms::Error as CmsError, xdma::Error as XdmaError};
use thiserror::Error;

pub use xilinx_u55n_xdma_std::*;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug, Error)]
pub enum Error {
    #[error("XDMA error")]
    Xdma(#[from] XdmaError),
    #[error("CMS error")]
    Cms(#[from] CmsError),
}

/// A shell is a collection of cores, for example, [`XilinxU55nXdmaStd`]. This trait provides
/// methods that may involve multiple cores.
pub trait Shell {
    fn init(&self) -> Result<()>;
    fn load_raw_user_image(&self, image: &[u8]) -> Result<()>;
}