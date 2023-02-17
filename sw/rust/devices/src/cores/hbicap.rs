//! Xilinx AXI High Bandwidth Internal Configuration Access Port (HBICAP)
//!
//! **WARNING: NOT TESTED!!!**

use crate::{xdma::Error as XdmaError, BasedCtrlOps, BasedDmaOps, DmaBuffer};
use enum_iterator::Sequence;
use thiserror::Error;

const MAX_BURST_SIZE: u32 = 256;
const AXI_MM_WORD_BYTES: usize = 4;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Error, Debug)]
pub enum Error {
    #[error("XDMA failed: {0}")]
    XdmaFailed(#[from] XdmaError),
}

#[derive(Copy, Clone, Debug, Sequence, PartialEq)]
#[repr(u64)]
pub enum HbicapReg {
    GlobalIntEn = 0x1c,
    IntStatus = 0x20,
    IpIntEn = 0x28,
    Size = 0x108,
    Control = 0x10c,
    Status = 0x110,
    WriteFifoVacancy = 0x114,
    ReadFifoOccupancy = 0x118,
    AbortStatus = 0x11c,
}

#[repr(u32)]
pub enum ControlRegBit {
    Read = 1 << 1,
    FifoClear = 1 << 2,
    SwReset = 1 << 3,
    Abort = 1 << 4,
    Lock = 1 << 5,
    SetAdditionalReadDelay = 1 << 11,
}

#[repr(u32)]
pub enum StatusRegBit {
    Idle = 1 << 0,
    Read = 1 << 2,
}

pub struct HbicapIfs<C, D> {
    ctrl_if: C,
    dma_if: D,
}

pub trait HbicapOps {
    /// Reads the value of an HBICAP register.
    fn get_hbicap_reg(&self, reg: HbicapReg) -> Result<u32>;

    /// Writes a value to an HBICAP register.
    fn set_hbicap_reg(&self, reg: HbicapReg, value: u32) -> Result<()>;

    /// Read `n_bytes` from the configured AXI interface into `buf`. The size read from the
    /// interface is `n_bytes` rounded up to the nearest multiple of `AXI_MM_WORD_BYTES`.
    fn read_axi(&self, buf: &mut DmaBuffer, n_bytes: usize) -> Result<()>;

    /// Write the entire `buf` to configured AXI interface: MM or Stream.
    fn write_axi(&self, buf: &DmaBuffer) -> Result<()>;

    /// Read programming sequence.
    fn read_programming(&self, bitstream: &[u8]) -> Result<()> {
        // Program the Size register with the number of words you want to write.
        let size = todo!();
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
    fn write_programming(&self, bitstream: &[u8]) -> Result<()> {
        let mut len = bitstream.len() as u32;

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

impl<C, D> HbicapOps for HbicapIfs<C, D>
where
    C: BasedCtrlOps<XdmaError>,
    D: BasedDmaOps<XdmaError>,
{
    fn get_hbicap_reg(&self, reg: HbicapReg) -> Result<u32> {
        Ok(self.ctrl_if.based_ctrl_read_u32(reg as u64)?)
    }

    fn set_hbicap_reg(&self, reg: HbicapReg, value: u32) -> Result<()> {
        Ok(self.ctrl_if.based_ctrl_write_u32(reg as u64, value)?)
    }

    fn read_axi(&self, buf: &mut DmaBuffer, _n_bytes: usize) -> Result<()> {
        // TODO

        Ok(self.dma_if.based_dma_read(buf, 0)?)
    }

    fn write_axi(&self, buf: &DmaBuffer) -> Result<()> {
        Ok(self.dma_if.based_dma_write(buf, 0)?)
    }
}
