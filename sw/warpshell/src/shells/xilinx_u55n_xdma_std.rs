use crate::modules::{xdma::Xdma, axi_firewall::AxiFirewall, io::ReadWritableCdev};

pub struct XilinxU55nXdmaStd<'a> {
    pub xdma: Box<Xdma>,
    pub ctrl_firewall: Box<AxiFirewall<'a>>
}

const CTRL_FIREWALL_BASEADDR: u64 = 0x0040_0000;

impl<'a> XilinxU55nXdmaStd<'a> {
    pub fn new(id: u32) -> Self {
        let xdma = Box::new(Xdma::new(id));
        let ctrl_firewall = Box::new(
            AxiFirewall::new(CTRL_FIREWALL_BASEADDR, xdma.user.as_ref())
        );
        Self {
            xdma,
            ctrl_firewall
        }
    }
}
