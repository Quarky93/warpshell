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
    xdma::{CtrlOps, GetCtrlChannel},
};

fn main() {
    env_logger::init();

    let shell = XilinxU55nXdmaStd::new().expect("cannot construct shell");
    shell.init().expect("cannot initialise shell");

    // Wait 1ms to allow readings to be populated.
    sleep(Duration::from_millis(100));

    println!(" ### BRAM test");
    {
        const BRAM_BASE_ADDR: u64 = 0x0080_1000;
        let ctrl_chan = shell.cms.get_ctrl_channel();
        let test_str: &[u8] = b"Warpshell ROCKXX";
        ctrl_chan
            .ctrl_write(test_str, BRAM_BASE_ADDR)
            .expect("cannot write to BRAM");
        let mut read_back_buf: [u8; 16] = [0; 16];
        ctrl_chan
            .ctrl_read(&mut read_back_buf, BRAM_BASE_ADDR)
            .expect("cannot read BRAM");
        assert_eq!(test_str, read_back_buf);
        println!("Successfully tested BRAM");
    }

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
        .poll_done_every_10ms(Duration::from_secs(10))
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
