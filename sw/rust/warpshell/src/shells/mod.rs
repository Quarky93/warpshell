//! # User-space interfaces to shells

mod xilinx_u55n_xdma_std;

use crate::{
    cores::{
        cms::Error as CmsError, dfx_decoupler::Error as DfxDecouplerError,
        hbicap::Error as HbicapError,
    },
    xdma::Error as XdmaError,
    Error as BasedError,
};
use thiserror::Error;

pub use xilinx_u55n_xdma_std::*;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug, Error)]
pub enum Error {
    #[error("XDMA error: {0}")]
    XdmaError(#[from] XdmaError),
    #[error("Based access error: {0}")]
    BasedError(#[from] BasedError),
    #[error("CMS error")]
    Cms(#[from] CmsError),
    #[error("HBICAP is not ready")]
    HbicapNotReady,
    #[error("HBICAP error")]
    Hbicap(#[from] HbicapError),
    #[error("DFX decoupler error")]
    DfxDecoupler(#[from] DfxDecouplerError),
}

/// A shell is a collection of cores with host interfaces to them, for example,
/// [`XilinxU55nXdmaStd`]. This trait provides methods that may involve multiple cores.
pub trait Shell {
    fn init(&self) -> Result<()>;
    fn read_back_user_image(&self) -> Result<Vec<u8>>;
    fn program_user_image(&self, image: &[u8]) -> Result<()>;
}
