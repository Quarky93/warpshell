use std::fs::File;
use std::io::SeekFrom;

pub enum Error {
    ShellReadFailed,
    ShellWriteFailed,
    DmaReadFailed,
    DmaWriteFailed,
}

pub type Result<T> = Result<T, Error>;

pub struct XdmaDevice {
    id: u32,
    user: File,
    host_to_card: File,
    card_to_host: File,
    /// Card Management Solution subsystem
    cms_baseaddr: u32,
    /// Interrupt Controller
    intc_baseaddr: u32,
    /// High Bandwidth Internal Configuration Access Port
    hbicap_baseaddr: u32,
}

pub trait XdmaAccess {
    fn shell_read(&self, buf: &mut [u8], offset: u64) -> Result<()>;
    fn shell_write(&self, buf: &[u8], offset: u64) -> Result<()>;
    fn dma_read(&self, buf: &mut [u8], offset: u64) -> Result<()>;
    fn dma_write(&self, buf: &[u8], offset: u64) -> Result<()>;
}

impl XdmaAccess for XdmaDevice {
    fn shell_read(&self, buf: &mut [u8], offset: u64) -> Result<()> {
        self.user.seek(SeekFrom::Start(offset));
        self.user
            .read_exact(&mut buf)
            .map_err(|_| Error::ShellReadFailed)
    }

    fn shell_write(&self, buf: &[u8], offset: u64) -> Result<()> {
        self.user.seek(SeekFrom::Start(offset));
        self.user
            .write_all(buf)
            .map_err(|_| Error::ShellWriteFailed)
    }

    fn dma_read(&self, buf: &mut [u8], offset: u64) -> Result<()> {
        self.user.seek(SeekFrom::Start(offset));
        self.user
            .read_exact(&mut buf)
            .map_err(|_| Error::DmaReadFailed)
    }

    fn dma_write(&self, buf: &[u8], offset: u64) -> Result<()> {
        self.user.seek(SeekFrom::Start(offset));
        self.user.write_all(buf).map_err(|_| Error::UserWriteFailed)
    }
}
