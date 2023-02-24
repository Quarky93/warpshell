#[macro_use]
extern crate amplify;

use std::mem;
use std::result::Result;

pub mod cores;
pub mod shells;
pub mod xdma;

/// Base address of a memory-mapped core
pub trait BaseParam {
    /// Base address in bytes
    const BASE_ADDR: u64;
}

/// IO operations on an offset memory-mapped component via a user channel
pub trait BasedCtrlOps<E> {
    fn based_ctrl_read_u32(&self, offset: u64) -> Result<u32, E>;
    fn based_ctrl_write_u32(&self, offset: u64, value: u32) -> Result<(), E>;
}

/// IO operations on an offset memory-mapped component via a DMA channel
pub trait BasedDmaOps<E> {
    fn based_dma_read(&self, buf: &mut DmaBuffer, offset: u64) -> Result<(), E>;
    fn based_dma_write(&self, buf: &DmaBuffer, offset: u64) -> Result<(), E>;
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

impl Into<Vec<u8>> for ByteString {
    fn into(self) -> Vec<u8> {
        self.0
    }
}
