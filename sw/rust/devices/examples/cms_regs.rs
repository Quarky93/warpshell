extern crate warp_devices;

use enum_iterator::all;
use log::{error, info};
use std::thread::sleep;
use std::time::Duration;
use warp_devices::{
    cms::{CardMgmtOps, CardMgmtSys, CmsReg},
    varium_c1100::VariumC1100,
};

fn main() {
    env_logger::init();

    let varium = VariumC1100::new().expect("cannot construct device");
    varium.init_cms().expect("cannot initialise CMS");

    // sleep(Duration::from_millis(100));

    // Expect to wait up to at least 1s.
    match varium.expect_ready_host_status(1000) {
        Ok(ms) => info!("CMS became ready after {}ms", ms),
        Err(e) => {
            error!("CMS is not ready: {:?}", e);
            std::process::exit(1);
        }
    }

    varium
        .enable_hbm_temp_monitoring()
        .expect("cannot enable HBM temp monitor");

    // Wait 1ms to allow readings to be populated.
    sleep(Duration::from_millis(100));

    for reg in all::<CmsReg>() {
        println!(
            "{:?} = {}",
            reg,
            varium.get_cms_reg(reg).expect("no reading")
        );
    }
}
