use crate::BaseParam;
use arrayvec::ArrayVec;
use once_cell::sync::OnceCell;
use std::fs::{File, OpenOptions};
use std::io::Error as IoError;
use std::mem;
use std::os::unix::fs::FileExt;

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

#[derive(Debug)]
pub enum Error {
    CtrlReadFailed(IoError),
    CtrlWriteFailed(IoError),
    DmaReadFailed { n_channel: usize, err: IoError },
    DmaWriteFailed { n_channel: usize, err: IoError },
    DevNode(IoError),
}

#[repr(C, align(4096))]
struct Align4K([u8; 4096]);

/// DMA-engine aligned buffer. Non-reallocatable since reallocations do not preserve alignment. The
/// size has to be known before creation.
#[derive(Debug)]
pub struct DmaBuffer(Vec<u8>);

impl DmaBuffer {
    pub fn new(n_bytes: usize) -> Self {
        Self(unsafe { aligned_vec(n_bytes) })
    }

    pub fn as_slice(&self) -> &[u8] {
        self.0.as_slice()
    }

    pub fn as_mut_slice(&mut self) -> &mut [u8] {
        self.0.as_mut_slice()
    }

    pub fn get(&self) -> &Vec<u8> {
        &self.0
    }

    pub fn get_mut(&mut self) -> &mut Vec<u8> {
        &mut self.0
    }
}

unsafe fn aligned_vec(n_bytes: usize) -> Vec<u8> {
    let n_units = (n_bytes / mem::size_of::<Align4K>()) + 1;

    let mut aligned: Vec<Align4K> = Vec::with_capacity(n_units);

    let ptr = aligned.as_mut_ptr();
    let len_units = aligned.len();
    let cap_units = aligned.capacity();

    mem::forget(aligned);

    Vec::from_raw_parts(
        ptr as *mut u8,
        len_units * mem::size_of::<Align4K>(),
        cap_units * mem::size_of::<Align4K>(),
    )
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

/// IO operations on an offset memory-mapped component via a user channel
pub trait BasedCtrlOps {
    fn based_ctrl_read_u32(&self, offset: u64) -> Result<u32>;
    fn based_ctrl_write_u32(&self, offset: u64, value: u32) -> Result<()>;
}

pub trait GetCtrlChannel {
    fn get_ctrl_channel(&self) -> &CtrlChannel;
}

impl<T> BasedCtrlOps for T
where
    T: GetCtrlChannel + BaseParam,
{
    #[inline]
    fn based_ctrl_read_u32(&self, offset: u64) -> Result<u32> {
        let mut data = [0u8; 4];
        self.get_ctrl_channel()
            .ctrl_read(&mut data, T::BASE_ADDR + offset)?;
        Ok(u32::from_le_bytes(data))
    }

    #[inline]
    fn based_ctrl_write_u32(&self, offset: u64, value: u32) -> Result<()> {
        let data = value.to_le_bytes();
        self.get_ctrl_channel()
            .ctrl_write(&data, T::BASE_ADDR + offset)
    }
}

pub trait DmaOps {
    fn dma_read(&self, buf: &mut DmaBuffer, offset: u64) -> Result<()>;
    fn dma_write(&self, buf: &DmaBuffer, offset: u64) -> Result<()>;
}

impl DmaOps for DmaChannel {
    fn dma_read(&self, buf: &mut DmaBuffer, offset: u64) -> Result<()> {
        self.c2h_cdev
            .read_exact_at(buf.as_mut_slice(), offset)
            .map_err(|err| Error::DmaReadFailed { n_channel: 0, err })
    }

    fn dma_write(&self, buf: &DmaBuffer, offset: u64) -> Result<()> {
        self.h2c_cdev
            .write_all_at(buf.as_slice(), offset)
            .map_err(|err| Error::DmaWriteFailed { n_channel: 0, err })
    }
}

/// IO operations on an offset memory-mapped component via a DMA channel
pub trait BasedDmaOps {
    fn based_dma_read(&self, buf: &mut DmaBuffer, offset: u64) -> Result<()>;
    fn based_dma_write(&self, buf: &DmaBuffer, offset: u64) -> Result<()>;
}

pub trait GetDmaChannel {
    fn get_dma_channel(&self) -> &DmaChannel;
}

impl<T> BasedDmaOps for T
where
    T: GetDmaChannel + BaseParam,
{
    #[inline]
    fn based_dma_read(&self, buf: &mut DmaBuffer, offset: u64) -> Result<()> {
        self.get_dma_channel().dma_read(buf, T::BASE_ADDR + offset)
    }

    #[inline]
    fn based_dma_write(&self, buf: &DmaBuffer, offset: u64) -> Result<()> {
        self.get_dma_channel().dma_write(buf, T::BASE_ADDR + offset)
    }
}

// pub trait DmaOps {
//     fn dma_read(&self, n_channel: usize, buf: &mut DmaBuffer, offset: u64) -> Result<()>;
//     fn dma_write(&self, n_channel: usize, buf: &DmaBuffer, offset: u64) -> Result<()>;
// }

// impl<'a, const N: usize> DmaOps for DmaChannels<'a, N> {
//     fn dma_read(&self, n_channel: usize, buf: &mut DmaBuffer, offset: u64) -> Result<()> {
//         self.inner[n_channel]
//             .c2h_cdev
//             .read_exact_at(buf.as_mut_slice(), offset)
//             .map_err(|err| Error::DmaReadFailed { n_channel, err })
//     }

//     fn dma_write(&self, n_channel: usize, buf: &DmaBuffer, offset: u64) -> Result<()> {
//         self.inner[n_channel]
//             .h2c_cdev
//             .write_all_at(buf.as_slice(), offset)
//             .map_err(|err| Error::DmaWriteFailed { n_channel, err })
//     }
// }

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
}
