use crate::{
    cms::CardMgmtSysParam,
    xdma::{DmaBuffer, Result as XdmaResult, XdmaDevice, XdmaOps},
};
use std::fs::{File, OpenOptions};

pub const HBM_BASE_ADDR: u64 = 0;
pub const HBM_SIZE: u64 = 8 * 1024 * 1024 * 1024;

pub struct VariumC1100 {
    pub xdma: XdmaDevice,
}

impl CardMgmtSysParam for VariumC1100 {
    const BASE_ADDR: u64 = 0x0400_0000;
}

impl XdmaOps for VariumC1100 {
    #[inline]
    fn user_read(&self, buf: &mut [u8], offset: u64) -> XdmaResult<()> {
        self.xdma.user_read(buf, offset)
    }

    #[inline]
    fn user_write(&self, buf: &[u8], offset: u64) -> XdmaResult<()> {
        self.xdma.user_write(buf, offset)
    }

    #[inline]
    fn dma_read(&self, n_channel: usize, buf: &mut DmaBuffer, offset: u64) -> XdmaResult<()> {
        self.xdma.dma_read(n_channel, buf, offset)
    }

    #[inline]
    fn dma_write(&self, n_channel: usize, buf: &DmaBuffer, offset: u64) -> XdmaResult<()> {
        self.xdma.dma_write(n_channel, buf, offset)
    }
}

impl VariumC1100 {
    pub fn new() -> Result<Self, std::io::Error> {
        // For some reason `File::open` doesn't return a valid descriptor.
        let user_cdev = OpenOptions::new()
            .read(true)
            .write(true)
            .open("/dev/xdma0_user")?;
        let h2c_cdev = File::create("/dev/xdma0_h2c_0")?;
        let c2h_cdev = File::open("/dev/xdma0_c2h_0")?;
        Ok(Self {
            xdma: XdmaDevice::new_one_dma_channel(user_cdev, h2c_cdev, c2h_cdev),
        })
    }
}
