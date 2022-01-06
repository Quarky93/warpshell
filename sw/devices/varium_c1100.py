import os
import struct

class VariumC1100():
    def __init__(self, id):
        self.id = id
        self.axil = os.open('/dev/xdma' + str(id) + '_user', os.O_RDWR)
        self.h2c = os.open('/dev/xdma' + str(id) + '_h2c_' + str(id), os.O_WRONLY)
        self.c2h = os.open('/dev/xdma' + str(id) + '_c2h_' + str(id), os.O_RDONLY)
        
        self.sys_mgmt_baseaddr = 0x0000_0000
        self.misc_status_baseaddr = 0x0001_0000
        self.hbicap_base_addr = 0x0002_0000

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

    # -- Sensors --------------------------------------------------------------
    def get_sysmgt_adc(self, offset):
        data = self.axil_read(self.sys_mgmt_baseaddr + offset, 4)
        [x] = struct.unpack('H', data[0:2])
        return x >> 6
    
    def get_sysmgt_voltage(self, offset):
        return self.get_sysmgt_adc(offset) * 3.0 / 1024.0
    
    def get_core_temp(self):
        return self.get_sysmgt_adc(0x400) * 507.6 / 1024.0 - 279.43

    def get_vccint(self):
        voltage = self.get_sysmgt_voltage(0x404)
        return (voltage, None)
    
    def get_vccaux(self):
        voltage = self.get_sysmgt_voltage(0x408)
        return (voltage, None)
    
    def get_vccbrm(self):
        voltage = self.get_sysmgt_voltage(0x418)
        return (voltage, None)
    
    def get_hbm_temp(self):
        data = self.axil_read(self.gpio_baseaddr, 4)
        [x] = struct.unpack('H', data[0:2])
        return (x >> 7, x & 0x7f)
    # -------------------------------------------------------------------------
