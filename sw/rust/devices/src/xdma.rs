use std::fs::File;
use std::os::unix::fs::FileExt;

#[derive(Debug)]
pub enum Error {
    CannotOpenFile(std::io::Error),
    ShellReadFailed,
    ShellWriteFailed,
    DmaReadFailed,
    DmaWriteFailed,
}

pub type Result<T> = std::result::Result<T, Error>;

pub struct XdmaDevice {
    pub id: u32,
    pub user: String,
    pub host_to_card: String,
    pub card_to_host: String,
    /// Card Management Solution subsystem
    pub cms_base_addr: u32,
    /// Interrupt Controller
    pub intc_base_addr: u32,
    /// High Bandwidth Internal Configuration Access Port
    pub hbicap_base_addr: u32,
}

pub trait XdmaOps {
    fn shell_read(&self, buf: &mut [u8], offset: u64) -> Result<()>;
    fn shell_write(&self, buf: &[u8], offset: u64) -> Result<()>;
    fn dma_read(&self, buf: &mut [u8], offset: u64) -> Result<()>;
    fn dma_write(&self, buf: &[u8], offset: u64) -> Result<()>;
}

impl XdmaOps for XdmaDevice {
    fn shell_read(&self, buf: &mut [u8], offset: u64) -> Result<()> {
        let file = File::open(&self.user).map_err(Error::CannotOpenFile)?;
        file.read_exact_at(buf, offset)
            .map_err(|_| Error::ShellReadFailed)
    }

    fn shell_write(&self, buf: &[u8], offset: u64) -> Result<()> {
        let file = File::open(&self.user).map_err(Error::CannotOpenFile)?;
        file.write_all_at(buf, offset)
            .map_err(|_| Error::ShellWriteFailed)
    }

    fn dma_read(&self, buf: &mut [u8], offset: u64) -> Result<()> {
        let file = File::open(&self.card_to_host).map_err(Error::CannotOpenFile)?;
        file.read_exact_at(buf, offset)
            .map_err(|_| Error::DmaReadFailed)
    }

    fn dma_write(&self, buf: &[u8], offset: u64) -> Result<()> {
        let file = File::open(&self.host_to_card).map_err(Error::CannotOpenFile)?;
        file.write_all_at(buf, offset)
            .map_err(|e| Error::DmaWriteFailed)
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn write_all() {
        let n: u64 = rand::random();
        let f = File::create(format!("/tmp/xdma-test-{:x}", n)).expect("cannot create file");
        let buf = vec![b'A', b'B', b'C'];
        f.write_all_at(buf.as_slice(), 0)
            .expect("write test failed");
    }
}
