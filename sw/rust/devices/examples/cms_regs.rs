extern crate warp_devices;

use enum_iterator::IntoEnumIterator;
use std::thread::sleep;
use std::time::Duration;
use warp_devices::{
    cms::{CardMgmtOps, CardMgmtSys, CmsReg},
    varium_c1100::VariumC1100,
};

fn main() {
    let mut varium = VariumC1100::new().expect("cannot construct device");
    varium.init_cms().expect("cannot initialise CMS");

    // Wait while the micro starts.
    sleep(Duration::from_millis(100));

    varium
        .enable_hbm_temp_monitoring()
        .expect("cannot enable HBM temp monitor");

    // Wait max 100µs to allow readings to be populated while polling the status register every 1µs.
    match varium.expect_ready_host_status(100) {
        Ok(us) => println!("CMS became ready in {}µs", us),
        Err(e) => {
            println!("CMS is not ready: {:?}", e);
            std::process::exit(1);
        }
    }

    for reg in CmsReg::into_enum_iter() {
        // println!("reading 0x{:x}", reg as u64);

        println!(
            "{:?} = {}",
            reg,
            varium.get_cms_reg(reg).expect("no reading")
        );
    }
}
