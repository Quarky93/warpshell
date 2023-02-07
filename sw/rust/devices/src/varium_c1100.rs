use crate::{
    cms::CardMgmtSysParam,
    xdma::{
        DmaBuffer, DmaChannel, DmaChannels, DmaOps, Result as XdmaResult, UserChannel, UserOps,
    },
};
use std::fs::{File, OpenOptions};

pub const HBM_BASE_ADDR: u64 = 0;
pub const HBM_SIZE: u64 = 8 * 1024 * 1024 * 1024;

pub struct VariumC1100 {
    /// User channel
    user_channel: UserChannel,
    /// DMA channel
    dma_channels: DmaChannels<1>,
}

impl CardMgmtSysParam for VariumC1100 {
    const BASE_ADDR: u64 = 0x0400_0000;
}

impl UserOps for VariumC1100 {
    #[inline]
    fn user_read(&self, buf: &mut [u8], offset: u64) -> XdmaResult<()> {
        self.user_channel.user_read(buf, offset)
    }

    #[inline]
    fn user_write(&self, buf: &[u8], offset: u64) -> XdmaResult<()> {
        self.user_channel.user_write(buf, offset)
    }
}

impl DmaOps for VariumC1100 {
    #[inline]
    fn dma_read(&self, _n_channel: usize, buf: &mut DmaBuffer, offset: u64) -> XdmaResult<()> {
        self.dma_channels.dma_read(0, buf, offset)
    }

    #[inline]
    fn dma_write(&self, _n_channel: usize, buf: &DmaBuffer, offset: u64) -> XdmaResult<()> {
        self.dma_channels.dma_write(0, buf, offset)
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
            user_channel: UserChannel(user_cdev),
            dma_channels: DmaChannels::from([DmaChannel { h2c_cdev, c2h_cdev }]),
        })
    }
}
