extern crate warp_devices;

use enum_iterator::all;
use log::info;
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

    // Wait 1ms to allow readings to be populated.
    sleep(Duration::from_millis(100));

    info!(" ### CMS registers:");
    for reg in all::<CmsReg>() {
        info!(
            "{:?} = {}",
            reg,
            shell.cms.get_cms_reg(reg).expect("no reading")
        );
    }

    info!(" ### Control AXI firewall registers:");
    for reg in all::<AxiFirewallReg>() {
        info!(
            "{:?} = 0x{:08x}",
            reg,
            shell
                .ctrl_axi_firewall
                .get_axi_firewall_reg(reg)
                .expect("no reading")
        );
    }

    info!(" ### DMA AXI firewall registers:");
    for reg in all::<AxiFirewallReg>() {
        info!(
            "{:?} = 0x{:08x}",
            reg,
            shell
                .dma_axi_firewall
                .get_axi_firewall_reg(reg)
                .expect("no reading")
        );
    }
}
