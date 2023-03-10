extern crate warpshell;

use enum_iterator::all;
use std::thread::sleep;
use std::time::Duration;
use warpshell::{
    cores::{
        axi_firewall::{AxiFirewallOps, AxiFirewallReg},
        cms::{CmsOps, CmsReg},
        hbicap::{ConfigLogicReg, HbicapOps, HbicapReg},
    },
    shells::{Shell, XilinxU55nXdmaStd},
};

fn main() {
    env_logger::init();

    let shell = XilinxU55nXdmaStd::new().expect("cannot construct shell");
    shell.init().expect("cannot initialise shell");

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

    println!(" ### HBICAP registers:");
    for reg in all::<HbicapReg>() {
        println!(
            "{:?} = 0x{:08x}",
            reg,
            shell.hbicap.get_hbicap_reg(reg).expect("no reading")
        );
    }

    println!(" ### FPGA config logic registers:");
    shell.hbicap.abort().expect("cannot perform HBICAP abort");
    shell
        .hbicap
        .poll_done_every_10ms()
        .expect("HBICAP not ready");
    for reg in all::<ConfigLogicReg>() {
        println!(
            "{:?} = 0x{:08x}",
            reg,
            shell
                .hbicap
                .config_logic_reg_readback(reg)
                .expect("no reading")
        );
    }
}
