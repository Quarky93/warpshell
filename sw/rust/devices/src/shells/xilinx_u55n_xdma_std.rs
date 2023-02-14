use super::{Result, Shell};
use crate::{
    cores::cms::CmsOps,
    xdma::{DmaChannel, GetDmaChannel, GetUserChannel, UserChannel, DMA_CHANNEL0, USER_CHANNEL},
    BaseParam,
};

pub struct XilinxU55nXdmaStd<'a> {
    /// CMS core instance
    pub cms: Cms<'a>,
    /// HBM core instance
    pub hbm: Hbm<'a>,
    /// User channel AXI firewall instance
    pub ctrl_axi_firewall: CtrlAxiFirewall<'a>,
    /// User channel AXI firewall instance
    pub dma_axi_firewall: DmaAxiFirewall<'a>,
}

pub struct Cms<'a> {
    /// User channel
    user_channel: &'a UserChannel,
}

impl<'a> BaseParam for Cms<'a> {
    const BASE_ADDR: u64 = 0x0400_0000;
}

impl GetUserChannel for Cms<'_> {
    fn get_user_channel(&self) -> &UserChannel {
        self.user_channel
    }
}

pub struct Hbm<'a> {
    /// DMA channel
    dma_channel: &'a DmaChannel,
}

impl<'a> BaseParam for Hbm<'a> {
    const BASE_ADDR: u64 = 0;
}

impl<'a> GetDmaChannel for Hbm<'a> {
    fn get_dma_channel(&self) -> &DmaChannel {
        self.dma_channel
    }
}

pub struct CtrlAxiFirewall<'a> {
    /// User channel
    user_channel: &'a UserChannel,
}

impl<'a> BaseParam for CtrlAxiFirewall<'a> {
    const BASE_ADDR: u64 = 0x0407_0000;
}

impl GetUserChannel for CtrlAxiFirewall<'_> {
    fn get_user_channel(&self) -> &UserChannel {
        self.user_channel
    }
}

pub struct DmaAxiFirewall<'a> {
    /// User channel
    user_channel: &'a UserChannel,
}

impl<'a> BaseParam for DmaAxiFirewall<'a> {
    const BASE_ADDR: u64 = 0x0408_0000;
}

impl GetUserChannel for DmaAxiFirewall<'_> {
    fn get_user_channel(&self) -> &UserChannel {
        self.user_channel
    }
}

impl<'a> XilinxU55nXdmaStd<'a> {
    pub fn new() -> Result<Self> {
        let user_channel = USER_CHANNEL.get_or_init()?;
        let dma_channel = DMA_CHANNEL0.get_or_init()?;
        let cms = Cms { user_channel };
        let hbm = Hbm { dma_channel };
        let ctrl_axi_firewall = CtrlAxiFirewall { user_channel };
        let dma_axi_firewall = DmaAxiFirewall { user_channel };
        Ok(Self {
            cms,
            hbm,
            ctrl_axi_firewall,
            dma_axi_firewall,
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
