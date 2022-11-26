use warpshell::{shells::xilinx_u55n_xdma_std::XilinxU55nXdmaStd, modules::xdma::Xdma};

fn main() {
    println!("Hello, world!");
    let xdma = Xdma::new(0);
    let _shell = XilinxU55nXdmaStd::new(&xdma).unwrap();
}
