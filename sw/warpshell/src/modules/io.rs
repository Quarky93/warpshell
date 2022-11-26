use std::{fs::File, os::unix::prelude::FileExt};
use anyhow::Result;

pub trait Readable {
    fn read(&self, buf: &mut [u8], offset: u64) -> Result<()>;

    fn read_u32(&self, offset: u64) -> Result<u32> {
        let mut buf: [u8; 4] = [0; 4];
        self.read(&mut buf, offset)?;
        Ok(u32::from_le_bytes(buf))
    }

    fn read_u64(&self, offset: u64) -> Result<u64> {
        let mut buf: [u8; 8] = [0; 8];
        self.read(&mut buf, offset)?;
        Ok(u64::from_le_bytes(buf))
    }
}

pub trait Writable {
    fn write(&self, buf: &[u8], offset: u64) -> Result<()>;

    fn write_u32(&self, data: u32, offset: u64) -> Result<()> {
        self.write(&data.to_le_bytes(), offset)
    }

    fn write_u64(&self, data: u64, offset: u64) -> Result<()> {
        self.write(&data.to_le_bytes(), offset)
    }
}

pub trait ReadWritable: Readable + Writable {}

pub struct ReadableCdev {
    pub cdev: File
}

pub struct WritableCdev {
    pub cdev: File
}

pub struct ReadWritableCdev {
    pub cdev: File
}

impl Readable for ReadableCdev {
    fn read(&self, buf: &mut [u8], offset: u64) -> Result<()> {
        self.cdev.read_exact_at(buf, offset).map_err(anyhow::Error::from)
    }
}

impl Writable for WritableCdev {
    fn write(&self, buf: &[u8], offset: u64) -> Result<()> {
        self.cdev.write_all_at(buf, offset).map_err(anyhow::Error::from)
    }
}

impl Readable for ReadWritableCdev {
    fn read(&self, buf: &mut [u8], offset: u64) -> Result<()> {
        self.cdev.read_exact_at(buf, offset).map_err(anyhow::Error::from)
    }
}

impl Writable for ReadWritableCdev {
    fn write(&self, buf: &[u8], offset: u64) -> Result<()> {
        self.cdev.write_all_at(buf, offset).map_err(anyhow::Error::from)
    }
}

impl ReadWritable for ReadWritableCdev {}