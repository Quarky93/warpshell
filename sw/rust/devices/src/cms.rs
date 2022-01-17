use crate::xdma::{Error as XdmaError, XdmaOps};
use enum_iterator_derive::IntoEnumIterator;
use std::iter;
use std::thread;
use std::time::Duration;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug)]
pub enum Error {
    XdmaFailed(XdmaError),
    HostStatusNotReady,
    MailboxNotAvailable,
    CmsRegMaskNotAsExpected,
    HostMsgError(u32),
}

/// CMS register offsets
#[derive(Copy, Clone, Debug, IntoEnumIterator, PartialEq)]
#[repr(u64)]
pub enum CmsReg {
    /// Microblaze reset register. Active-Low. Default 0, reset active.
    MicroblazeResetN = 0x2_0000,
    FwVersion = 0x2_8004,
    CmsStatus = 0x2_8008,
    Error = 0x2_800c,
    ProfileName = 0x2_8014,
    Control = 0x2_8018,
    /// Voltage in mV
    Pex12VMax = 0x2_8020,
    Pex12VAvg = 0x2_8024,
    Pex12VInst = 0x2_8028,
    Pex3V3Max = 0x2_802c,
    Pex3V3Avg = 0x2_8030,
    Pex3V3Inst = 0x2_8034,
    // Aux3V3Max = 0x2_8038,
    // Aux3V3Avg = 0x2_803c,
    // Aux3V3Inst = 0x2_8040,
    Aux12VMax = 0x2_8044,
    Aux12VAvg = 0x2_8048,
    Aux12VInst = 0x2_804c,
    Sys5V5Max = 0x2_805c,
    Sys5V5Avg = 0x2_8060,
    Sys5V5Inst = 0x2_8064,
    // Vcc1V2TopMax = 0x2_8068,
    // Vcc1V2TopAvg = 0x2_806c,
    // Vcc1V2TopInst = 0x2_8070,
    Vcc1V8Max = 0x2_8074,
    Vcc1V8Avg = 0x2_8078,
    Vcc1V8Inst = 0x2_807c,
    // Vcc0V85Max = 0x2_8080,
    // Vcc0V85Avg = 0x2_8084,
    // Vcc0V85Inst = 0x2_8088,
    Mgt0V9AVccMax = 0x2_8098,
    Mgt0V9AVccAvg = 0x2_809c,
    Mgt0V9AVccInst = 0x2_80A0,
    // Sw12VMax = 0x2_80a4,
    // Sw12VAvg = 0x2_80a8,
    // Sw12VInst = 0x2_80ac,
    MgtAVttMax = 0x2_80b0,
    MgtAVttAvg = 0x2_80b4,
    MgtAVttInst = 0x2_80b8,
    // Vcc1V2BottomMax = 0x2_80bc,
    // Vcc1V2BottomTopAvg = 0x2_80c0,
    // Vcc1V2BottomInst = 0x2_80c4,
    /// Current in mA
    Pex12VCurrentInMax = 0x2_80c8,
    Pex12VCurrentInAvg = 0x2_80cc,
    Pex12VCurrentInInst = 0x2_80d0,
    Aux12VCurrentInMax = 0x2_80d4,
    Aux12VCurrentInAvg = 0x2_80d8,
    Aux12VCurrentInInst = 0x2_80dc,
    VccIntMax = 0x2_80e0,
    VccIntAvg = 0x2_80e4,
    VccIntInst = 0x2_80e8,
    VccCurrentMax = 0x2_80ec,
    VccCurrentAvg = 0x2_80f0,
    VccCurrentInst = 0x2_80f4,
    /// Temperature in C
    FpgaTempMax = 0x2_80f8,
    FpgaTempAvg = 0x2_80fc,
    FpgaTempInst = 0x2_8100,
    // CageTemp0Max = 0x2_8170,
    // CageTemp0Avg = 0x2_8174,
    // CageTemp0Inst = 0x2_8178,
    // CageTemp1Max = 0x2_817c,
    // CageTemp1Avg = 0x2_8180,
    // CageTemp1Inst = 0x2_8184,
    // CageTemp2Max = 0x2_8188,
    // CageTemp2Avg = 0x2_818c,
    // CageTemp2Inst = 0x2_8190,
    // CageTemp3Max = 0x2_8194,
    // CageTemp3Avg = 0x2_8198,
    // CageTemp3Inst = 0x2_819c,
    Hbm0TempMax = 0x2_8260,
    Hbm0TempAvg = 0x2_8264,
    Hbm0TempInst = 0x2_8268,
    Vcc3V3Max = 0x2_826c,
    Vcc3V3Avg = 0x2_8270,
    Vcc3V3Inst = 0x2_8274,
    Pex3V3CurrentInMax = 0x2_8278,
    Pex3V3CurrentInAvg = 0x2_827c,
    Pex3V3CurrentInInst = 0x2_8280,
    VccIntCurrentMax = 0x2_8284,
    VccIntCurrentAvg = 0x2_8288,
    VccIntCurrentInst = 0x2_828c,
    Hbm1TempMax = 0x2_82b4,
    Hbm1TempAvg = 0x2_82b8,
    Hbm1TempInst = 0x2_82bc,
    // Aux1_12VMax = 0x2_82c0,
    // Aux1_12VAvg = 0x2_82c4,
    // Aux1_12VInst = 0x2_82c8,
    VccIntTempMax = 0x2_82cc,
    VccIntTempAvg = 0x2_82d0,
    VccIntTempInst = 0x2_82d4,
    // /// Power in mW
    // Pex12VPowerMax = 0x2_82d8,
    // Pex12VPowerAvg = 0x2_82dc,
    // Pex12VPowerInst = 0x2_82e0,
    // Pex3V3PowerMax = 0x2_82e4,
    // Pex3V3PowerAvg = 0x2_82e8,
    // Pex3V3PowerInst = 0x2_82ec,
    /// Mailbox offset from the base address `0x2_8000`. Valid range `0x1000..0x1ffc`. Default `0x1000`.
    HostMsgOffset = 0x2_8300,
    HostMsgError = 0x2_8304,
    /// Bit 0 is set if mailbox and sensor readings are ready.
    HostStatus = 0x2_830c,
}

#[repr(u32)]
pub enum ControlRegBits {
    MaxAgvValuesReset = 1,
    ErrorRegReset = 1 << 1,
    MailboxStatus = 1 << 5,
    MicroblazeReset = 1 << 6,
    QsfpGpioEnable = 1 << 26,
    HbmTempMonitorEnable = 1 << 27,
}

#[repr(u32)]
pub enum MailboxMsgOpcodes {
    // Only applicable after flashing new SC firmware; TODO. This is called CMC_OP_MSP432_JUMP in
    // "CMS SC Upgrade" UG. Calling it by itself is a bad idea.
    //
    // ScFwReboot = 3,
    CardInfo = 4,
}

/// Card Management Solution subsystem
pub trait CardMgmtSys {
    /// Reads the value at a raw CMS address
    fn get_cms_addr(&self, addr: u64) -> Result<u32>;

    /// Writes the value at a raw CMS address
    fn set_cms_addr(&mut self, addr: u64, value: u32) -> Result<()>;

    /// Reads the value in a given CMS register
    fn get_cms_reg(&self, reg: CmsReg) -> Result<u32> {
        self.get_cms_addr(reg as u64)
    }

    /// Writes the value in a given CMS register
    fn set_cms_reg(&mut self, reg: CmsReg, value: u32) -> Result<()> {
        self.set_cms_addr(reg as u64, value)
    }

    /// Reads the value in the CMS control register
    fn get_cms_control_reg(&self) -> Result<u32> {
        self.get_cms_reg(CmsReg::Control)
    }

    /// Writes the value in the CMS control register
    fn set_cms_control_reg(&mut self, value: u32) -> Result<()> {
        self.set_cms_reg(CmsReg::Control, value)
    }

    /// Polls a given `mask` in a given CMS register `reg` continuously at least `n` times until the
    /// mask is equal to the expected value.
    fn poll_cms_reg_mask(&self, reg: CmsReg, mask: u32, expected: u32, n: usize) -> Result<()> {
        iter::repeat(self.get_cms_reg(reg).ok())
            .take(n)
            .position(|ready| ready.map(|ready| ready & mask) == Some(expected))
            .map(|_| ())
            .ok_or(Error::CmsRegMaskNotAsExpected)
    }

    /// Polls a given `mask` in a given CMS register `reg` continuously at least `n` times until the
    /// mask is equal to the expected value, sleeping for `duration` in between tries. Returns the
    /// number of elapsed tries.
    fn poll_cms_reg_mask_sleep(
        &self,
        reg: CmsReg,
        mask: u32,
        expected: u32,
        n: usize,
        duration: Duration,
    ) -> Result<usize> {
        iter::repeat({
            thread::sleep(duration);
            self.get_cms_reg(reg).ok()
        })
        .take(n)
        .position(|ready| ready.map(|ready| ready & mask) == Some(expected))
        .map(|pos| pos + 1)
        .ok_or(Error::CmsRegMaskNotAsExpected)
    }

    /// Polls a given `mask` in a given CMS register `reg` continuously at least `n` times until the
    /// mask clears.
    fn poll_cms_reg_clear(&self, reg: CmsReg, mask: u32, n: usize) -> Result<()> {
        self.poll_cms_reg_mask(reg, mask, mask, n)
    }

    /// Polls a given `mask` in a given CMS register `reg` continuously at least `n` times until the
    /// mask is set.
    fn poll_cms_reg_set(&self, reg: CmsReg, mask: u32, n: usize) -> Result<()> {
        self.poll_cms_reg_mask(reg, mask, 0, n)
    }
}

/// CMS parameters
pub trait CardMgmtSysParam {
    const BASE_ADDR: u64;
}

pub trait CardMgmtOps {
    /// Initialises the Card Management System
    fn init_cms(&mut self) -> Result<()>;

    // Waits roughly `us` microseconds to allow readings to be populated while polling the status
    // register every 1µs. Returns the elapsed microseconds.
    fn expect_ready_host_status(&self, us: usize) -> Result<usize>;

    /// Enables HBM temperature monitoring
    fn enable_hbm_temp_monitoring(&mut self) -> Result<()>;

    /// Gets the mailbox offset from the base address
    fn get_mailbox_offset(&self) -> Result<u64>;

    // /// Issues a reboot of the satellite controller
    // fn sc_fw_reboot(&mut self) -> Result<()>;

    /// Gets the card information
    // TODO: parse the info vector
    fn get_card_info(&mut self) -> Result<Vec<u8>>;
}

impl<T> CardMgmtOps for T
where
    T: XdmaOps + CardMgmtSysParam,
{
    fn init_cms(&mut self) -> Result<()> {
        self.set_cms_reg(CmsReg::MicroblazeResetN, 1)
    }

    fn expect_ready_host_status(&self, us: usize) -> Result<usize> {
        self.poll_cms_reg_mask_sleep(CmsReg::HostStatus, 1, 1, us, Duration::from_micros(1))
            .map_err(|_| Error::HostStatusNotReady)
    }

    fn enable_hbm_temp_monitoring(&mut self) -> Result<()> {
        let v = self.get_cms_control_reg()?;
        self.set_cms_control_reg(v | ControlRegBits::HbmTempMonitorEnable as u32)
    }

    fn get_mailbox_offset(&self) -> Result<u64> {
        let control = self.get_cms_control_reg()?;
        if 0 != control & ControlRegBits::MailboxStatus as u32 {
            return Err(Error::MailboxNotAvailable);
        }
        let v = self.get_cms_reg(CmsReg::HostMsgOffset)?;
        Ok(0x2_8000u64 + v as u64)
    }

    // fn sc_fw_reboot(&mut self) -> Result<()> {
    //     let mbox_offset = self.get_mailbox_offset()?;
    //     self.set_cms_addr(mbox_offset, (MailboxMsgOpcodes::ScFwReboot as u32) << 24)?;
    //     self.set_cms_addr(mbox_offset + 4, 0x00000201)?;
    //     let control = self.get_cms_control_reg()?;
    //     self.set_cms_control_reg(control | ControlRegBits::MailboxStatus as u32)?;
    //     let error = self.get_cms_reg(CmsReg::HostMsgError)?;
    //     if error != 0 {
    //         Err(Error::HostMsgError(error))
    //     } else {
    //         Ok(())
    //     }
    // }

    fn get_card_info(&mut self) -> Result<Vec<u8>> {
        let mbox_offset = self.get_mailbox_offset()?;
        self.set_cms_addr(mbox_offset, (MailboxMsgOpcodes::CardInfo as u32) << 24)?;
        let control = self.get_cms_control_reg()?;
        self.set_cms_control_reg(control | ControlRegBits::MailboxStatus as u32)?;
        self.poll_cms_reg_clear(CmsReg::Control, ControlRegBits::MailboxStatus as u32, 100)?;

        let error = self.get_cms_reg(CmsReg::HostMsgError)?;
        if error != 0 {
            return Err(Error::HostMsgError(error));
        }

        let len = self.get_cms_addr(mbox_offset)? & 0xfff;
        let mut info = Vec::with_capacity(len as usize);
        for i in 0..len {
            let w = self.get_cms_addr(mbox_offset + 4 + i as u64)?;
            let bytes = w.to_le_bytes();
            info.extend_from_slice(&bytes);
        }
        Ok(info)
    }
}

impl<T> CardMgmtSys for T
where
    T: XdmaOps + CardMgmtSysParam,
{
    fn get_cms_addr(&self, addr: u64) -> Result<u32> {
        let mut data = [0u8; 4];
        self.shell_read(&mut data, T::BASE_ADDR + addr)
            .map_err(Error::XdmaFailed)?;
        Ok(u32::from_le_bytes(data))
    }

    fn set_cms_addr(&mut self, addr: u64, value: u32) -> Result<()> {
        let data = value.to_le_bytes();
        self.shell_write(&data, T::BASE_ADDR + addr)
            .map_err(Error::XdmaFailed)
    }
}
