extern crate warp_devices;

use enum_iterator::all;
use log::{error, info};
use std::thread::sleep;
use std::time::Duration;
use warp_devices::{
    cores::{
        axi_firewall::{AxiFirewallOps, AxiFirewallReg},
        cms::{CmsOps, CmsReg},
    },
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

    shell
        .cms
        .enable_hbm_temp_monitoring()
        .expect("cannot enable HBM temp monitor");

    // Wait 1ms to allow readings to be populated.
    sleep(Duration::from_millis(100));

    println!(" ### CMS registers:");
    for reg in all::<CmsReg>() {
        println!(
            "{:?} = {}",
            reg,
            shell.cms.get_cms_reg(reg).expect("no reading")
        );
    }

    println!(" ### Control AXI firewall registers:");
    for reg in all::<AxiFirewallReg>() {
        println!(
            "{:?} = 0x{:08x}",
            reg,
            shell
                .ctrl_axi_firewall
                .get_axi_firewall_reg(reg)
                .expect("no reading")
        );
    }

    println!(" ### DMA AXI firewall registers:");
    for reg in all::<AxiFirewallReg>() {
        println!(
            "{:?} = 0x{:08x}",
            reg,
            shell
                .dma_axi_firewall
                .get_axi_firewall_reg(reg)
                .expect("no reading")
        );
    }
}
