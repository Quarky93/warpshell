use arrayvec::ArrayVec;
use std::fs::File;
use std::io::Error as IoError;
use std::mem;
use std::os::unix::fs::FileExt;

/// Memory alignment for optimal performance of DMA reads and writes.
pub const DMA_ALIGNMENT: u64 = 4096;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug)]
pub enum Error {
    ShellReadFailed(IoError),
    ShellWriteFailed(IoError),
    DmaReadFailed { n_channel: usize, err: IoError },
    DmaWriteFailed { n_channel: usize, err: IoError },
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
pub struct UserChannel(pub File);

/// DMA channel represented by a couple files, one for reading and another for writing
#[derive(Debug)]
pub struct DmaChannel {
    /// Host to card character device
    pub h2c_cdev: File,
    /// Card to host character device
    pub c2h_cdev: File,
}

/// All available DMA channels for a given shell
pub struct DmaChannels<const N: usize> {
    pub inner: ArrayVec<DmaChannel, N>,
}

impl<const N: usize> From<[DmaChannel; N]> for DmaChannels<N> {
    fn from(channels: [DmaChannel; N]) -> Self {
        Self {
            inner: ArrayVec::from(channels),
        }
    }
}

pub trait UserOps {
    fn user_read(&self, buf: &mut [u8], offset: u64) -> Result<()>;
    fn user_write(&self, buf: &[u8], offset: u64) -> Result<()>;
}

impl UserOps for UserChannel {
    fn user_read(&self, buf: &mut [u8], offset: u64) -> Result<()> {
        self.0
            .read_exact_at(buf, offset)
            .map_err(Error::ShellReadFailed)
    }

    fn user_write(&self, buf: &[u8], offset: u64) -> Result<()> {
        self.0
            .write_all_at(buf, offset)
            .map_err(Error::ShellWriteFailed)
    }
}

pub trait DmaOps {
    fn dma_read(&self, n_channel: usize, buf: &mut DmaBuffer, offset: u64) -> Result<()>;
    fn dma_write(&self, n_channel: usize, buf: &DmaBuffer, offset: u64) -> Result<()>;
}

impl<const N: usize> DmaOps for DmaChannels<N> {
    fn dma_read(&self, n_channel: usize, buf: &mut DmaBuffer, offset: u64) -> Result<()> {
        self.inner[n_channel]
            .c2h_cdev
            .read_exact_at(buf.as_mut_slice(), offset)
            .map_err(|err| Error::DmaReadFailed { n_channel, err })
    }

    fn dma_write(&self, n_channel: usize, buf: &DmaBuffer, offset: u64) -> Result<()> {
        self.inner[n_channel]
            .h2c_cdev
            .write_all_at(buf.as_slice(), offset)
            .map_err(|err| Error::DmaWriteFailed { n_channel, err })
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn dma_buffer_alignment() {
        const BUF_LEN: usize = 42;

        let mut buf = DmaBuffer::new(BUF_LEN);
        buf.get_mut().extend_from_slice(&vec![0u8; BUF_LEN]);

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
        let f = File::create(format!("/tmp/xdma-test-{:x}", n)).expect("cannot create file");
        let buf = vec![b'A', b'B', b'C'];
        f.write_all_at(buf.as_slice(), 0)
            .expect("write test failed");
    }
}
