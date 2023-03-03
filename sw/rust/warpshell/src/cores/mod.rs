//! # Collection of IP cores
//!
//! Every core has at the minimum an operations `Ops` trait which defines operations on the
//! core. For example, [`hbicap::HbicapOps`] defines bitstream programming and read-back
//! procedures. To instantiate it, it is necessary to define a memory-mapped IO interface by
//! instantiating an `If` trait, see [`hbicap::GetHbicapIf`]. This trait is abstract in the sense it
//! does not depend on the particular transport mechanism, whether it is XDMA or QDMA. All those
//! particulars belong in the definition of a shell, see [`crate::shells::XilinxU55nXdmaStd`].
//!
//! An `If` is only required in cores which provide multiple interfaces to the host. In the case of
//! [HBICAP](`hbicap`) those are one AXI-Lite control interface and one AXI-MM DMA
//! interface. `If` traits are skipped in cores with only one interface to the host such as
//! [CMS](`cms`) and [AXI firewall](`axi_firewall`).

pub mod axi_firewall;
pub mod cms;
pub mod hbicap;
