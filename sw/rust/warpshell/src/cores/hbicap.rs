//! Xilinx AXI High Bandwidth Internal Configuration Access Port (HBICAP)
//!
//! **WARNING: NOT TESTED!!!**

use crate::{BasedCtrlOps, BasedDmaOps, DmaBuffer, Error as BasedError};
use enum_iterator::Sequence;
use std::mem::size_of;
use thiserror::Error;

const MAX_BURST_SIZE: u32 = 256;
// const AXI_MM_WORD_BYTES: usize = 4;

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

pub trait GetHbicapIf<C: BasedCtrlOps, D: BasedDmaOps> {
    fn get_ctrl_if(&self) -> &C;
    fn get_dma_if(&self) -> &D;
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

    /// Read `n_bytes` from the configured AXI interface into `buf`. The size read from the
    /// interface is `n_bytes` rounded up to the nearest multiple of `AXI_MM_WORD_BYTES`.
    fn read_axi(&self, buf: &mut DmaBuffer, _n_bytes: usize) -> Result<()> {
        // TODO

        Ok(self.get_dma_if().based_dma_read(buf, 0)?)
    }

    /// Write the entire `buf` to configured AXI interface: MM or Stream.
    fn write_axi(&self, buf: &DmaBuffer) -> Result<()> {
        Ok(self.get_dma_if().based_dma_write(buf, 0)?)
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
