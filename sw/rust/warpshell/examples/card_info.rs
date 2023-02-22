extern crate warpshell;

use warpshell::{
    cores::cms::CmsOps,
    shells::{Shell, XilinxU55nXdmaStd},
};

fn main() {
    env_logger::init();

    let shell = XilinxU55nXdmaStd::new().expect("cannot construct shell");
    shell.init().expect("cannot initialise shell");

    let info = shell.cms.get_card_info().expect("cannot get card info");
    println!("Card info: {info:?}");
}
