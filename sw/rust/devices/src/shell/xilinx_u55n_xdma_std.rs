use super::{Result, Shell};
use crate::{
    cores::cms::CmsOps,
    xdma::{
        DmaBuffer, DmaChannels, DmaOps, GetUserChannel, OnceCellDmaChannel, OnceCellUserChannel,
        Result as XdmaResult, UserChannel,
    },
    BaseParam,
};
use once_cell::sync::OnceCell;

static USER_CHANNEL: OnceCellUserChannel = OnceCellUserChannel {
    cdev_path: "/dev/xdma0_user",
    channel: OnceCell::new(),
};
static DMA_CHANNEL: OnceCellDmaChannel = OnceCellDmaChannel {
    h2c_cdev_path: "/dev/xdma0_h2c_0",
    c2h_cdev_path: "/dev/xdma0_c2h_0",
    channel: OnceCell::new(),
};

// pub const HBM_BASE_ADDR: u64 = 0;
// pub const HBM_SIZE: u64 = 8 * 1024 * 1024 * 1024;

pub struct XilinxU55nXdmaStd<'a> {
    /// DMA channel
    dma_channels: DmaChannels<'a, 1>,
    /// CMS core instance
    cms: Cms<'a>,
}

pub struct Cms<'a> {
    /// User channel
    user_channel: &'a UserChannel,
}

impl<'a> BaseParam for Cms<'a> {
    const BASE_ADDR: u64 = 0x0400_0000;
}

impl<'a> GetUserChannel for Cms<'a> {
    fn get_user_channel(&self) -> &UserChannel {
        self.user_channel
    }
}

// TODO: refactor DmaOps to derive it from BaseParam + GetDmaChannel.
impl<'a> DmaOps for XilinxU55nXdmaStd<'a> {
    #[inline]
    fn dma_read(&self, _n_channel: usize, buf: &mut DmaBuffer, offset: u64) -> XdmaResult<()> {
        self.dma_channels.dma_read(0, buf, offset)
    }

    #[inline]
    fn dma_write(&self, _n_channel: usize, buf: &DmaBuffer, offset: u64) -> XdmaResult<()> {
        self.dma_channels.dma_write(0, buf, offset)
    }
}

impl<'a> XilinxU55nXdmaStd<'a> {
    pub fn new() -> Result<Self> {
        let user_channel = USER_CHANNEL.get_or_init()?;
        let dma_channel = DMA_CHANNEL.get_or_init()?;
        let cms = Cms { user_channel };
        Ok(Self {
            dma_channels: DmaChannels::from([dma_channel]),
            cms,
        })
    }
}

impl<'a> Shell for XilinxU55nXdmaStd<'a> {
    fn init(&self) -> Result<()> {
        Ok(self.cms.init()?)
    }

    fn load_raw_user_image(&self, _image: &[u8]) -> Result<()> {
        todo!()
    }
}
