use super::{Result, Shell};
use crate::{
    cores::{cms::CmsOps, hbicap::HbicapIfs},
    xdma::{CtrlChannel, DmaChannel, GetCtrlChannel, GetDmaChannel, CTRL_CHANNEL, DMA_CHANNEL0},
    BaseParam,
};
use warpshell_derive::{GetCtrlChannel, GetDmaChannel};

/// Standard shell for Xilinx U55N also known as [Varium C1100 blockchain accelerator
/// card](https://www.xilinx.com/products/accelerators/varium/c1100.html)
pub struct XilinxU55nXdmaStd<'a> {
    /// CMS core instance
    pub cms: Cms<'a>,
    /// HBM core instance
    pub hbm: Hbm<'a>,
    /// Control channel AXI firewall instance
    pub ctrl_axi_firewall: CtrlAxiFirewall<'a>,
    /// DMA channel AXI firewall instance
    pub dma_axi_firewall: DmaAxiFirewall<'a>,
    /// HBICAP instance
    pub hbicap: Hbicap<'a>,
}

#[derive(GetCtrlChannel)]
pub struct Cms<'a> {
    /// User channel
    ctrl_channel: &'a CtrlChannel,
}

impl<'a> BaseParam for Cms<'a> {
    const BASE_ADDR: u64 = 0x0400_0000;
}

#[derive(GetDmaChannel)]
pub struct Hbm<'a> {
    /// DMA channel
    dma_channel: &'a DmaChannel,
}

impl<'a> BaseParam for Hbm<'a> {
    const BASE_ADDR: u64 = 0;
}

#[derive(GetCtrlChannel)]
pub struct CtrlAxiFirewall<'a> {
    /// Control channel
    ctrl_channel: &'a CtrlChannel,
}

impl<'a> BaseParam for CtrlAxiFirewall<'a> {
    const BASE_ADDR: u64 = 0x0407_0000;
}

#[derive(GetCtrlChannel)]
pub struct DmaAxiFirewall<'a> {
    /// Control channel
    ctrl_channel: &'a CtrlChannel,
}

impl<'a> BaseParam for DmaAxiFirewall<'a> {
    const BASE_ADDR: u64 = 0x0408_0000;
}

pub struct Hbicap<'a> {
    /// Interfaces for which `HbicapOps` is implemented.
    pub ifs: HbicapIfs<HbicapCtrlIf<'a>, HbicapDmaIf<'a>>,
}

#[derive(GetCtrlChannel)]
pub struct HbicapCtrlIf<'a> {
    /// Control channel
    ctrl_channel: &'a CtrlChannel,
}

impl<'a> BaseParam for HbicapCtrlIf<'a> {
    const BASE_ADDR: u64 = 0x0405_0000;
}

#[derive(GetDmaChannel)]
pub struct HbicapDmaIf<'a> {
    /// DMA channel
    dma_channel: &'a DmaChannel,
}

impl<'a> BaseParam for HbicapDmaIf<'a> {
    const BASE_ADDR: u64 = 0x1000_0000_0000_0000;
}

impl<'a> XilinxU55nXdmaStd<'a> {
    pub fn new() -> Result<Self> {
        let ctrl_channel = CTRL_CHANNEL.get_or_init()?;
        let dma_channel = DMA_CHANNEL0.get_or_init()?;
        let cms = Cms { ctrl_channel };
        let hbm = Hbm { dma_channel };
        let ctrl_axi_firewall = CtrlAxiFirewall { ctrl_channel };
        let dma_axi_firewall = DmaAxiFirewall { ctrl_channel };
        let hbicap = Hbicap {
            ifs: HbicapIfs {
                ctrl_if: HbicapCtrlIf { ctrl_channel },
                dma_if: HbicapDmaIf { dma_channel },
            },
        };
        Ok(Self {
            cms,
            hbm,
            ctrl_axi_firewall,
            dma_axi_firewall,
            hbicap,
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
