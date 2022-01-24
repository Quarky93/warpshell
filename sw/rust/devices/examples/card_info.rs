extern crate warp_devices;

use itertools::Itertools;
use log::{error, info};
use warp_devices::{cms::CardMgmtOps, varium_c1100::VariumC1100};

fn main() {
    env_logger::init();

    let mut varium = VariumC1100::new().expect("cannot construct device");
    varium.init_cms().expect("cannot initialise CMS");

    // Expect to wait up to at least 1s.
    match varium.expect_ready_host_status(1000) {
        Ok(ms) => info!("CMS became ready after {}ms", ms),
        Err(e) => {
            error!("CMS is not ready: {:?}", e);
            std::process::exit(1);
        }
    }

    let info = varium.get_card_info().expect("cannot get card info");
    println!("Card info: {:?}", info);
}
