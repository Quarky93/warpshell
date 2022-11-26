use super::io::{Readable, Writable, ReadWritable};
use std::{fs::{File, OpenOptions}, os::unix::prelude::FileExt};

pub struct UserCdev {
    fd: File,
}

pub struct H2cCdev {
    fd: File,
}

pub struct C2hCdev {
    fd: File,
}

impl Readable for UserCdev {
    // The /dev/xdma0_user cdev does not automatically break up read/write calls to 4-byte transactions.
    fn read(&self, buf: &mut [u8], offset: u64) {
        let mut i = 0;
        let chunks = buf.chunks_mut(4);
        for chunk in chunks {
            self.fd.read_exact_at(chunk, offset + i).unwrap();
            i += 4;
        }
    }
}

impl Writable for UserCdev {
    // The /dev/xdma0_user cdev does not automatically break up read/write calls to 4-byte transactions.
    fn write(&self, buf: &[u8], offset: u64) {
        let mut i = 0;
        let chunks = buf.chunks(4);
        for chunk in chunks {
            self.fd.write_all_at(chunk, offset + i).unwrap();
            i += 4;
        }
    }
}

impl ReadWritable for UserCdev {}

impl Readable for C2hCdev {
    fn read(&self, buf: &mut [u8], offset: u64) {
        self.fd.read_exact_at(buf, offset).unwrap();
    }
}

impl Writable for C2hCdev {
    fn write(&self, buf: &[u8], offset: u64) {
        self.fd.write_all_at(buf, offset).unwrap();
    }
}

pub struct Xdma {
    pub user: Vec<UserCdev>,
    pub bypass: Vec<H2cCdev>,
    pub h2c: Vec<H2cCdev>,
    pub c2h: Vec<C2hCdev>,
}

impl Xdma {
    pub fn new(id: u32) -> Self {
        let user_fd = OpenOptions::new()
            .read(true)
            .write(true)
            .open(format!("/dev/xdma{id}_user"));
        let mut user: Vec<UserCdev> = Vec::new();
        if user_fd.is_ok() {
            user.push(UserCdev {
                fd: user_fd.unwrap(),
            });
        }

        let bypass_fd = OpenOptions::new()
            .read(true)
            .write(true)
            .open(format!("/dev/xdma{id}_bypass"));
        let mut bypass: Vec<H2cCdev> = Vec::new();
        if bypass_fd.is_ok() {
            bypass.push(H2cCdev {
                fd: bypass_fd.unwrap(),
            });
        }

        let mut h2c: Vec<H2cCdev> = Vec::new();
        for i in 0..4 {
            let h2c_fd = OpenOptions::new()
                .read(true)
                .write(true)
                .open(format!("/dev/xdma{id}_h2c_{i}"));
            if h2c_fd.is_ok() {
                h2c.push(H2cCdev {
                    fd: h2c_fd.unwrap(),
                });
            } else {
                break;
            }
        }

        let mut c2h: Vec<C2hCdev> = Vec::new();
        for i in 0..4 {
            let c2h_fd = OpenOptions::new()
                .read(true)
                .write(true)
                .open(format!("/dev/xdma{id}_c2h_{i}"));
            if c2h_fd.is_ok() {
                c2h.push(C2hCdev {
                    fd: c2h_fd.unwrap(),
                });
            } else {
                break;
            }
        }

        Self {
            user: user,
            bypass: bypass,
            h2c: h2c,
            c2h: c2h,
        }
    }
}
