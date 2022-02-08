extern crate warp_devices;

use warp_devices::{dev_core::DevCoreOps, varium_c1100::VariumC1100};

fn main() {
    env_logger::init();

    let mut varium = VariumC1100::new().expect("cannot construct device");

    let x: u8 = rand::random();
    let result = varium.compute(x as u32).expect("cannot compute result");
    println!("0x{:X}^2 = 0x{:X}", x, result);
    assert_eq!(result, x as u32 * x as u32);
}
