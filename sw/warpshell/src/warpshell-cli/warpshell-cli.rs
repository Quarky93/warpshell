use clap::Parser;
use warpshell::{shells::xilinx_u55n_xdma_std::XilinxU55nXdmaStd, modules::xdma::Xdma};

#[derive(Parser,Default,Debug)]
struct Args {
    command: String
}

fn main() {
    let args = Args::parse();
    match args.command.as_str() {
        "load-user-image" => println!("LOAD USER IMAGE"),
        "get-fpga-temp" => println!("FPGA TEMP"),
        "get-hbm-temp" => println!("HBM TEMP"),
        "get-board-power" => println!("BOARD POWER"),
        _ => println!("Invalid Command")
    }
    
    // println!("Detecting XDMA...");
    // let xdma = Xdma::new(0);
    // println!("Initializing Warpshell...");
    // let shell = XilinxU55nXdmaStd::new(&xdma).unwrap();
    // shell.init();
    // println!("--[CMS]----------------------------");
    // shell.cms.print_info();
    // println!("--[CTRL_FIREWALL]------------------");
    // shell.dma_firewall.print_status();
    // println!("--[DMA_FIREWALL]-------------------");
    // shell.dma_firewall.print_status();
}
