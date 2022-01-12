use crate::xdma::{Error as XdmaError, XdmaOps};

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug)]
pub enum Error {
    XdmaFailed(XdmaError),
}

/// CMS register offsets
pub enum CmsReg {
    Init = 0x2_0000,
    Control = 0x2_8018,
    /// VCCint voltage in mV
    VccIntMax = 0x2_80e0,
    VccIntAvg = 0x2_80e4,
    VccIntInst = 0x2_80e8,
    /// VCCint current in mA
    VccCurrentMax = 0x2_80ec,
    VccCurrentAvg = 0x2_80f0,
    VccCurrentInst = 0x2_80f4,
    /// Temperature in C
    FpgaTempMax = 0x2_80f8,
    FpgaTempAvg = 0x2_80fc,
    FpgaTempInst = 0x2_8100,
    Hbm0TempMax = 0x2_8260,
    Hbm0TempAvg = 0x2_8264,
    Hbm0TempInst = 0x2_8268,
    Hbm1TempMax = 0x2_82b4,
    Hbm1TempAvg = 0x2_82b8,
    Hbm1TempInst = 0x2_82bc,
}

#[repr(u32)]
pub enum ControlRegBits {
    HbmTempMonitorEnable = 1 << 27,
}

/// Card Management Solution subsystem
pub trait CardMgmtSys {
    /// Initialises the Card Management System
    fn init_cms(&mut self) -> Result<()>;

    /// Reads the value in a given CMS register
    fn get_cms_reg(&self, reg: CmsReg) -> Result<u32>;

    /// Reads the value in the CMS control register
    fn get_cms_control_reg(&self) -> Result<u32>;

    /// Reads the value in the CMS control register
    fn set_cms_control_reg(&mut self, value: u32) -> Result<()>;

    /// Enables HBM temperature monitoring
    fn enable_hbm_temp_monitoring(&mut self) -> Result<()>;
}

/// CMS parameters
pub trait CardMgmtSysParam {
    const BASE_ADDR: u64;
}

impl<T> CardMgmtSys for T
where
    T: XdmaOps + CardMgmtSysParam,
{
    fn init_cms(&mut self) -> Result<()> {
        let v = 1u32.to_le_bytes();
        self.shell_write(&v, T::BASE_ADDR + CmsReg::Init as u64)
            .map_err(Error::XdmaFailed)
    }

    fn get_cms_reg(&self, reg: CmsReg) -> Result<u32> {
        let mut data = [0u8; 4];
        self.shell_read(&mut data, T::BASE_ADDR + reg as u64)
            .map_err(Error::XdmaFailed)?;
        Ok(u32::from_le_bytes(data))
    }

    fn get_cms_control_reg(&self) -> Result<u32> {
        self.get_cms_reg(CmsReg::Control)
    }

    fn set_cms_control_reg(&mut self, value: u32) -> Result<()> {
        let data = value.to_le_bytes();
        self.shell_write(&data, T::BASE_ADDR + CmsReg::Control as u64)
            .map_err(Error::XdmaFailed)
    }

    fn enable_hbm_temp_monitoring(&mut self) -> Result<()> {
        let v = self.get_cms_control_reg()?;
        self.set_cms_control_reg(v | ControlRegBits::HbmTempMonitorEnable as u32)
    }
}
