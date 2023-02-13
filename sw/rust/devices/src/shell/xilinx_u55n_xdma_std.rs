use super::{Result, Shell};
use crate::{
    cores::cms::CmsOps,
    xdma::{
        DmaChannel, GetDmaChannel, GetUserChannel, OnceCellDmaChannel, OnceCellUserChannel,
        UserChannel,
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
    /// CMS core instance
    cms: Cms<'a>,
    /// HBM core instance
    hbm: Hbm<'a>,
}

pub struct Cms<'a> {
    /// User channel
    user_channel: &'a UserChannel,
}

pub struct Hbm<'a> {
    /// DMA channel
    dma_channel: &'a DmaChannel,
}

impl<'a> BaseParam for Cms<'a> {
    const BASE_ADDR: u64 = 0x0400_0000;
}

impl GetUserChannel for Cms<'_> {
    fn get_user_channel(&self) -> &UserChannel {
        self.user_channel
    }
}

impl<'a> BaseParam for Hbm<'a> {
    const BASE_ADDR: u64 = 0;
}

impl<'a> GetDmaChannel for Hbm<'a> {
    fn get_dma_channel(&self) -> &DmaChannel {
        self.dma_channel
    }
}

impl<'a> XilinxU55nXdmaStd<'a> {
    pub fn new() -> Result<Self> {
        let user_channel = USER_CHANNEL.get_or_init()?;
        let dma_channel = DMA_CHANNEL.get_or_init()?;
        let cms = Cms { user_channel };
        let hbm = Hbm { dma_channel };
        Ok(Self { cms, hbm })
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
