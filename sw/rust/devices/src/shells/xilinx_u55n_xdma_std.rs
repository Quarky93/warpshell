use super::{Result, Shell};
use crate::{
    cores::cms::CmsOps,
    xdma::{CtrlChannel, DmaChannel, GetCtrlChannel, GetDmaChannel, CTRL_CHANNEL, DMA_CHANNEL0},
    BaseParam,
};

pub struct XilinxU55nXdmaStd<'a> {
    /// CMS core instance
    pub cms: Cms<'a>,
    /// HBM core instance
    pub hbm: Hbm<'a>,
    /// Control channel AXI firewall instance
    pub ctrl_axi_firewall: CtrlAxiFirewall<'a>,
    /// DMA channel AXI firewall instance
    pub dma_axi_firewall: DmaAxiFirewall<'a>,
}

pub struct Cms<'a> {
    /// User channel
    ctrl_channel: &'a CtrlChannel,
}

impl<'a> BaseParam for Cms<'a> {
    const BASE_ADDR: u64 = 0x0400_0000;
}

impl GetCtrlChannel for Cms<'_> {
    fn get_ctrl_channel(&self) -> &CtrlChannel {
        self.ctrl_channel
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
    /// Control channel
    ctrl_channel: &'a CtrlChannel,
}

impl<'a> BaseParam for CtrlAxiFirewall<'a> {
    const BASE_ADDR: u64 = 0x0407_0000;
}

impl GetCtrlChannel for CtrlAxiFirewall<'_> {
    fn get_ctrl_channel(&self) -> &CtrlChannel {
        self.ctrl_channel
    }
}

pub struct DmaAxiFirewall<'a> {
    /// Control channel
    ctrl_channel: &'a CtrlChannel,
}

impl<'a> BaseParam for DmaAxiFirewall<'a> {
    const BASE_ADDR: u64 = 0x0408_0000;
}

impl GetCtrlChannel for DmaAxiFirewall<'_> {
    fn get_ctrl_channel(&self) -> &CtrlChannel {
        self.ctrl_channel
    }
}

impl<'a> XilinxU55nXdmaStd<'a> {
    pub fn new() -> Result<Self> {
        let ctrl_channel = CTRL_CHANNEL.get_or_init()?;
        let dma_channel = DMA_CHANNEL0.get_or_init()?;
        let cms = Cms { ctrl_channel };
        let hbm = Hbm { dma_channel };
        let ctrl_axi_firewall = CtrlAxiFirewall { ctrl_channel };
        let dma_axi_firewall = DmaAxiFirewall { ctrl_channel };
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
