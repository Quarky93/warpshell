use crate::xdma::{Error as XdmaError, XdmaOps};
use enum_iterator::Sequence;
use log::debug;
use num_enum::TryFromPrimitive;
use num_enum::TryFromPrimitiveError;
use std::collections::BTreeSet;
use std::convert::TryFrom;
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
    CardInfoParseError(CardInfoParseError),
}

impl From<CardInfoParseError> for Error {
    fn from(e: CardInfoParseError) -> Self {
        Self::CardInfoParseError(e)
    }
}

/// CMS register offsets
#[derive(Copy, Clone, Debug, Sequence, PartialEq)]
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
pub enum ControlRegBit {
    MaxAgvValuesReset = 1,
    ErrorRegReset = 1 << 1,
    MailboxStatus = 1 << 5,
    MicroblazeReset = 1 << 6,
    QsfpGpioEnable = 1 << 26,
    HbmTempMonitorEnable = 1 << 27,
}

#[repr(u32)]
pub enum MailboxMsgOpcode {
    // Only applicable after flashing new SC firmware; TODO. This is called CMC_OP_MSP432_JUMP in
    // "CMS SC Upgrade" UG. Calling it by itself is a bad idea.
    //
    // ScFwReboot = 3,
    CardInfo = 4,
}

#[derive(Copy, Clone, Debug, PartialEq, Eq, PartialOrd, Ord, TryFromPrimitive)]
#[repr(u8)]
pub enum CardInfoKey {
    SerialNumber = 0x21,
    MacAddress0 = 0x22,
    MacAddress1 = 0x23,
    MacAddress2 = 0x24,
    MacAddress3 = 0x25,
    CardRev = 0x26,
    CardName = 0x27,
    SatelliteVersion = 0x28,
    TotalPowerAvail = 0x29,
    FanPresence = 0x2a,
    ConfigMode = 0x2b,
    NewMacScheme = 0x4b,
    CageType0 = 0x50,
    CageType1 = 0x51,
    CageType2 = 0x52,
    CageType3 = 0x53,
}

pub type OldMacAddress = [u8; 16];
pub type MacAddress = [u8; 6];

#[derive(Copy, Clone, Debug, PartialEq, Eq, PartialOrd, Ord, TryFromPrimitive)]
#[repr(u8)]
pub enum TotalPowerAvail {
    Power75W,
    Power150W,
    Power225W,
    Power300W,
}

#[derive(Copy, Clone, Debug, PartialEq, Eq, PartialOrd, Ord, TryFromPrimitive)]
#[repr(u8)]
pub enum ConfigMode {
    SlaveSerialX1,
    SlaveSelectMapX8,
    SlaveMapX16,
    SlaveSelectMapX32,
    JtagBoudaryScanX1,
    MasterSpiX1,
    MasterSpiX2,
    MasterSpiX4,
    MasterSpiX8,
    MasterSpiX16,
    MasterSerialX1,
    MasterSelectMapX8,
    MasterSelectMapX16,
}

#[derive(Copy, Clone, Debug, PartialEq, Eq, PartialOrd, Ord, TryFromPrimitive)]
#[repr(u8)]
pub enum CageType {
    Qsfp,
    Dsfp,
    Sfp,
}

#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum CardInfoItem {
    SerialNumber(Vec<u8>),
    MacAddress0(OldMacAddress),
    MacAddress1(OldMacAddress),
    MacAddress2(OldMacAddress),
    MacAddress3(OldMacAddress),
    CardRev(Vec<u8>),
    CardName(Vec<u8>),
    SatelliteVersion(Vec<u8>),
    TotalPowerAvail(TotalPowerAvail),
    FanPresence(u8),
    ConfigMode(ConfigMode),
    NewMacScheme(u8, MacAddress),
    CageType0(CageType),
    CageType1(CageType),
    CageType2(CageType),
    CageType3(CageType),
}

#[derive(Copy, Clone, Debug, PartialEq)]
pub enum CardInfoItemParseError {
    IncompleteInput,
    IncorrectLength,
    NonNullTerminator,
    CardInfoKey(TryFromPrimitiveError<CardInfoKey>),
    TotalPowerAvail(TryFromPrimitiveError<TotalPowerAvail>),
    ConfigMode(TryFromPrimitiveError<ConfigMode>),
    CageType(TryFromPrimitiveError<CageType>),
}

impl From<TryFromPrimitiveError<CardInfoKey>> for CardInfoItemParseError {
    fn from(e: TryFromPrimitiveError<CardInfoKey>) -> Self {
        Self::CardInfoKey(e)
    }
}

impl From<TryFromPrimitiveError<TotalPowerAvail>> for CardInfoItemParseError {
    fn from(e: TryFromPrimitiveError<TotalPowerAvail>) -> Self {
        Self::TotalPowerAvail(e)
    }
}

impl From<TryFromPrimitiveError<ConfigMode>> for CardInfoItemParseError {
    fn from(e: TryFromPrimitiveError<ConfigMode>) -> Self {
        Self::ConfigMode(e)
    }
}

impl From<TryFromPrimitiveError<CageType>> for CardInfoItemParseError {
    fn from(e: TryFromPrimitiveError<CageType>) -> Self {
        Self::CageType(e)
    }
}

impl TryFrom<&[u8]> for CardInfoItem {
    type Error = CardInfoItemParseError;

    fn try_from(input: &[u8]) -> std::result::Result<Self, Self::Error> {
        let mut iter = input.iter();
        let mut next = || iter.next().ok_or(CardInfoItemParseError::IncompleteInput);
        let key = CardInfoKey::try_from(*next()?)?;
        let len = *next()? as usize;
        match key {
            CardInfoKey::SerialNumber => {
                if len == 0 {
                    return Err(CardInfoItemParseError::IncorrectLength);
                }
                let mut v = vec![];
                for _ in 0..len - 1 {
                    v.push(*next()?);
                }
                if *next()? != 0 {
                    return Err(CardInfoItemParseError::NonNullTerminator);
                }
                Ok(Self::SerialNumber(v))
            }
            CardInfoKey::MacAddress0 => {
                if len != 18 {
                    return Err(CardInfoItemParseError::IncorrectLength);
                }
                let mut v = vec![];
                for _ in 0..len - 1 {
                    v.push(*next()?);
                }
                if *next()? != 0 {
                    return Err(CardInfoItemParseError::NonNullTerminator);
                }
                let old_mac = v
                    .try_into()
                    .map_err(|_| CardInfoItemParseError::IncorrectLength)?;
                Ok(Self::MacAddress0(old_mac))
            }
            CardInfoKey::MacAddress1 => {
                if len != 18 {
                    return Err(CardInfoItemParseError::IncorrectLength);
                }
                let mut v = vec![];
                for _ in 0..len - 1 {
                    v.push(*next()?);
                }
                if *next()? != 0 {
                    return Err(CardInfoItemParseError::NonNullTerminator);
                }
                let old_mac = v
                    .try_into()
                    .map_err(|_| CardInfoItemParseError::IncorrectLength)?;
                Ok(Self::MacAddress1(old_mac))
            }
            CardInfoKey::MacAddress2 => {
                if len != 18 {
                    return Err(CardInfoItemParseError::IncorrectLength);
                }
                let mut v = vec![];
                for _ in 0..len - 1 {
                    v.push(*next()?);
                }
                if *next()? != 0 {
                    return Err(CardInfoItemParseError::NonNullTerminator);
                }
                let old_mac = v
                    .try_into()
                    .map_err(|_| CardInfoItemParseError::IncorrectLength)?;
                Ok(Self::MacAddress2(old_mac))
            }
            CardInfoKey::MacAddress3 => {
                if len != 18 {
                    return Err(CardInfoItemParseError::IncorrectLength);
                }
                let mut v = vec![];
                for _ in 0..len - 1 {
                    v.push(*next()?);
                }
                if *next()? != 0 {
                    return Err(CardInfoItemParseError::NonNullTerminator);
                }
                let old_mac = v
                    .try_into()
                    .map_err(|_| CardInfoItemParseError::IncorrectLength)?;
                Ok(Self::MacAddress3(old_mac))
            }
            CardInfoKey::CardRev => {
                if len == 0 {
                    return Err(CardInfoItemParseError::IncorrectLength);
                }
                let mut v = vec![];
                for _ in 0..len - 1 {
                    v.push(*next()?);
                }
                if *next()? != 0 {
                    return Err(CardInfoItemParseError::NonNullTerminator);
                }
                Ok(Self::CardRev(v))
            }
            CardInfoKey::CardName => {
                if len == 0 {
                    return Err(CardInfoItemParseError::IncorrectLength);
                }
                let mut v = vec![];
                for _ in 0..len - 1 {
                    v.push(*next()?);
                }
                if *next()? != 0 {
                    return Err(CardInfoItemParseError::NonNullTerminator);
                }
                Ok(Self::CardName(v))
            }
            CardInfoKey::SatelliteVersion => {
                if len == 0 {
                    return Err(CardInfoItemParseError::IncorrectLength);
                }
                let mut v = vec![];
                for _ in 0..len - 1 {
                    v.push(*next()?);
                }
                if *next()? != 0 {
                    return Err(CardInfoItemParseError::NonNullTerminator);
                }
                Ok(Self::SatelliteVersion(v))
            }
            CardInfoKey::TotalPowerAvail => {
                if len != 1 {
                    return Err(CardInfoItemParseError::IncorrectLength);
                }
                Ok(Self::TotalPowerAvail(TotalPowerAvail::try_from_primitive(
                    *next()?,
                )?))
            }
            CardInfoKey::FanPresence => {
                if len != 1 {
                    return Err(CardInfoItemParseError::IncorrectLength);
                }
                Ok(Self::FanPresence(*next()?))
            }
            CardInfoKey::ConfigMode => {
                if len != 1 {
                    return Err(CardInfoItemParseError::IncorrectLength);
                }
                Ok(Self::ConfigMode(ConfigMode::try_from_primitive(*next()?)?))
            }
            CardInfoKey::NewMacScheme => {
                if len != 8 {
                    return Err(CardInfoItemParseError::IncorrectLength);
                }
                let num_addresses = *next()?;
                // Skip the reserved byte.
                next()?;
                let mut v = vec![];
                for _ in 0..6 {
                    v.push(*next()?);
                }
                let mac = v
                    .try_into()
                    .map_err(|_| CardInfoItemParseError::IncorrectLength)?;
                Ok(Self::NewMacScheme(num_addresses, mac))
            }
            CardInfoKey::CageType0 => {
                if len != 1 {
                    return Err(CardInfoItemParseError::IncorrectLength);
                }
                Ok(Self::CageType0(CageType::try_from_primitive(*next()?)?))
            }
            CardInfoKey::CageType1 => {
                if len != 1 {
                    return Err(CardInfoItemParseError::IncorrectLength);
                }
                Ok(Self::CageType1(CageType::try_from_primitive(*next()?)?))
            }
            CardInfoKey::CageType2 => {
                if len != 1 {
                    return Err(CardInfoItemParseError::IncorrectLength);
                }
                Ok(Self::CageType2(CageType::try_from_primitive(*next()?)?))
            }
            CardInfoKey::CageType3 => {
                if len != 1 {
                    return Err(CardInfoItemParseError::IncorrectLength);
                }
                Ok(Self::CageType3(CageType::try_from_primitive(*next()?)?))
            }
        }
    }
}

#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub struct CardInfo(pub BTreeSet<CardInfoItem>);

#[derive(Copy, Clone, Debug, PartialEq)]
pub enum CardInfoParseError {
    CardInfoItem(CardInfoItemParseError),
    ItemLengthOutOfBounds,
}

impl From<CardInfoItemParseError> for CardInfoParseError {
    fn from(e: CardInfoItemParseError) -> Self {
        Self::CardInfoItem(e)
    }
}

impl TryFrom<&[u8]> for CardInfo {
    type Error = CardInfoParseError;

    fn try_from(input: &[u8]) -> std::result::Result<Self, Self::Error> {
        let mut set = BTreeSet::new();
        let mut parsed_len = 0;
        while parsed_len + 2 < input.len() {
            let item_len = input[parsed_len + 1];
            let to_parse_len = item_len as usize + 2;
            let next_item_pos = parsed_len + to_parse_len;
            debug!(
                "parsed_len {}, item_len {}, next_item_pos {}",
                parsed_len, item_len, next_item_pos
            );
            if next_item_pos - 1 > input.len() {
                return Err(CardInfoParseError::ItemLengthOutOfBounds);
            }
            let item = CardInfoItem::try_from(&input[parsed_len..next_item_pos])?;
            set.insert(item);
            parsed_len += to_parse_len;
        }
        Ok(Self(set))
    }
}

/// Card Management Solution subsystem
pub trait CardMgmtSys {
    /// Reads the value at a raw CMS address
    fn get_cms_addr(&self, addr: u64) -> Result<u32>;

    /// Writes the value at a raw CMS address
    fn set_cms_addr(&self, addr: u64, value: u32) -> Result<()>;

    /// Reads the value in a given CMS register
    fn get_cms_reg(&self, reg: CmsReg) -> Result<u32> {
        self.get_cms_addr(reg as u64)
    }

    /// Writes the value in a given CMS register
    fn set_cms_reg(&self, reg: CmsReg, value: u32) -> Result<()> {
        self.set_cms_addr(reg as u64, value)
    }

    /// Reads the value in the CMS control register
    fn get_cms_control_reg(&self) -> Result<u32> {
        self.get_cms_reg(CmsReg::Control)
    }

    /// Writes the value in the CMS control register
    fn set_cms_control_reg(&self, value: u32) -> Result<()> {
        self.set_cms_reg(CmsReg::Control, value)
    }

    /// Polls a given `mask` in a given CMS register `reg` continuously at least `n` times until the
    /// mask is equal to the expected value.
    fn poll_cms_reg_mask(&self, reg: CmsReg, mask: u32, expected: u32, n: usize) -> Result<()> {
        iter::repeat_with(|| self.get_cms_reg(reg).ok())
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
        iter::repeat_with(|| {
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
        self.poll_cms_reg_mask(reg, mask, 0, n)
    }

    /// Polls a given `mask` in a given CMS register `reg` continuously at least `n` times until the
    /// mask is set.
    fn poll_cms_reg_set(&self, reg: CmsReg, mask: u32, n: usize) -> Result<()> {
        self.poll_cms_reg_mask(reg, mask, mask, n)
    }
}

/// CMS parameters
pub trait CardMgmtSysParam {
    const BASE_ADDR: u64;
}

pub trait CardMgmtOps {
    /// Initialises the Card Management System
    fn init_cms(&self) -> Result<()>;

    // Waits roughly `ms` milliseconds to allow readings to be populated while polling the status
    // register every 1ms. Returns the elapsed milliseconds.
    fn expect_ready_host_status(&self, ms: usize) -> Result<usize>;

    /// Enables HBM temperature monitoring
    fn enable_hbm_temp_monitoring(&self) -> Result<()>;

    /// Gets the mailbox offset from the base address
    fn get_mailbox_offset(&self) -> Result<u64>;

    // /// Issues a reboot of the satellite controller
    // fn sc_fw_reboot(&mut self) -> Result<()>;

    /// Gets the card information
    fn get_card_info(&self) -> Result<CardInfo>;
}

impl<T> CardMgmtOps for T
where
    T: XdmaOps + CardMgmtSysParam,
{
    fn init_cms(&self) -> Result<()> {
        self.set_cms_reg(CmsReg::MicroblazeResetN, 1)
    }

    fn expect_ready_host_status(&self, ms: usize) -> Result<usize> {
        self.poll_cms_reg_mask_sleep(CmsReg::HostStatus, 1, 1, ms, Duration::from_millis(1))
            .map_err(|_| Error::HostStatusNotReady)
    }

    fn enable_hbm_temp_monitoring(&self) -> Result<()> {
        let v = self.get_cms_control_reg()?;
        self.set_cms_control_reg(v | ControlRegBit::HbmTempMonitorEnable as u32)
    }

    fn get_mailbox_offset(&self) -> Result<u64> {
        let control = self.get_cms_control_reg()?;
        if 0 != control & ControlRegBit::MailboxStatus as u32 {
            return Err(Error::MailboxNotAvailable);
        }
        let v = self.get_cms_reg(CmsReg::HostMsgOffset)?;
        Ok(0x2_8000u64 + v as u64)
    }

    // fn sc_fw_reboot(&mut self) -> Result<()> {
    //     let mbox_offset = self.get_mailbox_offset()?;
    //     self.set_cms_addr(mbox_offset, (MailboxMsgOpcode::ScFwReboot as u32) << 24)?;
    //     self.set_cms_addr(mbox_offset + 4, 0x00000201)?;
    //     let control = self.get_cms_control_reg()?;
    //     self.set_cms_control_reg(control | ControlRegBit::MailboxStatus as u32)?;
    //     let error = self.get_cms_reg(CmsReg::HostMsgError)?;
    //     if error != 0 {
    //         Err(Error::HostMsgError(error))
    //     } else {
    //         Ok(())
    //     }
    // }

    fn get_card_info(&self) -> Result<CardInfo> {
        let mbox_offset = self.get_mailbox_offset()?;
        debug!("mbox_offset 0x{:x}", mbox_offset);
        self.set_cms_addr(mbox_offset, (MailboxMsgOpcode::CardInfo as u32) << 24)?;
        let control = self.get_cms_control_reg()?;
        self.set_cms_control_reg(control | ControlRegBit::MailboxStatus as u32)?;
        // Wait for at most 1s.
        self.poll_cms_reg_mask_sleep(
            CmsReg::Control,
            ControlRegBit::MailboxStatus as u32,
            0,
            100,
            Duration::from_millis(10),
        )?;

        let error = self.get_cms_reg(CmsReg::HostMsgError)?;
        if error != 0 {
            return Err(Error::HostMsgError(error));
        }

        let len = self.get_cms_addr(mbox_offset)? & 0xfff;
        let mut info_bytes = Vec::with_capacity(len as usize);
        let mut data_offset = 4;
        let mut remaining = len as isize;
        while remaining > 0 {
            let w = self.get_cms_addr(mbox_offset + data_offset as u64)?;
            let bytes = w.to_le_bytes();
            let num_bytes = remaining.min(4) as usize;
            info_bytes.extend_from_slice(&bytes[..num_bytes]);
            data_offset += 4;
            remaining -= 4;
        }
        Ok(CardInfo::try_from(info_bytes.as_slice())?)
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

    fn set_cms_addr(&self, addr: u64, value: u32) -> Result<()> {
        let data = value.to_le_bytes();
        self.shell_write(&data, T::BASE_ADDR + addr)
            .map_err(Error::XdmaFailed)
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use test_log::test;

    #[test]
    fn parse_pg348_example_card_info() {
        let card_info_bytes: Vec<u8> = vec![
            0x27, 0x0d, 0x41, 0x4c, 0x56, 0x45, 0x4f, 0x20, 0x55, 0x35, 0x30, 0x20, 0x50, 0x51,
            0x00, 0x26, 0x02, 0x31, 0x00, 0x21, 0x0d, 0x35, 0x30, 0x31, 0x32, 0x31, 0x31, 0x31,
            0x39, 0x43, 0x53, 0x50, 0x4d, 0x00, 0x4b, 0x08, 0x04, 0x00, 0x00, 0x0a, 0x35, 0x05,
            0x0f, 0xd8, 0x2a, 0x01, 0x50, 0x2b, 0x01, 0x07, 0x29, 0x01, 0x00, 0x28, 0x04, 0x35,
            0x2e, 0x30, 0x00,
        ];
        let expected_card_info = CardInfo(
            vec![
                CardInfoItem::SerialNumber(b"50121119CSPM".to_vec()),
                CardInfoItem::CardRev(b"1".to_vec()),
                CardInfoItem::CardName(b"ALVEO U50 PQ".to_vec()),
                CardInfoItem::SatelliteVersion(b"5.0".to_vec()),
                CardInfoItem::TotalPowerAvail(TotalPowerAvail::Power75W),
                CardInfoItem::FanPresence(b'P'),
                CardInfoItem::ConfigMode(ConfigMode::MasterSpiX4),
                CardInfoItem::NewMacScheme(4, [0x00, 0x0a, 0x35, 0x05, 0x0f, 0xd8]),
            ]
            .into_iter()
            .collect(),
        );
        assert_eq!(
            CardInfo::try_from(card_info_bytes.as_slice()),
            Ok(expected_card_info)
        );
    }

    #[test]
    fn card_info_sernum_zero_length() {
        let card_info_bytes: Vec<u8> = vec![0x21, 0x00, 0x31, 0x32, 0x33, 0x00];
        assert_eq!(
            CardInfo::try_from(card_info_bytes.as_slice()),
            Err(CardInfoParseError::CardInfoItem(
                CardInfoItemParseError::IncorrectLength
            ))
        );
    }

    #[test]
    fn card_info_sernum_length_out_of_bounds() {
        let card_info_bytes: Vec<u8> = vec![0x21, 0xff, 0x31, 0x32, 0x33, 0x00];
        assert_eq!(
            CardInfo::try_from(card_info_bytes.as_slice()),
            Err(CardInfoParseError::ItemLengthOutOfBounds)
        );
    }

    #[test]
    fn card_info_sernum_non_null_terminator() {
        let card_info_bytes: Vec<u8> = vec![0x21, 0x04, 0x31, 0x32, 0x33, 0xff];
        assert_eq!(
            CardInfo::try_from(card_info_bytes.as_slice()),
            Err(CardInfoParseError::CardInfoItem(
                CardInfoItemParseError::NonNullTerminator
            ))
        );
    }
}
