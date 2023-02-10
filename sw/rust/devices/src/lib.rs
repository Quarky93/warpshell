pub mod cores;
pub mod shell;
pub mod xdma;

/// Base address of a memory-mapped core
pub trait BaseParam {
    /// Base address in bytes
    const BASE_ADDR: u64;
}
