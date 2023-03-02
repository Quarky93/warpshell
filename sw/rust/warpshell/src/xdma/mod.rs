use crate::{BaseParam, BasedCtrlOps, BasedDmaOps, DmaBuffer, Result as BasedResult};
use arrayvec::ArrayVec;
use once_cell::sync::OnceCell;
use std::fs::{File, OpenOptions};
use std::io::Error as IoError;
use std::os::unix::fs::FileExt;
use thiserror::Error;

pub static CTRL_CHANNEL: OnceCellCtrlChannel = OnceCellCtrlChannel {
    cdev_path: "/dev/xdma0_user",
    channel: OnceCell::new(),
};

pub static DMA_CHANNEL0: OnceCellDmaChannel = OnceCellDmaChannel {
    h2c_cdev_path: "/dev/xdma0_h2c_0",
    c2h_cdev_path: "/dev/xdma0_c2h_0",
    channel: OnceCell::new(),
};

/// Memory alignment for optimal performance of DMA reads and writes.
pub const DMA_ALIGNMENT: u64 = 4096;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug, Error)]
pub enum Error {
    #[error("Control read failed: {0}")]
    CtrlReadFailed(IoError),
    #[error("Control write failed: {0}")]
    CtrlWriteFailed(IoError),
    #[error("DMA read failed on channel {n_channel}: {err}")]
    DmaReadFailed { n_channel: usize, err: IoError },
    #[error("DMA write failed on channel {n_channel}: {err}")]
    DmaWriteFailed { n_channel: usize, err: IoError },
    #[error("Device node error: {0}")]
    DevNode(IoError),
}

/// Readable and writable user channel represented by a single file
#[derive(Debug)]
pub struct CtrlChannel(pub File);

/// DMA channel represented by a couple files, one for reading and another for writing
#[derive(Debug)]
pub struct DmaChannel {
    /// Host to card character device
    pub h2c_cdev: File,
    /// Card to host character device
    pub c2h_cdev: File,
}

/// All available DMA channels for a given shell
pub struct DmaChannels<'a, const N: usize> {
    pub inner: ArrayVec<&'a DmaChannel, N>,
}

impl<'a, const N: usize> From<[&'a DmaChannel; N]> for DmaChannels<'a, N> {
    fn from(channels: [&'a DmaChannel; N]) -> Self {
        Self {
            inner: ArrayVec::from(channels),
        }
    }
}

pub trait CtrlOps {
    fn ctrl_read(&self, buf: &mut [u8], offset: u64) -> Result<()>;
    fn ctrl_write(&self, buf: &[u8], offset: u64) -> Result<()>;
}

impl CtrlOps for CtrlChannel {
    #[inline]
    fn ctrl_read(&self, buf: &mut [u8], offset: u64) -> Result<()> {
        self.0
            .read_exact_at(buf, offset)
            .map_err(Error::CtrlReadFailed)
    }

    #[inline]
    fn ctrl_write(&self, buf: &[u8], offset: u64) -> Result<()> {
        self.0
            .write_all_at(buf, offset)
            .map_err(Error::CtrlWriteFailed)
    }
}

pub trait GetCtrlChannel {
    fn get_ctrl_channel(&self) -> &CtrlChannel;
}

impl<T> BasedCtrlOps for T
where
    T: GetCtrlChannel + BaseParam,
{
    #[inline]
    fn based_ctrl_read_u32(&self, offset: u64) -> BasedResult<u32> {
        let mut data = [0u8; 4];
        self.get_ctrl_channel()
            .ctrl_read(&mut data, T::BASE_ADDR + offset)?;
        Ok(u32::from_le_bytes(data))
    }

    #[inline]
    fn based_ctrl_write_u32(&self, offset: u64, value: u32) -> BasedResult<()> {
        let data = value.to_le_bytes();
        Ok(self
            .get_ctrl_channel()
            .ctrl_write(&data, T::BASE_ADDR + offset)?)
    }
}

pub trait DmaOps {
    fn dma_read(&self, buf: &mut DmaBuffer, offset: u64) -> Result<()>;
    fn dma_write(&self, buf: &DmaBuffer, offset: u64) -> Result<()>;
}

impl DmaOps for DmaChannel {
    #[inline]
    fn dma_read(&self, buf: &mut DmaBuffer, offset: u64) -> Result<()> {
        self.c2h_cdev
            .read_exact_at(buf.as_mut_slice(), offset)
            .map_err(|err| Error::DmaReadFailed { n_channel: 0, err })
    }

    #[inline]
    fn dma_write(&self, buf: &DmaBuffer, offset: u64) -> Result<()> {
        self.h2c_cdev
            .write_all_at(buf.as_slice(), offset)
            .map_err(|err| Error::DmaWriteFailed { n_channel: 0, err })
    }
}

pub trait GetDmaChannel {
    fn get_dma_channel(&self) -> &DmaChannel;
}

impl<T> BasedDmaOps for T
where
    T: GetDmaChannel + BaseParam,
{
    #[inline]
    fn based_dma_read(&self, buf: &mut DmaBuffer, offset: u64) -> BasedResult<()> {
        Ok(self
            .get_dma_channel()
            .dma_read(buf, T::BASE_ADDR + offset)?)
    }

    #[inline]
    fn based_dma_write(&self, buf: &DmaBuffer, offset: u64) -> BasedResult<()> {
        Ok(self
            .get_dma_channel()
            .dma_write(buf, T::BASE_ADDR + offset)?)
    }
}

pub struct OnceCellCtrlChannel {
    pub cdev_path: &'static str,
    pub channel: OnceCell<CtrlChannel>,
}

impl OnceCellCtrlChannel {
    pub fn get_or_init(&self) -> Result<&CtrlChannel> {
        let cdev = OpenOptions::new()
            .read(true)
            .write(true)
            .open(self.cdev_path)
            .map_err(Error::DevNode)?;
        Ok(self.channel.get_or_init(|| CtrlChannel(cdev)))
    }
}

pub struct OnceCellDmaChannel {
    pub h2c_cdev_path: &'static str,
    pub c2h_cdev_path: &'static str,
    pub channel: OnceCell<DmaChannel>,
}

impl OnceCellDmaChannel {
    pub fn get_or_init(&self) -> Result<&DmaChannel> {
        // For some reason `File::open` doesn't return a valid descriptor.
        let h2c_cdev = File::create(self.h2c_cdev_path).map_err(Error::DevNode)?;
        let c2h_cdev = File::open(self.c2h_cdev_path).map_err(Error::DevNode)?;
        Ok(self
            .channel
            .get_or_init(|| DmaChannel { h2c_cdev, c2h_cdev }))
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use assert_matches::assert_matches;

    #[test]
    fn dma_buffer_alignment() {
        const BUF_LEN: usize = 42;

        let mut buf = DmaBuffer::new(BUF_LEN);
        buf.get_mut().extend_from_slice(&[0u8; BUF_LEN]);

        let ptr = buf.as_mut_slice().as_mut_ptr();
        let len = buf.get().len();
        let cap = buf.get().capacity();

        assert_eq!(ptr as u64 % DMA_ALIGNMENT, 0);
        assert_eq!(len, BUF_LEN);
        assert_eq!(cap, DMA_ALIGNMENT as usize);
    }

    #[test]
    fn file_write_all_at() {
        let n: u64 = rand::random();
        let f = File::create(format!("/tmp/xdma-test-{n}")).expect("cannot create file");
        let buf = vec![b'A', b'B', b'C'];
        f.write_all_at(buf.as_slice(), 0)
            .expect("write test failed");
    }

    #[test]
    fn one_cell_ctrl_absent() {
        let absent_ctrl_channel = OnceCellCtrlChannel {
            cdev_path: "/a/file/that/doesnt/exist",
            channel: OnceCell::new(),
        };

        assert_matches!(absent_ctrl_channel.get_or_init(), Err(Error::DevNode(_)));
    }

    #[test]
    fn one_cell_dma_absent() {
        let absent_dma_channel = OnceCellDmaChannel {
            h2c_cdev_path: "/a/file/that/doesnt/exist/1",
            c2h_cdev_path: "/a/file/that/doesnt/exist/2",
            channel: OnceCell::new(),
        };

        assert_matches!(absent_dma_channel.get_or_init(), Err(Error::DevNode(_)));
    }
}
