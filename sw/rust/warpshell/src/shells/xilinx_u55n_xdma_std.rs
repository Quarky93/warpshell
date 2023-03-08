use super::{Error, Result, Shell};
use crate::{
    cores::{
        axi_firewall::AxiFirewallOps,
        cms::CmsOps,
        dfx_decoupler::DfxDecouplerOps,
        hbicap::{GetHbicapIf, HbicapOps},
    },
    xdma::{CtrlChannel, DmaChannel, GetCtrlChannel, GetDmaChannel, CTRL_CHANNEL, DMA_CHANNEL0},
    BaseParam, DmaBuffer,
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
    /// DFX decoupler instance
    pub dfx_decoupler: DfxDecoupler<'a>,
}

#[derive(GetCtrlChannel)]
pub struct Cms<'a> {
    /// User channel
    ctrl_channel: &'a CtrlChannel,
}

impl CmsOps for Cms<'_> {}

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

impl AxiFirewallOps for CtrlAxiFirewall<'_> {}

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

impl AxiFirewallOps for DmaAxiFirewall<'_> {}

pub struct Hbicap<'a> {
    /// Control interface
    ctrl_if: HbicapCtrlIf<'a>,
    /// DMA interface
    dma_if: HbicapDmaIf<'a>,
}

impl<'a> GetHbicapIf<HbicapCtrlIf<'a>, HbicapDmaIf<'a>> for Hbicap<'a> {
    fn get_ctrl_if(&self) -> &HbicapCtrlIf<'a> {
        &self.ctrl_if
    }

    fn get_dma_if(&self) -> &HbicapDmaIf<'a> {
        &self.dma_if
    }
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

#[derive(GetCtrlChannel)]
pub struct DfxDecoupler<'a> {
    /// User channel
    ctrl_channel: &'a CtrlChannel,
}

impl DfxDecouplerOps for DfxDecoupler<'_> {}

impl<'a> BaseParam for DfxDecoupler<'a> {
    const BASE_ADDR: u64 = 0x0409_0000;
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
            ctrl_if: HbicapCtrlIf { ctrl_channel },
            dma_if: HbicapDmaIf { dma_channel },
        };
        let dfx_decoupler = DfxDecoupler { ctrl_channel };
        Ok(Self {
            cms,
            hbm,
            ctrl_axi_firewall,
            dma_axi_firewall,
            hbicap,
            dfx_decoupler,
        })
    }
}

impl<'a> Shell for XilinxU55nXdmaStd<'a> {
    fn init(&self) -> Result<()> {
        Ok(self.cms.init()?)
    }

    fn read_back_user_image(&self) -> Result<Vec<u8>> {
        todo!()
    }

    fn program_user_image(&self, image: &[u8]) -> Result<()> {
        if self.hbicap.is_ready()? {
            return Err(Error::HbicapNotReady);
        }

        self.dfx_decoupler.enable()?;
        self.hbicap.reset()?;

        let mut buf = DmaBuffer::new(image.len());
        buf.0.extend_from_slice(image);
        self.hbicap.write_bitstream(&buf)?;

        self.hbicap.poll_ready_every_10ms()?;
        self.dfx_decoupler.disable()?;

        Ok(())
    }
}
