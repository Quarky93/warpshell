use super::io::{ReadWritableCdev, ReadableCdev, WritableCdev};
use std::fs::OpenOptions;

pub struct Xdma {
    pub user: Option<ReadWritableCdev>,
    pub bypass: Option<ReadWritableCdev>,
    pub h2c: Vec<WritableCdev>,
    pub c2h: Vec<ReadableCdev>,
}

impl Xdma {
    pub fn new(id: u32) -> Self {
        let user_cdev = OpenOptions::new()
            .read(true)
            .write(true)
            .open(format!("/dev/xdma{id}_user"));
        let user: Option<ReadWritableCdev>;
        if user_cdev.is_ok() {
            user = Some(ReadWritableCdev {
                cdev: user_cdev.unwrap(),
            });
        } else {
            user = None
        }

        let bypass_cdev = OpenOptions::new()
            .read(true)
            .write(true)
            .open(format!("/dev/xdma{id}_bypass"));
        let bypass: Option<ReadWritableCdev>;
        if bypass_cdev.is_ok() {
            bypass = Some(ReadWritableCdev {
                cdev: bypass_cdev.unwrap(),
            });
        } else {
            bypass = None
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
