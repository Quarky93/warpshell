//! # DFX decoupler

use crate::{BasedCtrlOps, Error as BasedError};
use enum_iterator::Sequence;
use thiserror::Error;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug, Error)]
pub enum Error {
    #[error("Based access error: {0}")]
    BasedError(#[from] BasedError),
}

/// CMS register offsets
#[derive(Copy, Clone, Debug, Sequence, PartialEq)]
#[repr(u64)]
pub enum DfxDecouplerReg {
    Control = 0,
}

#[repr(u32)]
pub enum ControlRegBit {
    En = 1,
}

pub trait DfxDecouplerOps: BasedCtrlOps {
    /// Checks whether decoupling is enabled.
    fn is_enabled(&self) -> Result<bool> {
        let en = ControlRegBit::En as u32;
        Ok(self.based_ctrl_read_u32(DfxDecouplerReg::Control as u64)? & en == en)
    }

    /// Enables decoupling.
    fn enable(&self) -> Result<()> {
        let en = ControlRegBit::En as u32;
        let v = self.based_ctrl_read_u32(DfxDecouplerReg::Control as u64)? | en;
        Ok(self.based_ctrl_write_u32(DfxDecouplerReg::Control as u64, v)?)
    }

    /// Disables decoupling.
    fn disable(&self) -> Result<()> {
        let en = ControlRegBit::En as u32;
        let v = (self.based_ctrl_read_u32(DfxDecouplerReg::Control as u64)? | en) ^ en;
        Ok(self.based_ctrl_write_u32(DfxDecouplerReg::Control as u64, v)?)
    }
}
