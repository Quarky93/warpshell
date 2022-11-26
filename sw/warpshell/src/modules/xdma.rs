use super::io::{ReadWritableCdev, ReadableCdev, WritableCdev};
use std::fs::OpenOptions;

pub struct Xdma {
    pub user: Vec<ReadWritableCdev>,
    pub bypass: Vec<ReadWritableCdev>,
    pub h2c: Vec<WritableCdev>,
    pub c2h: Vec<ReadableCdev>,
}

impl Xdma {
    pub fn new(id: u32) -> Self {
        let user_cdev = OpenOptions::new()
            .read(true)
            .write(true)
            .open(format!("/dev/xdma{id}_user"));
        let mut user: Vec<ReadWritableCdev> = Vec::new();
        if user_cdev.is_ok() {
            user.push(ReadWritableCdev {
                cdev: user_cdev.unwrap(),
            });
        }

        let bypass_cdev = OpenOptions::new()
            .read(true)
            .write(true)
            .open(format!("/dev/xdma{id}_bypass"));
        let mut bypass: Vec<ReadWritableCdev> = Vec::new();
        if bypass_cdev.is_ok() {
            bypass.push(ReadWritableCdev {
                cdev: bypass_cdev.unwrap(),
            });
        }

        let mut h2c: Vec<WritableCdev> = Vec::new();
        for i in 0..4 {
            let h2c_cdev = OpenOptions::new()
                .read(true)
                .write(true)
                .open(format!("/dev/xdma{id}_h2c_{i}"));
            if h2c_cdev.is_ok() {
                h2c.push(WritableCdev {
                    cdev: h2c_cdev.unwrap(),
                });
            } else {
                break;
            }
        }

        let mut c2h: Vec<ReadableCdev> = Vec::new();
        for i in 0..4 {
            let c2h_cdev = OpenOptions::new()
                .read(true)
                .write(true)
                .open(format!("/dev/xdma{id}_c2h_{i}"));
            if c2h_cdev.is_ok() {
                c2h.push(ReadableCdev {
                    cdev: c2h_cdev.unwrap(),
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
