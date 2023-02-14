extern crate warp_devices;

use log::{error, info};
use warp_devices::{
    cores::cms::CmsOps,
    shells::{Shell, XilinxU55nXdmaStd},
};

fn main() {
    env_logger::init();

    let shell = XilinxU55nXdmaStd::new().expect("cannot construct shell");
    shell.init().expect("cannot initialise shell");

    // Expect to wait up to at least 1s.
    match shell.cms.expect_ready_host_status(1000) {
        Ok(ms) => info!("CMS became ready after {}ms", ms),
        Err(e) => {
            error!("CMS is not ready: {:?}", e);
            std::process::exit(1);
        }
    }

    let info = shell.cms.get_card_info().expect("cannot get card info");
    println!("Card info: {:?}", info);
}
