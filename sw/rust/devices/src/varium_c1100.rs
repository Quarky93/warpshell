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
    const BASE_ADDR: u64 = 0;
}

impl XdmaOps for VariumC1100 {
    #[inline]
    fn shell_read(&self, buf: &mut [u8], offset: u64) -> XdmaResult<()> {
        self.xdma.shell_read(buf, offset)
    }

    #[inline]
    fn shell_write(&mut self, buf: &[u8], offset: u64) -> XdmaResult<()> {
        self.xdma.shell_write(buf, offset)
    }

    #[inline]
    fn dma_read(&self, buf: &mut DmaBuffer, offset: u64) -> XdmaResult<()> {
        self.xdma.dma_read(buf, offset)
    }

    #[inline]
    fn dma_write(&mut self, buf: &DmaBuffer, offset: u64) -> XdmaResult<()> {
        self.xdma.dma_write(buf, offset)
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
            xdma: XdmaDevice {
                id: 0,
                user_cdev,
                h2c_cdev,
                c2h_cdev,
                intc_base_addr: 0x1_0000,
                hbicap_base_addr: 0x10_0000,
            },
        })
    }
}
