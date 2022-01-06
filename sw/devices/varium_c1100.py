import os
import struct

class VariumC1100():
    def __init__(self, id):
        self.id = id
        self.axil = os.open('/dev/xdma' + str(id) + '_user', os.O_RDWR)
        self.h2c = os.open('/dev/xdma' + str(id) + '_h2c_' + str(id), os.O_WRONLY)
        self.c2h = os.open('/dev/xdma' + str(id) + '_c2h_' + str(id), os.O_RDONLY)
        
        # CMS Subsystem
        self.cms_baseaddr = 0x0000_0000
        # Interrupt Controller
        self.intc_baseaddr = 0x0001_0000
        # High Bandwidth ICAP
        self.hbicap_base_addr = 0x0002_0000

        self.initialize_cms()
        self.enable_hbm_temp_monitoring()

    # -- Shell Bus ------------------------------------------------------------
    def axil_read(self, addr, size):
        return os.pread(self.axil, size, addr)

    def axil_write(self, addr, data):
        return os.pwrite(self.axil, data, addr)
    # -------------------------------------------------------------------------

    # -- DMA Bus --------------------------------------------------------------
    def axi_read(self, addr, size):
        return os.pread(self.c2h, size, addr)
    
    def axi_write(self, addr, data):
        return os.pwrite(self.h2c, data, addr)
    # -------------------------------------------------------------------------

    # -- CMS ------------------------------------------------------------------
    def initialize_cms(self):
        self.axil_write(self.cms_baseaddr + 0x020000, (1).to_bytes(4, 'little'))

    def get_cms_control_reg(self):
        data = self.axil_read(self.cms_baseaddr + 0x020000 + 0x0018, 4)
        [x] = struct.unpack("I", data)
        return x
    
    def set_cms_control_reg(self, data):
        data = self.axil_write(self.cms_baseaddr + 0x020000 + 0x0018, data)

    def enable_hbm_temp_monitoring(self):
        ctrl_reg = self.get_cms_control_reg()
        self.set_cms_control_reg((ctrl_reg | 1 << 27).to_bytes(4, 'little'))

    def get_fpga_temp(self):
        data = self.axil_read(self.cms_baseaddr + 0x028000 + 0x00F8, 4)
        [temp_max] = struct.unpack("I", data)
        data = self.axil_read(self.cms_baseaddr + 0x028000 + 0x00FC, 4)
        [temp_avg] = struct.unpack("I", data)
        data = self.axil_read(self.cms_baseaddr + 0x028000 + 0x0100, 4)
        [temp_inst] = struct.unpack("I", data)
        return (temp_inst, temp_avg, temp_max)
    
    def get_hbm0_temp(self):
        # CMS calls this HBM_TEMP1
        data = self.axil_read(self.cms_baseaddr + 0x028000 + 0x0260, 4)
        [temp_max] = struct.unpack("I", data)
        data = self.axil_read(self.cms_baseaddr + 0x028000 + 0x0264, 4)
        [temp_avg] = struct.unpack("I", data)
        data = self.axil_read(self.cms_baseaddr + 0x028000 + 0x0268, 4)
        [temp_inst] = struct.unpack("I", data)
        return (temp_inst, temp_avg, temp_max)
    
    def get_hbm1_temp(self):
        # CMS calls this HBM_TEMP2
        data = self.axil_read(self.cms_baseaddr + 0x028000 + 0x02B4, 4)
        [temp_max] = struct.unpack("I", data)
        data = self.axil_read(self.cms_baseaddr + 0x028000 + 0x02B8, 4)
        [temp_avg] = struct.unpack("I", data)
        data = self.axil_read(self.cms_baseaddr + 0x028000 + 0x02BC, 4)
        [temp_inst] = struct.unpack("I", data)
        return (temp_inst, temp_avg, temp_max)
    # -------------------------------------------------------------------------
