use anyhow::{Result, anyhow};

use crate::modules::{xdma::Xdma, axi_firewall::AxiFirewall, cms::Cms};

pub struct XilinxU55nXdmaStd<'a> {
    pub xdma: &'a Xdma,
    pub cms: Cms<'a>,
    pub ctrl_firewall: AxiFirewall<'a>,
    pub dma_firewall: AxiFirewall<'a>
}

// -- ADDRESS MAP -----------------------------------------------------------------------------------------------------
const CTRL_USER_BASEADDR: u64 = 0x0000_0000;
const CTRL_CMS_BASEADDR: u64 = 0x0400_0000;
const CTRL_QSPI_BASEADDR: u64 = 0x0404_0000;
const CTRL_HBICAP_BASEADDR: u64 = 0x0405_0000;
const CTRL_MGMT_RAM_BASEADDR: u64 = 0x0406_0000;
const CTRL_CTRL_FIREWALL_BASEADDR: u64 = 0x0407_0000;
const CTRL_DMA_FIREWALL_BASEADDR: u64 = 0x0408_0000;
const CTRL_DECOUPLER_BASEADDR: u64 = 0x0409_0000;
// --------------------------------------------------------------------------------------------------------------------

impl<'a> XilinxU55nXdmaStd<'a> {
    pub fn new(xdma: &'a Xdma) -> Result<Self> {
        if xdma.user.len() != 1 {
            return Err(anyhow!("NO CTRL BUS FOUND!"));
        }
        if xdma.h2c.len() == 0 {
            return Err(anyhow!("NO H2C BUS FOUND!"));
        }
        if xdma.c2h.len() == 0 {
            return Err(anyhow!("NO C2H BUS FOUND!"));
        }
        Ok(Self {
            xdma,
            cms: Cms::new(&xdma.user[0], CTRL_CMS_BASEADDR),
            ctrl_firewall: AxiFirewall::new(&xdma.user[0], CTRL_CTRL_FIREWALL_BASEADDR),
            dma_firewall: AxiFirewall::new(&xdma.user[0], CTRL_DMA_FIREWALL_BASEADDR)
        })
    }

    pub fn init(&self) {
        self.cms.init();
    }
}
