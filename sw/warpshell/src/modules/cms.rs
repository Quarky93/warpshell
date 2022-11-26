use super::io::{ReadWritable, ReadWritableAddressSpace, Readable, Writable};

pub struct Cms<'a> {
    pub ctrl: ReadWritableAddressSpace<'a>,
}

// -- REGISTER MAP ----------------------------------------------------------------------------------------------------
// Alveo Card Management Solution Subsystem v4.0

const O_MB_RESETN_REG: u64 = 0x02_0000;
const O_HOST_INTC: u64 = 0x02_2000;
const O_REG_MAP: u64 = 0x02_8000;

const O_REG_MAP_ID: u64 = 0x0000;
const O_FW_VERSION_REG: u64 = 0x0004;
const O_STATUS_REG: u64 = 0x0008;
const O_ERROR_REG: u64 = 0x000c;
const O_PROFILE_NAME_REG: u64 = 0x0014;
const O_CONTROL_REG: u64 = 0x0018;
const O_12V_PEX_MAX_REG: u64 = 0x0020;
const O_12V_PEX_AVG_REG: u64 = 0x0024;
const O_12V_PEX_INS_REG: u64 = 0x0028;
const O_3V3_PEX_MAX_REG: u64 = 0x002c;
const O_3V3_PEX_AVG_REG: u64 = 0x0030;
const O_3V3_PEX_INS_REG: u64 = 0x0034;
const O_3V3_AUX_MAX_REG: u64 = 0x0038;
const O_3V3_AUX_AVG_REG: u64 = 0x003c;
const O_3V3_AUX_INS_REG: u64 = 0x0040;
const O_12V_AUX_MAX_REG: u64 = 0x0044;
const O_12V_AUX_AVG_REG: u64 = 0x0048;
const O_12V_AUX_INS_REG: u64 = 0x004c;
const O_DDR4_VPP_BTM_MAX_REG: u64 = 0x0050;
const O_DDR4_VPP_BTM_AVG_REG: u64 = 0x0054;
const O_DDR4_VPP_BTM_INS_REG: u64 = 0x0058;
const O_SYS_5V5_MAX_REG: u64 = 0x005c;
const O_SYS_5V5_AVG_REG: u64 = 0x0060;
const O_SYS_5V5_INS_REG: u64 = 0x0064;

const O_HOST_STATUS2_REG: u64 = 0x030c;
// --------------------------------------------------------------------------------------------------------------------

impl<'a> Cms<'a> {
    pub fn new(ctrl_channel: &'a dyn ReadWritable, ctrl_baseaddr: u64) -> Self {
        Self {
            ctrl: ReadWritableAddressSpace {
                channel: ctrl_channel,
                baseaddr: ctrl_baseaddr,
            },
        }
    }

    pub fn init(&self) {
        self.ctrl.write_u32(1, O_MB_RESETN_REG);
        let mut ready = false;
        while !ready {
            ready = (self.ctrl.read_u32(O_REG_MAP + O_HOST_STATUS2_REG) & 1) == 1;
        }
    }

    pub fn get_reg_map_id(&self) -> u32 {
        self.ctrl.read_u32(O_REG_MAP + O_REG_MAP_ID)
    }

    pub fn get_fw_version(&self) -> u32 {
        self.ctrl.read_u32(O_REG_MAP + O_FW_VERSION_REG)
    }

    pub fn get_profile_name(&self) -> u32 {
        self.ctrl.read_u32(O_REG_MAP + O_PROFILE_NAME_REG)
    }

    pub fn print_info(&self) {
        println!("REG_MAP_ID: {:#010x}", self.get_reg_map_id());
        println!("FW_VERSION: {:#010x}", self.get_fw_version());
        println!("PROFILE_NAME: {:#010x}", self.get_profile_name());
    }
}
