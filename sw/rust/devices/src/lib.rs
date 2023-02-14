pub mod cores;
pub mod shells;
pub mod xdma;

/// Base address of a memory-mapped core
pub trait BaseParam {
    /// Base address in bytes
    const BASE_ADDR: u64;
}
