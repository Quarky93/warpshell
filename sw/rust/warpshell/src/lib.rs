//! # Warpshell library

#[macro_use]
extern crate amplify;

use crate::xdma::Error as XdmaError;
use std::iter;
use std::mem;
use std::thread;
use std::time::Duration;
use thiserror::Error;

pub mod cores;
pub mod shells;
pub mod xdma;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Error, Debug)]
pub enum Error {
    #[error("XDMA error: {0}")]
    XdmaError(#[from] XdmaError),
    #[error(
        "Register mask 0x{mask:08x} not equal to expected 0x{expected:08x} at offset 0x{offset:16x}"
    )]
    RegMaskNotAsExpected {
        offset: u64,
        mask: u32,
        expected: u32,
    },
}

/// Base address of a memory-mapped core
pub trait BaseParam {
    /// Base address in bytes
    const BASE_ADDR: u64;
}

/// IO operations on a memory-mapped component via a control channel
pub trait BasedCtrlOps {
    /// Reads a `u32` register at `offset`.
    fn based_ctrl_read_u32(&self, offset: u64) -> Result<u32>;

    /// Writes `value` into a `u32` register at `offset`.
    fn based_ctrl_write_u32(&self, offset: u64, value: u32) -> Result<()>;

    /// Polls a given `mask` in a given `u32` register at `offset` continuously at least `n` times
    /// until the mask is equal to the expected value.
    fn poll_reg_mask(&self, offset: u64, mask: u32, expected: u32, n: usize) -> Result<()> {
        iter::repeat_with(|| self.based_ctrl_read_u32(offset).ok())
            .take(n)
            .position(|ready| ready.map(|ready| ready & mask) == Some(expected))
            .map(|_| ())
            .ok_or(Error::RegMaskNotAsExpected {
                offset,
                mask,
                expected,
            })
    }

    /// Polls a given `mask` in a given `u32` register at `offset` continuously at least `n` times
    /// until the mask is equal to the expected value, sleeping for `duration` in between
    /// tries. Returns the number of elapsed tries.
    fn poll_reg_mask_sleep(
        &self,
        offset: u64,
        mask: u32,
        expected: u32,
        n: usize,
        duration: Duration,
    ) -> Result<usize> {
        iter::repeat_with(|| {
            thread::sleep(duration);
            self.based_ctrl_read_u32(offset).ok()
        })
        .take(n)
        .position(|ready| ready.map(|ready| ready & mask) == Some(expected))
        .map(|pos| pos + 1)
        .ok_or(Error::RegMaskNotAsExpected {
            offset,
            mask,
            expected,
        })
    }

    /// Polls a given `mask` in a given `u32` register at `offset` continuously at least `n` times
    /// until the mask clears.
    fn poll_reg_mask_clear(&self, offset: u64, mask: u32, n: usize) -> Result<()> {
        self.poll_reg_mask(offset, mask, 0, n)
    }

    /// Polls a given `mask` in a given `u32` register at `offset` continuously at least `n` times
    /// until the mask is set.
    fn poll_reg_mask_set(&self, offset: u64, mask: u32, n: usize) -> Result<()> {
        self.poll_reg_mask(offset, mask, mask, n)
    }
}

/// Getter trait for a control interface.
pub trait GetBasedCtrlIf<C: BasedCtrlOps> {
    /// Returns an abstract control interface.
    fn get_based_ctrl_if(&self) -> &C;
}

/// IO operations on a memory-mapped component via a DMA channel
pub trait BasedDmaOps {
    fn based_dma_read(&self, buf: &mut DmaBuffer, offset: u64) -> Result<()>;
    fn based_dma_write(&self, buf: &DmaBuffer, offset: u64) -> Result<()>;
}

/// Getter trait for a DMA interface.
pub trait GetBasedDmaIf<D: BasedDmaOps> {
    /// Returns an abstract DMA interface.
    fn get_based_dma_if(&self) -> &D;
}

#[repr(C, align(4096))]
struct Align4K([u8; 4096]);

/// DMA-engine aligned buffer. Non-reallocatable since reallocations do not preserve alignment. The
/// size has to be known before creation.
#[derive(Debug)]
pub struct DmaBuffer(Vec<u8>);

impl DmaBuffer {
    pub fn new(n_bytes: usize) -> Self {
        Self(unsafe { aligned_vec(n_bytes) })
    }

    pub fn as_slice(&self) -> &[u8] {
        self.0.as_slice()
    }

    pub fn as_mut_slice(&mut self) -> &mut [u8] {
        self.0.as_mut_slice()
    }

    pub fn get(&self) -> &Vec<u8> {
        &self.0
    }

    pub fn get_mut(&mut self) -> &mut Vec<u8> {
        &mut self.0
    }
}

unsafe fn aligned_vec(n_bytes: usize) -> Vec<u8> {
    let n_units = (n_bytes / mem::size_of::<Align4K>()) + 1;

    let mut aligned: Vec<Align4K> = Vec::with_capacity(n_units);

    let ptr = aligned.as_mut_ptr();
    let len_units = aligned.len();
    let cap_units = aligned.capacity();

    mem::forget(aligned);

    Vec::from_raw_parts(
        ptr as *mut u8,
        len_units * mem::size_of::<Align4K>(),
        cap_units * mem::size_of::<Align4K>(),
    )
}

/// Lightly standardised byte strings with convenience methods.
#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord, Display)]
#[display(ByteString::as_string)]
pub struct ByteString(Vec<u8>);

impl ByteString {
    pub fn as_string(&self) -> String {
        self.0.iter().map(|b| *b as char).collect()
    }
}

impl From<Vec<u8>> for ByteString {
    fn from(vec: Vec<u8>) -> Self {
        Self(vec)
    }
}

impl From<ByteString> for Vec<u8> {
    fn from(bs: ByteString) -> Vec<u8> {
        bs.0
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use test_log::test;

    #[test]
    fn dma_buffer_capacity_len() {
        const PAYLOAD_LEN: usize = 64;
        let mut buf: DmaBuffer = DmaBuffer::new(PAYLOAD_LEN);

        assert_eq!(buf.0.capacity(), 4096);
        assert_eq!(buf.0.len(), 0);

        let payload: [u8; PAYLOAD_LEN] = [42; PAYLOAD_LEN];
        buf.0.extend_from_slice(&payload);

        assert_eq!(buf.0.capacity(), 4096);
        assert_eq!(buf.0.len(), PAYLOAD_LEN);
    }
}
