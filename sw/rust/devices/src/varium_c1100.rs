extern crate test;

use crate::xdma::XdmaDevice;
use std::fs::File;

pub struct VariumC1100 {
    pub device: XdmaDevice,
}

impl VariumC1100 {
    pub fn new() -> Result<Self, std::io::Error> {
        Ok(Self {
            device: XdmaDevice {
                id: 0,
                user: File::open("/dev/xdma0_user")?,
                host_to_card: File::open("/dev/xdma0_h2c_0")?,
                card_to_host: File::open("/dev/xdma0_c2h_0")?,
                cms_base_addr: 0,
                intc_base_addr: 0x1_0000,
                hbicap_base_addr: 0x10_0000,
            },
        })
    }
}

#[cfg(test)]
mod tests {
    use super::test::Bencher;
    use super::*;
    use crate::xdma::XdmaAccess;
    use rand::Rng;

    const BENCH_PAYLOAD_LEN: usize = 1 * 1024 * 1024 * 1024;
    const HBM_BASE_ADDR: u64 = 0;

    #[bench]
    fn bench_write(b: &mut Bencher) -> Result<(), std::io::Error> {
        let mut varium = VariumC1100::new()?;
        let mut payload: Vec<u8> = Vec::with_capacity(BENCH_PAYLOAD_LEN);

        for _ in 0..BENCH_PAYLOAD_LEN {
            payload.push(rand::random())
        }

        b.iter(|| {
            varium
                .device
                .dma_write(&mut payload, 0)
                .expect("write failed")
        });
        Ok(())
    }

    #[bench]
    fn bench_read(b: &mut Bencher) -> Result<(), std::io::Error> {
        let mut varium = VariumC1100::new()?;
        let mut buf: Vec<u8> = Vec::with_capacity(BENCH_PAYLOAD_LEN);

        b.iter(|| varium.device.dma_read(&mut buf, 0).expect("read failed"));
        Ok(())
    }
}
