use super::io::{ReadWritable, ReadWritableAddressSpace, Readable, Writable};

pub struct AxiFirewall<'a> {
    pub ctrl: ReadWritableAddressSpace<'a>,
}

// -- REGISTER MAP ----------------------------------------------------------------------------------------------------
const MI_SIDE_FAULT_STATUS_REGISTER_OFFSET: u64 = 0x0;
const MI_SIDE_SOFT_FAULT_CONTROL_REGISTER_OFFSET: u64 = 0x4;
const MI_SIDE_UNBLOCK_CONTROL_REGISTER_OFFSET: u64 = 0x8;
const IP_VERSION_REGISTER_OFFSET: u64 = 0x10;
// const SOFT_PAUSE_REGISTER_OFFSET: u64 = 0x14;
// --------------------------------------------------------------------------------------------------------------------

impl<'a> AxiFirewall<'a> {
    pub fn new(ctrl_channel: &'a dyn ReadWritable, ctrl_baseaddr: u64) -> Self {
        Self {
            ctrl: ReadWritableAddressSpace {
                channel: ctrl_channel,
                baseaddr: ctrl_baseaddr,
            },
        }
    }
    // -- MI OPS ------------------------------------------------------------------------------------------------------
    pub fn get_mi_fault_status(&self) -> u32 {
        self.ctrl.read_u32(MI_SIDE_FAULT_STATUS_REGISTER_OFFSET)
    }

    pub fn mi_is_blocked(&self) -> bool {
        self.get_mi_fault_status() != 0
    }

    pub fn block_mi(&self) {
        self.ctrl
            .write_u32(0x0100_0100, MI_SIDE_SOFT_FAULT_CONTROL_REGISTER_OFFSET);
    }

    pub fn unblock_mi(&self) {
        self.ctrl
            .write_u32(0x0, MI_SIDE_SOFT_FAULT_CONTROL_REGISTER_OFFSET);
        self.ctrl
            .write_u32(0x1, MI_SIDE_UNBLOCK_CONTROL_REGISTER_OFFSET);
    }
    // ----------------------------------------------------------------------------------------------------------------

    pub fn get_ip_version(&self) -> u32 {
        self.ctrl.read_u32(IP_VERSION_REGISTER_OFFSET)
    }

    pub fn print_status(&self) {
        println!("VERSION: {:?}", self.get_ip_version());
        let status = self.get_mi_fault_status();
        let mi_is_blocked = status != 0;
        println!("MI_IS_BLOCKED: {:?}", mi_is_blocked);
        if mi_is_blocked {
            println!("MI_STATUS: {:?}", status);
        }
    }
}
