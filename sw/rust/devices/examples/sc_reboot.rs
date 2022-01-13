extern crate warp_devices;

use warp_devices::{
    cms::{CardMgmtOps, CardMgmtSys, CmsReg},
    varium_c1100::VariumC1100,
};

fn main() {
    let mut varium = VariumC1100::new().expect("cannot construct device");
    varium.init_cms().expect("cannot initialise CMS");
    varium.sc_fw_reboot().expect("cannot reboot SC");
    println!("Successfully rebooted the Satellite Controller");
}
