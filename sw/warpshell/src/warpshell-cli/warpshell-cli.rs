use warpshell::{shells::xilinx_u55n_xdma_std::XilinxU55nXdmaStd, modules::xdma::Xdma};

fn main() {
    println!("Detecting XDMA...");
    let xdma = Xdma::new(0);
    println!("Initializing Warpshell...");
    let shell = XilinxU55nXdmaStd::new(&xdma).unwrap();
    shell.init();
    println!("--[CMS]----------------------------");
    shell.cms.print_info();
    println!("--[CTRL_FIREWALL]------------------");
    shell.dma_firewall.print_status();
    println!("--[DMA_FIREWALL]-------------------");
    shell.dma_firewall.print_status();
}
