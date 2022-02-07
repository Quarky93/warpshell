extern crate warp_devices;

use warp_devices::{dev_core::DevCoreOps, varium_c1100::VariumC1100};

fn main() {
    let mut varium = VariumC1100::new().expect("cannot construct device");

    let x = 8;
    let result = varium.compute(x).expect("cannot compute result");
    println!("{}^2 = {}", x, result);
}
