extern crate warp_devices;

use enum_iterator::IntoEnumIterator;
use warp_devices::{
    cms::{CardMgmtSys, CmsReg},
    varium_c1100::VariumC1100,
};

fn main() {
    let mut varium = VariumC1100::new().expect("cannot construct device");
    varium.init_cms().expect("cannot initialise CMS");
    varium
        .enable_hbm_temp_monitoring()
        .expect("cannot enable HBM temp monitor");

    for reg in CmsReg::into_enum_iter() {
        println!(
            "{:?} = {}",
            reg,
            varium.get_cms_reg(reg).expect("no reading")
        );
    }
}
