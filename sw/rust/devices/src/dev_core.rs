use crate::xdma::{Error as XdmaError, XdmaOps};

#[repr(u32)]
pub enum ControlRegBit {
    Start = 0b0001,            // (Read/Write/COH)
    Done = 0b0010,             // (Read/COR)
    Idle = 0b0100,             // (Read)
    Ready = 0b1000,            // (Read)
    AutoRestart = 0x1000_0000, // (Read/Write)
}

/// Development (Vitis HLS) core parameters
pub trait DevCoreParam {
    const BASE_ADDR: u64;
}

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug)]
pub enum Error {
    XdmaFailed(XdmaError),
}

impl From<XdmaError> for Error {
    fn from(e: XdmaError) -> Self {
        Self::XdmaFailed(e)
    }
}

pub trait DevCoreOps {
    /// Initialises the Card Management System
    fn compute(&mut self, x: u32) -> Result<u32>;
}

impl<T> DevCoreOps for T
where
    T: XdmaOps + DevCoreParam,
{
    fn compute(&mut self, x: u32) -> Result<u32> {
        let mut control_reg = 0;
        let mut control_bytes = [0u8; 4];

        // Wait for IDLE.
        while control_reg & ControlRegBit::Idle as u32 != ControlRegBit::Idle as u32 {
            self.shell_read(&mut control_bytes, T::BASE_ADDR)?;
            control_reg = u32::from_le_bytes(control_bytes);
        }

        // Write the input.
        let input = x.to_le_bytes();
        self.shell_write(&input, T::BASE_ADDR + 0x24)?;

        // Send the start command.
        let start_cmd = 0x1u32.to_le_bytes();
        self.shell_write(&start_cmd, T::BASE_ADDR)?;

        // Wait until DONE.
        control_reg = 0;
        while control_reg & ControlRegBit::Done as u32 != ControlRegBit::Done as u32 {
            self.shell_read(&mut control_bytes, T::BASE_ADDR)?;
            control_reg = u32::from_le_bytes(control_bytes);
        }

        // Read the output.
        let mut output = [0u8; 4];
        self.shell_read(&mut output, T::BASE_ADDR + 0x10)?;
        Ok(u32::from_le_bytes(output))
    }
}
