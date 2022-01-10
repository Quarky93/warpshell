use crate::xdma::XdmaDevice;
use std::fs::File;

pub struct VariumC1100 {
    pub device: XdmaDevice,
}

impl VariumC1100 {
    pub fn new() -> Self {
        Self {
            device: XdmaDevice {
                id: 0,
                user: "/tmp/xdma0_user".to_string(),
                host_to_card: "/tmp/xdma0_h2c_0".to_string(),
                card_to_host: "/tmp/xdma0_c2h_0".to_string(),
                cms_base_addr: 0,
                intc_base_addr: 0x1_0000,
                hbicap_base_addr: 0x10_0000,
            },
        }
    }
}
