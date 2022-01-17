use std::fs::File;
use std::io::Error as IoError;
use std::os::unix::fs::FileExt;

/// Memory alignment for optimal performance of DMA reads and writes.
pub const DMA_ALIGNMENT: u64 = 4096;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug)]
pub enum Error {
    ShellReadFailed(IoError),
    ShellWriteFailed(IoError),
    DmaReadFailed(IoError),
    DmaWriteFailed(IoError),
}

#[repr(align(4096))]
pub struct DmaBuffer(pub Vec<u8>);

pub struct XdmaDevice {
    /// Device ID
    pub id: u32,
    /// User character device
    pub user_cdev: File,
    /// Host to card character device
    pub h2c_cdev: File,
    /// Card to host character device
    pub c2h_cdev: File,
    /// Interrupt Controller
    //
    // TODO: create an INTC parameter trait and move it there as a trait const.
    pub intc_base_addr: u32,
    /// High Bandwidth Internal Configuration Access Port
    //
    // TODO: create an HBICAP parameter trait and move it there as a trait const.
    pub hbicap_base_addr: u32,
}

pub trait XdmaOps {
    fn shell_read(&self, buf: &mut [u8], offset: u64) -> Result<()>;
    fn shell_write(&mut self, buf: &[u8], offset: u64) -> Result<()>;
    fn dma_read(&self, buf: &mut DmaBuffer, offset: u64) -> Result<()>;
    fn dma_write(&mut self, buf: &DmaBuffer, offset: u64) -> Result<()>;
}

impl XdmaOps for XdmaDevice {
    fn shell_read(&self, buf: &mut [u8], offset: u64) -> Result<()> {
        self.user_cdev
            .read_exact_at(buf, offset)
            .map_err(Error::ShellReadFailed)
    }

    fn shell_write(&mut self, buf: &[u8], offset: u64) -> Result<()> {
        self.user_cdev
            .write_all_at(buf, offset)
            .map_err(Error::ShellWriteFailed)
    }

    fn dma_read(&self, buf: &mut DmaBuffer, offset: u64) -> Result<()> {
        self.c2h_cdev
            .read_exact_at(buf.0.as_mut_slice(), offset)
            .map_err(Error::DmaReadFailed)
    }

    fn dma_write(&mut self, buf: &DmaBuffer, offset: u64) -> Result<()> {
        self.h2c_cdev
            .write_all_at(buf.0.as_slice(), offset)
            .map_err(Error::DmaWriteFailed)
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn file_write_all_at() {
        let n: u64 = rand::random();
        let f = File::create(format!("/tmp/xdma-test-{:x}", n)).expect("cannot create file");
        let buf = vec![b'A', b'B', b'C'];
        f.write_all_at(buf.as_slice(), 0)
            .expect("write test failed");
    }
}
