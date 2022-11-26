use super::io::ReadWritable;

pub struct AxiFirewall<'a> {
    pub ctrl_baseaddr: u64,
    pub ctrl_channel: &'a dyn ReadWritable
}

const MI_SIDE_FAULT_STATUS_REGISTER_OFFSET: u64 = 0x0;
const MI_SIDE_SOFT_FAULT_CONTROL_REGISTER_OFFSET: u64 = 0x4;
const MI_SIDE_UNBLOCK_CONTROL_REGISTER_OFFSET: u64 = 0x8;
const IP_VERSION_REGISTER_OFFSET: u64 = 0x10;
// const SOFT_PAUSE_REGISTER_OFFSET: u64 = 0x14;

impl<'a> AxiFirewall<'a> {
    pub fn get_ip_version(&self) -> u32 {
        self.ctrl_channel.read_u32(self.ctrl_baseaddr + IP_VERSION_REGISTER_OFFSET).unwrap()
    }

    pub fn get_mi_side_fault_status(&self) -> u32 {
        self.ctrl_channel.read_u32(self.ctrl_baseaddr + MI_SIDE_FAULT_STATUS_REGISTER_OFFSET).unwrap()
    }

    pub fn block(&self) {
        self.ctrl_channel.write_u32(0x0100_0100, self.ctrl_baseaddr + MI_SIDE_SOFT_FAULT_CONTROL_REGISTER_OFFSET).unwrap();
    }

    pub fn unblock(&self) {
        self.ctrl_channel.write_u32(0x0, self.ctrl_baseaddr + MI_SIDE_SOFT_FAULT_CONTROL_REGISTER_OFFSET).unwrap();
        self.ctrl_channel.write_u32(0x1, self.ctrl_baseaddr + MI_SIDE_UNBLOCK_CONTROL_REGISTER_OFFSET).unwrap();
    }
}
