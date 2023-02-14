mod xilinx_u55n_xdma_std;

use crate::{cores::cms::Error as CmsError, xdma::Error as XdmaError};

pub use xilinx_u55n_xdma_std::*;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug)]
pub enum Error {
    Xdma(XdmaError),
    Cms(CmsError),
}

impl From<CmsError> for Error {
    fn from(e: CmsError) -> Error {
        Error::Cms(e)
    }
}

impl From<XdmaError> for Error {
    fn from(e: XdmaError) -> Error {
        Error::Xdma(e)
    }
}

/// A shell is a collection of cores, for example, [`XilinxU55nXdmaStd`]. This trait provides
/// methods that may involve multiple cores.
pub trait Shell {
    fn init(&self) -> Result<()>;
    fn load_raw_user_image(&self, image: &[u8]) -> Result<()>;
}
