//! # Card Management System

use crate::{BasedCtrlOps, ByteString, Error as BasedError};
use enum_iterator::Sequence;
use log::debug;
use num_enum::{TryFromPrimitive, TryFromPrimitiveError};
use std::convert::TryFrom;
use std::time::Duration;
use thiserror::Error;

const SUPPORTED_REG_MAP_ID: u32 = 0x74736574;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug, Error)]
pub enum Error {
    #[error("Based access error: {0}")]
    BasedError(#[from] BasedError),
    #[error("Host status not ready")]
    HostStatusNotReady,
    #[error("Unsupported register map id 0x{0:x}")]
    UnsupportedRegMapId(u32),
    #[error("Mailbox not available")]
    MailboxNotAvailable,
    #[error("CMS register mask not as expected")]
    CmsRegMaskNotAsExpected,
    #[error("Host message error {0}")]
    HostMsgError(u32),
    #[error("CardInfo parsing error: {0}")]
    CardInfoParseError(#[from] CardInfoParseError),
}

/// CMS register offsets
#[derive(Copy, Clone, Debug, Sequence, PartialEq)]
#[repr(u64)]
pub enum CmsReg {
    /// Microblaze reset register. Active-Low. Default 0, reset active.
    MicroblazeResetN = 0x2_0000,
    RegMapId = 0x2_8000,
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
    VccIntCurrentMax = 0x2_80ec,
    VccIntCurrentAvg = 0x2_80f0,
    VccIntCurrentInst = 0x2_80f4,
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
    VccIntIoCurrentMax = 0x2_8284,
    VccIntIoCurrentAvg = 0x2_8288,
    VccIntIoCurrentInst = 0x2_828c,
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

#[derive(Copy, Clone, Debug, PartialEq, Eq, PartialOrd, Ord, TryFromPrimitive, Display)]
#[display(Debug)]
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

#[derive(Copy, Clone, Debug, PartialEq, Eq, PartialOrd, Ord, Display)]
#[display(OldMacAddress::as_string)]
pub struct OldMacAddress(pub [u8; 16]);

impl OldMacAddress {
    pub fn as_string(&self) -> String {
        self.0.iter().map(|b| *b as char).collect()
    }
}

#[derive(Copy, Clone, Debug, PartialEq, Eq, PartialOrd, Ord, Display)]
#[display(MacAddress::as_string)]
pub struct MacAddress(pub [u8; 6]);

impl MacAddress {
    pub fn as_string(&self) -> String {
        let octets: Vec<_> = self.0.iter().map(|b| format!("{:02x}", *b)).collect();
        octets.join(":")
    }
}

#[derive(Copy, Clone, Debug, PartialEq, Eq, PartialOrd, Ord, TryFromPrimitive, Display)]
#[repr(u8)]
pub enum TotalPowerAvail {
    #[display("75W")]
    Power75W,
    #[display("150W")]
    Power150W,
    #[display("225W")]
    Power225W,
    #[display("300W")]
    Power300W,
}

#[derive(Copy, Clone, Debug, PartialEq, Eq, PartialOrd, Ord, TryFromPrimitive, Display)]
#[display(Debug)]
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

#[derive(Copy, Clone, Debug, PartialEq, Eq, PartialOrd, Ord, TryFromPrimitive, Display)]
#[display(uppercase)]
#[repr(u8)]
pub enum CageType {
    Qsfp,
    Dsfp,
    Sfp,
}

#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord, Display)]
pub enum CardInfoItem {
    #[display("serial number: {0}")]
    SerialNumber(ByteString),
    #[display("MAC address 0: {0}")]
    MacAddress0(OldMacAddress),
    #[display("MAC address 1: {0}")]
    MacAddress1(OldMacAddress),
    #[display("MAC address 2: {0}")]
    MacAddress2(OldMacAddress),
    #[display("MAC address 3: {0}")]
    MacAddress3(OldMacAddress),
    #[display("card revision: {0}")]
    CardRev(ByteString),
    #[display("card name: {0}")]
    CardName(ByteString),
    #[display("satellite controller version: {0}")]
    SatelliteVersion(ByteString),
    #[display("total power available: {0}")]
    TotalPowerAvail(TotalPowerAvail),
    #[display("fan presence: {0}")]
    FanPresence(char),
    #[display("config mode: {0}")]
    ConfigMode(ConfigMode),
    #[display("new MAC scheme: {0} addresses starting from {1}")]
    NewMacScheme(u8, MacAddress),
    #[display("cage 0 type: {0}")]
    CageType0(CageType),
    #[display("cage 1 type: {0}")]
    CageType1(CageType),
    #[display("cage 2 type: {0}")]
    CageType2(CageType),
    #[display("cage 3 type: {0}")]
    CageType3(CageType),
}

#[derive(Error, Copy, Clone, Debug, PartialEq)]
pub enum CardInfoItemParseError {
    #[error("Incomplete input for CardInfoItem")]
    IncompleteInput,
    #[error("Incorrect length of CardInfoItem")]
    IncorrectLength,
    #[error("Non-null terminator of CardInfoItem")]
    NonNullTerminator,
    #[error("CardInfoKey error")]
    CardInfoKey(#[from] TryFromPrimitiveError<CardInfoKey>),
    #[error("TotalPowerAvail error")]
    TotalPowerAvail(#[from] TryFromPrimitiveError<TotalPowerAvail>),
    #[error("ConfigMode error")]
    ConfigMode(#[from] TryFromPrimitiveError<ConfigMode>),
    #[error("CageType error")]
    CageType(#[from] TryFromPrimitiveError<CageType>),
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
                Ok(Self::SerialNumber(v.into()))
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
                Ok(Self::MacAddress0(OldMacAddress(old_mac)))
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
                Ok(Self::MacAddress1(OldMacAddress(old_mac)))
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
                Ok(Self::MacAddress2(OldMacAddress(old_mac)))
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
                Ok(Self::MacAddress3(OldMacAddress(old_mac)))
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
                Ok(Self::CardRev(v.into()))
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
                Ok(Self::CardName(v.into()))
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
                Ok(Self::SatelliteVersion(v.into()))
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
                Ok(Self::FanPresence(*next()? as char))
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
                let mac = MacAddress(
                    v.try_into()
                        .map_err(|_| CardInfoItemParseError::IncorrectLength)?,
                );
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

#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord, Display)]
#[display(CardInfo::as_string)]
pub struct CardInfo(pub Vec<CardInfoItem>);

impl CardInfo {
    pub fn as_string(&self) -> String {
        let mut s = String::new();
        for item in &self.0 {
            s.push_str(&format!("{item}\n"));
        }
        s
    }
}

#[derive(Error, Copy, Clone, Debug, PartialEq)]
pub enum CardInfoParseError {
    #[error("CardInfoItem parsing error")]
    CardInfoItem(#[from] CardInfoItemParseError),
    #[error("CardInfoItem length out of bounds")]
    ItemLengthOutOfBounds,
}

impl TryFrom<&[u8]> for CardInfo {
    type Error = CardInfoParseError;

    fn try_from(input: &[u8]) -> std::result::Result<Self, Self::Error> {
        let mut items = Vec::new();
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
            items.push(item);
            parsed_len += to_parse_len;
        }
        Ok(Self(items))
    }
}

/// Card Management Solution subsystem
pub trait CmsOps: BasedCtrlOps {
    /// Reads the value in a given CMS register
    fn get_cms_reg(&self, reg: CmsReg) -> Result<u32> {
        Ok(self.based_ctrl_read_u32(reg as u64)?)
        //        Ok(self.get_cms_offset(reg as u64)?)
    }

    /// Writes the value in a given CMS register
    fn set_cms_reg(&self, reg: CmsReg, value: u32) -> Result<()> {
        Ok(self.based_ctrl_write_u32(reg as u64, value)?)
        //        Ok(self.set_cms_offset(reg as u64, value)?)
    }

    /// Reads the value in the CMS control register
    fn get_cms_control_reg(&self) -> Result<u32> {
        self.get_cms_reg(CmsReg::Control)
    }

    /// Writes the value in the CMS control register
    fn set_cms_control_reg(&self, value: u32) -> Result<()> {
        self.set_cms_reg(CmsReg::Control, value)
    }

    /// Initialises the Card Management System
    fn init(&self) -> Result<()> {
        self.set_cms_reg(CmsReg::MicroblazeResetN, 1)?;
        // Expect to wait up to at least 1s.
        self.expect_ready_host_status(1000)?;

        let v = self.get_reg_map_id()?;
        if v != SUPPORTED_REG_MAP_ID {
            return Err(Error::UnsupportedRegMapId(v));
        };

        // For consideration: this would delete any previous readings...
        // self.reset_sensor_max_avg()?;

        self.enable_hbm_temp_monitoring()
    }

    /// Waits roughly `ms` milliseconds to allow readings to be populated while polling the status
    /// register every 1ms. Returns the elapsed milliseconds.
    fn expect_ready_host_status(&self, ms: usize) -> Result<usize> {
        self.poll_reg_mask_sleep(
            CmsReg::HostStatus as u64,
            1,
            1,
            ms,
            Duration::from_millis(1),
        )
        .map_err(|_| Error::HostStatusNotReady)
    }

    fn get_reg_map_id(&self) -> Result<u32> {
        self.get_cms_reg(CmsReg::RegMapId)
    }

    /// Enables HBM temperature monitoring
    fn enable_hbm_temp_monitoring(&self) -> Result<()> {
        let v = self.get_cms_control_reg()?;
        self.set_cms_control_reg(v | ControlRegBit::HbmTempMonitorEnable as u32)
    }

    /// Resets stored max and average sensor readings
    fn reset_sensor_max_avg(&self) -> Result<()> {
        let v = self.get_cms_control_reg()?;
        self.set_cms_control_reg(v | ControlRegBit::MaxAgvValuesReset as u32)
    }

    /// Gets the mailbox offset from the base address
    fn get_mailbox_offset(&self) -> Result<u64> {
        let control = self.get_cms_control_reg()?;
        if 0 != control & ControlRegBit::MailboxStatus as u32 {
            return Err(Error::MailboxNotAvailable);
        }
        let v = self.get_cms_reg(CmsReg::HostMsgOffset)?;
        Ok(0x2_8000u64 + v as u64)
    }

    /// Gets the card information
    fn get_card_info(&self) -> Result<CardInfo> {
        let mbox_offset = self.get_mailbox_offset()?;
        debug!("mbox_offset 0x{:x}", mbox_offset);
        self.based_ctrl_write_u32(mbox_offset, (MailboxMsgOpcode::CardInfo as u32) << 24)?;
        let control = self.get_cms_control_reg()?;
        self.set_cms_control_reg(control | ControlRegBit::MailboxStatus as u32)?;
        // Wait for at most 1s.
        self.poll_reg_mask_sleep(
            CmsReg::Control as u64,
            ControlRegBit::MailboxStatus as u32,
            0,
            100,
            Duration::from_millis(10),
        )?;

        let error = self.get_cms_reg(CmsReg::HostMsgError)?;
        if error != 0 {
            return Err(Error::HostMsgError(error));
        }

        let len = self.based_ctrl_read_u32(mbox_offset)? & 0xfff;
        let mut info_bytes = Vec::with_capacity(len as usize);
        let mut data_offset = 4;
        let mut remaining = len as isize;
        while remaining > 0 {
            let w = self.based_ctrl_read_u32(mbox_offset + data_offset as u64)?;
            let bytes = w.to_le_bytes();
            let num_bytes = remaining.min(4) as usize;
            info_bytes.extend_from_slice(&bytes[..num_bytes]);
            data_offset += 4;
            remaining -= 4;
        }
        Ok(CardInfo::try_from(info_bytes.as_slice())?)
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
        let expected_card_info = CardInfo(vec![
            CardInfoItem::CardName(b"ALVEO U50 PQ".to_vec().into()),
            CardInfoItem::CardRev(b"1".to_vec().into()),
            CardInfoItem::SerialNumber(b"50121119CSPM".to_vec().into()),
            CardInfoItem::NewMacScheme(4, MacAddress([0x00, 0x0a, 0x35, 0x05, 0x0f, 0xd8])),
            CardInfoItem::FanPresence(b'P' as char),
            CardInfoItem::ConfigMode(ConfigMode::MasterSpiX4),
            CardInfoItem::TotalPowerAvail(TotalPowerAvail::Power75W),
            CardInfoItem::SatelliteVersion(b"5.0".to_vec().into()),
        ]);
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
