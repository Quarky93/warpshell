use crate::{xdma::Error as XdmaError, BasedCtrlOps};
use enum_iterator::Sequence;
use thiserror::Error;

const MI_BLOCK_MASK: u32 = 0x0100_0100;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Error, Debug)]
pub enum Error {
    #[error("XDMA failed: {0}")]
    XdmaFailed(#[from] XdmaError),
}

/// AXI firewall registers
#[derive(Copy, Clone, Debug, Sequence, PartialEq)]
#[repr(u64)]
pub enum AxiFirewallReg {
    MiSideFaultStatus = 0x0,
    MiSideSoftFaultControl = 0x4,
    MiSideUnblockControl = 0x8,
    IpVersion = 0x10,
    SiSideFaultStatus = 0x100,
    SiSideSoftFaultControl = 0x104,
    SiSideUnblockControl = 0x108,
}

pub trait AxiFirewallOps {
    /// Reads the value of an AXI firewall register
    fn get_axi_firewall_reg(&self, reg: AxiFirewallReg) -> Result<u32>;

    /// Writes the value of an AXI firewall register
    fn set_axi_firewall_reg(&self, reg: AxiFirewallReg, value: u32) -> Result<()>;

    fn get_mi_fault_status(&self) -> Result<u32> {
        self.get_axi_firewall_reg(AxiFirewallReg::MiSideFaultStatus)
    }

    fn mi_is_blocked(&self) -> Result<bool> {
        Ok(self.get_mi_fault_status()? != 0)
    }

    fn block_mi(&self) -> Result<()> {
        self.set_axi_firewall_reg(AxiFirewallReg::MiSideSoftFaultControl, MI_BLOCK_MASK)
    }

    fn unblock_mi(&self) -> Result<()> {
        self.set_axi_firewall_reg(AxiFirewallReg::MiSideSoftFaultControl, 0)?;
        self.set_axi_firewall_reg(AxiFirewallReg::MiSideUnblockControl, 1)
    }

    fn get_ip_version(&self) -> Result<u32> {
        self.get_axi_firewall_reg(AxiFirewallReg::IpVersion)
    }
}

impl<T> AxiFirewallOps for T
where
    T: BasedCtrlOps<XdmaError>,
{
    fn get_axi_firewall_reg(&self, reg: AxiFirewallReg) -> Result<u32> {
        Ok(self.based_ctrl_read_u32(reg as u64)?)
    }

    fn set_axi_firewall_reg(&self, reg: AxiFirewallReg, value: u32) -> Result<()> {
        Ok(self.based_ctrl_write_u32(reg as u64, value)?)
    }
}
