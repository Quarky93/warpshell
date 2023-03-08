//! # Xilinx AXI High Bandwidth Internal Configuration Access Port (HBICAP)
//!
//! **WARNING: NOT TESTED!!!**

use crate::{BasedCtrlOps, BasedDmaOps, DmaBuffer, Error as BasedError};
use enum_iterator::Sequence;
use std::{mem::size_of, time::Duration};
use thiserror::Error;

const MAX_BURST_SIZE: u32 = 256;
const AXI_WORD_BYTES: usize = 4;

/// ICAP commands
const DUMMY_CMD: u32 = 0xffff_ffff;
const BUS_WIDTH_SYNC_CMD: u32 = 0x0000_00bb;
const BUS_WIDTH_DETECT_CMD: u32 = 0x1122_0044;
const SYNC_CMD: u32 = 0xaa99_5566;

const TYPE1_N_WORDS_MASK: u32 = 0x0000_07ff;
const TYPE2_N_WORDS_MASK: u32 = 0x07ff_ffff;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Error, Debug)]
pub enum Error {
    #[error("Based access error: {0}")]
    BasedError(#[from] BasedError),
}

/// HBICAP core register memory offsets.
#[derive(Copy, Clone, Debug, Sequence, PartialEq)]
#[repr(u64)]
pub enum HbicapReg {
    GlobalIntEn = 0x1c,
    IntStatus = 0x20,
    IpIntEn = 0x28,
    /// 30-bit write-only register that determines the number of 32-bit words to be transferred from
    /// the ICAPEn to the read FIFO and from the write FIFO to the ICAP. This signifies the number
    /// of 32-bit data beats that are expected.
    Size = 0x108,
    /// 32-bit read/write register that determines the direction of the data transfer. It controls
    /// whether a configuration or a readback occurs. Writing to this register initiates the
    /// transfer.
    Control = 0x10c,
    /// 32-bit read register that contains the ICAPEn status bits.
    Status = 0x110,
    /// 32-bit read only register that indicates the vacancy of the write FIFO. The actual depth of
    /// the write FIFO is one less than the value specified during customization. For example, if
    /// the write FIFO depth is set to 1024 during customization, the actual FIFO depth is
    /// 1023. This register reports the actual write FIFO vacancy.
    WriteFifoVacancy = 0x114,
    /// 32-bit read-only register that indicates occupancy of the read FIFO. The actual depth of the
    /// read FIFO is one less than the value specified during customization. For example, if the
    /// read FIFO depth is set to 256 during customization, the actual FIFO depth is 255. This
    /// register reports the actual read FIFO occupancy.
    ReadFifoOccupancy = 0x118,
    /// Abort status of the ICAPEn during the configuration or reading the configuration.
    AbortStatus = 0x11c,
}

/// Control register R/W bits.
#[repr(u32)]
pub enum ControlRegBit {
    /// 1 = Initiate ICAPEn Read.
    Read = 1 << 1,
    /// 1 = Clears the FIFOs.
    FifoClear = 1 << 2,
    /// 1 = Resets all the registers.
    SwReset = 1 << 3,
    /// 1 = Aborts the read or write of the ICAPEn and clears the FIFOs.
    Abort = 1 << 4,
    /// 0 = Unlock, cap_req does not depend on this bit. 1 = Lock, cap_req output is ORed with
    /// this bit, which locks the access to the ICAP.
    Lock = 1 << 5,
    /// Setting this bit to 1 loads the value in bits 6..10.
    SetAdditionalReadDelay = 1 << 11,
}

/// Read-only status register bits.
#[repr(u32)]
pub enum StatusRegBit {
    /// 1 = Idle / Done with previous operation (configuration or read), 0 = Busy.
    Idle = 1 << 0,
    /// End-of-startup bit: Indicates that the EOS is complete. The ICAPEn can be accessed only when
    /// this bit is 1.
    Eos = 1 << 2,
}

#[repr(u32)]
pub enum PacketType {
    Type1 = 0b001,
    Type2 = 0b010,
}

#[repr(u32)]
pub enum Opcode {
    Noop = 0b00,
    Read = 0b01,
    Write = 0b10,
}

/// Xilinx 7/US/US+ FPGA configuration control logic registers. Bits `[26:13]` of a type 1 packet
/// header word.
#[repr(u32)]
pub enum FpgaConfigReg {
    /// [R/W] CRC register
    Crc = 0b00000,
    /// [R/W] Frame address register
    Far = 0b00001,
    /// [W] Frame data register, input register (write configuration data)
    Fdri = 0b00010,
    /// [R] Frame data register, output register (read configuration data)
    Fdro = 0b00011,
    /// [R/W] Command register
    Cmd = 0b00100,
    /// [R/W] Control register 0
    Ctl0 = 0b00101,
    /// [R/W] Masking register for CTL0 and CTL1
    Mask = 0b00110,
    /// [R] Status register
    Stat = 0b00111,
    /// [W] Legacy output register for daisy chain
    Lout = 0b01000,
    /// [R/W] Configuration option register 0
    Cor0 = 0b01001,
    /// [W] Multiple frame write register
    Mfwr = 0b01011,
    /// [W] Initial CBC value register
    Cbc = 0b01010,
    /// [R/W] Device ID register
    Idcode = 0b01100,
    /// [R/W] User access register
    Axss = 0b01101,
    /// [R/W] Configuration option register 1
    Cor1 = 0b01110,
    /// [R/W] Warm boot start address register
    Wbstar = 0b10000,
    /// [R/W] Watchdog timer register
    Timer = 0b10001,
    /// [R] Boot history status register
    Bootsts = 0b10110,
    /// [R/W] Control register 1
    Ctl1 = 0b11000,
    /// [R/W] BPI/SPI configuration options register
    Bspi = 0b11111,
}

/// TODO. Command config register codes. US Arch Config UG570, p. 164.
#[repr(u32)]
pub enum CmdRegCode {
    /// Null command, no action.
    Null = 0b00000,
    /// Begins the start-up sequence: start-up sequence begins after a successful CRC check and a
    /// DESYNC command are performed.
    Start = 0b00101,
    /// Resets the DALIGN signal: Used at the end of configuration to desynchronize the
    /// device. After desynchronization, all values on the configuration data pins are ignored.
    Desync = 0b01101,
}

pub struct Type1Packet {
    /// Bits [28:27]
    opcode: Opcode,
    /// Bits [26:13]
    reg: FpgaConfigReg,
    /// Bits [10:0]
    n_words: u32,
}

impl Type1Packet {
    pub fn new(opcode: Opcode, reg: FpgaConfigReg, n_words: u32) -> Self {
        Self {
            opcode,
            reg,
            n_words,
        }
    }
}

impl Into<u32> for Type1Packet {
    fn into(self) -> u32 {
        (PacketType::Type1 as u32) << 29
            | (self.opcode as u32) << 27
            | (self.reg as u32) << 13
            | (self.n_words & TYPE1_N_WORDS_MASK)
    }
}

pub struct Type2Packet {
    /// Bits [28:27]
    opcode: Opcode,
    /// Bits [26:0]
    n_words: u32,
}

impl Type2Packet {
    pub fn new(opcode: Opcode, n_words: u32) -> Self {
        Self { opcode, n_words }
    }
}

impl Into<u32> for Type2Packet {
    fn into(self) -> u32 {
        (PacketType::Type2 as u32) << 29
            | (self.opcode as u32) << 27
            | (self.n_words & TYPE2_N_WORDS_MASK)
    }
}

/// Memory-mapped interface to an HBICAP core. Instantiating this trait suffices as a definition of
/// `HbicapOps` which is implemented automatically in that case.
pub trait GetHbicapIf<C: BasedCtrlOps, D: BasedDmaOps> {
    fn get_ctrl_if(&self) -> &C;
    fn get_dma_if(&self) -> &D;
}

impl<C, D, T> HbicapOps<C, D> for T
where
    C: BasedCtrlOps,
    D: BasedDmaOps,
    T: GetHbicapIf<C, D>,
{
}

pub trait HbicapOps<C, D>: GetHbicapIf<C, D>
where
    C: BasedCtrlOps,
    D: BasedDmaOps,
{
    /// Reads the value of an HBICAP register.
    fn get_hbicap_reg(&self, reg: HbicapReg) -> Result<u32> {
        Ok(self.get_ctrl_if().based_ctrl_read_u32(reg as u64)?)
    }

    /// Writes a value to an HBICAP register.
    fn set_hbicap_reg(&self, reg: HbicapReg, value: u32) -> Result<()> {
        Ok(self.get_ctrl_if().based_ctrl_write_u32(reg as u64, value)?)
    }

    /// Checks if the core is in ready state.
    fn is_ready(&self) -> Result<bool> {
        let mask = StatusRegBit::Idle as u32 | StatusRegBit::Eos as u32;
        Ok(self.get_hbicap_reg(HbicapReg::Status)? & mask == mask)
    }

    /// Resets the core.
    fn reset(&self) -> Result<()> {
        let v = self.get_hbicap_reg(HbicapReg::Control)?
            | ControlRegBit::FifoClear as u32
            | ControlRegBit::SwReset as u32;
        self.set_hbicap_reg(HbicapReg::Control, v)
    }

    /// Writes the entire bitstream in one iteration.
    fn write_bitstream(&self, buf: &DmaBuffer) -> Result<()> {
        let n_words = ((buf.0.len() + (AXI_WORD_BYTES - 1)) / AXI_WORD_BYTES) as u32;
        self.set_hbicap_reg(HbicapReg::Size, n_words)?;
        Ok(self.get_dma_if().based_dma_write(buf, 0)?)
    }

    /// Fills in `buf` in one iteration.
    fn read_bitstream(&self, buf: &mut DmaBuffer) -> Result<()> {
        let n_words = (buf.0.capacity() / AXI_WORD_BYTES) as u32;
        self.set_hbicap_reg(HbicapReg::Size, n_words)?;
        self.set_hbicap_reg(
            HbicapReg::Control,
            self.get_hbicap_reg(HbicapReg::Control)? | ControlRegBit::Read as u32,
        )?;
        Ok(self.get_dma_if().based_dma_read(buf, 0)?)
    }

    fn status_readback(&self) -> Result<u32> {
        let noop: u32 = Type1Packet::new(Opcode::Noop, FpgaConfigReg::Crc, 0).into(); // = 0x2000_0000
        let opening_cmds: Vec<u32> = vec![
            DUMMY_CMD,
            BUS_WIDTH_SYNC_CMD,
            BUS_WIDTH_DETECT_CMD,
            DUMMY_CMD,
            SYNC_CMD,
            noop,
            Type1Packet::new(Opcode::Write, FpgaConfigReg::Stat, 1).into(),
            noop,
            noop,
        ];
        let closing_cmds: Vec<u32> = vec![
            Type1Packet::new(Opcode::Write, FpgaConfigReg::Cmd, 1).into(),
            CmdRegCode::Desync as u32,
            noop,
            noop,
        ];

        let mut write_buf = DmaBuffer::new(opening_cmds.len() * size_of::<u32>());
        for w in opening_cmds {
            write_buf.0.extend_from_slice(&w.to_le_bytes());
        }
        self.write_bitstream(&write_buf)?;

        let mut read_buf = DmaBuffer::new(size_of::<u32>());
        self.read_bitstream(&mut read_buf)?;

        // Reuse the allocated DMA buffer.
        write_buf.0.clear();
        for w in closing_cmds {
            write_buf.0.extend_from_slice(&w.to_le_bytes());
        }
        self.write_bitstream(&write_buf)?;

        let mut stat_bytes: [u8; 4] = [0; 4];
        stat_bytes.copy_from_slice(&read_buf.0[0..3]);
        Ok(u32::from_le_bytes(stat_bytes))
    }

    /// Polls for the ready status at 10 ms intervals for at 10 seconds, returning the elapsed number of polls.
    fn poll_ready_every_10ms(&self) -> Result<usize> {
        let mask = StatusRegBit::Idle as u32 | StatusRegBit::Eos as u32;
        Ok(self.get_ctrl_if().poll_reg_mask_sleep(
            HbicapReg::Status as u64,
            mask,
            mask,
            1_000,
            Duration::from_millis(10),
        )?)
    }

    /// Read programming sequence.
    fn read_programming(&self, bytes: &[u8]) -> Result<()> {
        // Program the Size register with the number of words you want to write.
        let size = (bytes.len() / size_of::<u32>()) as u32;
        self.set_hbicap_reg(HbicapReg::Size, size)?;

        // Send the first set of words you want to write to the ICAPEn using the memory mapped AXI4
        // interface using burst transactions.

        // Wait for the Done signal from the Status register, which indicates that the requested
        // number of words have been written on the ICAPEn interface.

        // Program the Size register again with the number of words to be read from the ICAPEn.
        // Program the Control register with a value of 0x00000002, which initiates a read on the
        // ICAPEn.

        // Use the read interfaces in one of the following ways.
        //
        // - Read using memory mapped AXI4 read burst transactions: Initiate memory mapped AXI4 read
        // burst transactions and continue the process until the required number of bytes are read
        // out.
        //
        // - Read using the AXI4-Stream interface: In this mode, the HBICAP core initiates the
        // stream transactions. Wait until TLAST, which indicates the end of the transfer.

        // Hardware clears the Control register bits after the successful completion of the data
        // transfer from the ICAPEn to the read FIFO.

        // Software should not initiate another read or configuration to the ICAPEn until the read
        // bit in the Control register is cleared.

        // Program the Size register with a second set of writes, which contains DE-SYNC and other
        // commands to terminate the Read operation on the ICAPEn.

        // Send the second set of words to be written to the ICAPEn using the memory mapped AXI4
        // interface using burst transactions.

        // The Done signal from the Status register indicates that the requested number of words
        // have been written on the ICAPEn interface.

        todo!()
    }

    /// Write programming sequence.
    fn write_programming(&self, bytes: &[u8]) -> Result<()> {
        let mut len = (bytes.len() / size_of::<u32>()) as u32;

        while len > 0 {
            // Program the number of words to be transferred to the Size register.
            let size = u32::min(MAX_BURST_SIZE, len);
            self.set_hbicap_reg(HbicapReg::Size, size)?;
            len -= size;

            // Send burst transactions from the memory mapped AXI4 interface. A maximum burst of 256
            // beats or words can be sent per transaction.

            // Monitor the Done bit in the Status register. This bit is set to '1' after all words
            // mentioned in the Size register are put on the ICAPEn interface and continue the process
            // until all bitstream words are written to the ICAPEn.
        }

        todo!()
    }

    /// Abort sequence.
    fn abort(&self) -> Result<()> {
        // Initiate a write or read of the ICAPEn using the steps in Programming Sequence, and while
        // waiting for the completion of the operation, perform the following steps.

        // Write a value of 0x00000010 to the Control register to initiate an abort.

        // The Done bit in the Status register indicates whether the abort operation is completed.

        // Read the Abort Status register that contains the four bytes read from the ICAPEn, which
        // indicates the status of the abort operation.

        // The hardware clears the Control register bits after the successful completion of the
        // abort-on read, abort-on configuration, or normal abort.

        // The software should not initiate another read or configuration to the ICAPEn until the
        // abort bit in the Control register is cleared.

        todo!()
    }
}
