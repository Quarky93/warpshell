use crate::xdma::XdmaDevice;
use std::fs::File;

pub struct VariumC1100 {
    pub device: XdmaDevice,
}

impl VariumC1100 {
    pub fn new() -> Result<Self, std::io::Error> {
        // For some reason `File::open` doesn't return a valid descriptor.
        let user_cdev = File::open("/dev/xdma0_user")?;
        let h2c_cdev = File::open("/dev/xdma0_h2c_0")?;
        let c2h_cdev = File::open("/dev/xdma0_c2h_0")?;
        Ok(Self {
            device: XdmaDevice {
                id: 0,
                user_cdev,
                h2c_cdev,
                c2h_cdev,
                cms_base_addr: 0,
                intc_base_addr: 0x1_0000,
                hbicap_base_addr: 0x10_0000,
            },
        })
    }
}
