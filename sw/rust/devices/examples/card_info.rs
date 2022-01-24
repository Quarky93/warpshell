extern crate warp_devices;

use itertools::Itertools;
use warp_devices::{cms::CardMgmtOps, varium_c1100::VariumC1100};

fn main() {
    let mut varium = VariumC1100::new().expect("cannot construct device");
    varium.init_cms().expect("cannot initialise CMS");

    // Expect to wait up to at least 1s.
    match varium.expect_ready_host_status(1000) {
        Ok(ms) => println!("CMS became ready after {}ms", ms),
        Err(e) => {
            println!("CMS is not ready: {:?}", e);
            std::process::exit(1);
        }
    }

    let info = varium.get_card_info().expect("cannot get card info");
    println!("Raw card info: {:02x}", info.iter().format(""));
}
