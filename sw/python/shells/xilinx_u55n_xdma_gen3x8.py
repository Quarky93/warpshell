import os
import struct
from time import sleep
from ctypes import *

class XILINX_U55N_XDMA_GEN3X8():
    def __init__(self, id):
        self.id = id
        self.ctrl = os.open('/dev/xdma' + str(id) + '_user', os.O_RDWR | os.O_SYNC)
        self.h2c = []
        self.c2h = []
        self.h2c.append(os.open('/dev/xdma' + str(id) + '_h2c_0', os.O_WRONLY))
        self.c2h.append(os.open('/dev/xdma' + str(id) + '_c2h_0', os.O_RDONLY))

        # -- XDMA CTRL BUS --------------------------------------------------------------------------------------------
        self.ctrl_user_partition_baseaddr = 0x0000_0000
        self.ctrl_cms_baseaddr = 0x0400_0000
        self.ctrl_qspi_baseaddr = 0x0404_0000
        self.ctrl_hbicap_baseaddr = 0x0405_0000
        self.ctrl_mgmt_ram_baseaddr = 0x0406_0000
        self.ctrl_ctrl_firewall_baseaddr = 0x0407_0000
        self.ctrl_dma_firewall_baseaddr = 0x0408_0000
        self.ctrl_dfx_decoupler_baseaddr = 0x0409_0000
        # -------------------------------------------------------------------------------------------------------------

        # -- XDMA DMA BUS ---------------------------------------------------------------------------------------------
        self.dma_user_partition_baseaddr = 0x0000_0000_0000_0000
        self.dma_hbicap_baseaddr = 0x1000_0000_0000_0000
        # -------------------------------------------------------------------------------------------------------------

    # -- CTRL Bus -------------------------------------------------------------
    def ctrl_read(self, addr, size):
        return os.pread(self.ctrl, size, addr)

    def ctrl_write(self, addr, data):
        return os.pwrite(self.ctrl, data, addr)
    
    def ctrl_user_read(self, addr, size):
        return os.pread(self.ctrl, size, addr + self.ctrl_user_partition_baseaddr)

    def ctrl_user_write(self, addr, data):
        return os.pwrite(self.ctrl, data, addr + self.ctrl_user_partition_baseaddr)
    # -------------------------------------------------------------------------

    # -- DMA Bus --------------------------------------------------------------
    def dma_read(self, addr, size, channel=0):
        return os.pread(self.c2h[channel], size, addr)
    
    def dma_write(self, addr, data, channel=0):
        return os.pwrite(self.h2c[channel], data, addr)
    
    def dma_user_read(self, addr, size, channel=0):
        return os.pread(self.c2h[channel], size, addr + self.dma_user_partition_baseaddr)
    
    def dma_user_write(self, addr, data, channel=0):
        return os.pwrite(self.h2c[channel], data, addr + self.dma_user_partition_baseaddr)
    # -------------------------------------------------------------------------

    # -- CMS ------------------------------------------------------------------
    def initialize_cms(self):
        self.ctrl_write(self.ctrl_cms_baseaddr + 0x020000, (1).to_bytes(4, 'little'))
        sleep(0.2)

    def get_cms_control_reg(self):
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x0018, 4)
        [x] = struct.unpack("I", data)
        return x
    
    def set_cms_control_reg(self, data):
        data = self.ctrl_write(self.ctrl_cms_baseaddr + 0x028000 + 0x0018, data)

    def enable_hbm_temp_monitoring(self):
        ctrl_reg = self.get_cms_control_reg()
        self.set_cms_control_reg((ctrl_reg | 1 << 27).to_bytes(4, 'little'))

    def reset_sensor_data(self):
        ctrl_reg = self.get_cms_control_reg()
        self.set_cms_control_reg((ctrl_reg | 1).to_bytes(4, 'little'))

    def get_fpga_temp(self):
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x00F8, 4)
        [temp_max] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x00FC, 4)
        [temp_avg] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x0100, 4)
        [temp_inst] = struct.unpack("I", data)
        return (temp_inst, temp_avg, temp_max)
    
    def get_hbm0_temp(self):
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x0260, 4)
        [temp_max] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x0264, 4)
        [temp_avg] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x0268, 4)
        [temp_inst] = struct.unpack("I", data)
        return (temp_inst, temp_avg, temp_max)
    
    def get_hbm1_temp(self):
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x02B4, 4)
        [temp_max] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x02B8, 4)
        [temp_avg] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x02BC, 4)
        [temp_inst] = struct.unpack("I", data)
        return (temp_inst, temp_avg, temp_max)
    
    def get_vccint_voltagte(self):
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x00E0, 4)
        [voltage_max] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x00E4, 4)
        [voltage_avg] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x00E8, 4)
        [voltage_inst] = struct.unpack("I", data)
        return (voltage_inst, voltage_avg, voltage_max)
    
    def get_vccint_current(self):
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x00EC, 4)
        [current_max] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x00F0, 4)
        [current_avg] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x00F4, 4)
        [current_inst] = struct.unpack("I", data)
        return (current_inst, current_avg, current_max)
    
    def get_12v_aux_voltage(self):
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x0044, 4)
        [voltage_max] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x0048, 4)
        [voltage_avg] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x004C, 4)
        [voltage_inst] = struct.unpack("I", data)
        return (voltage_inst / 1000.0, voltage_avg / 1000.0, voltage_max / 1000.0)

    def get_12v_aux_current(self):
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x00D4, 4)
        [current_max] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x00D8, 4)
        [current_avg] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x00DC, 4)
        [current_inst] = struct.unpack("I", data)
        return (current_inst / 1000.0, current_avg / 1000.0, current_max / 1000.0)
    
    def get_12v_pex_voltage(self):
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x0020, 4)
        [voltage_max] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x0024, 4)
        [voltage_avg] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x0028, 4)
        [voltage_inst] = struct.unpack("I", data)
        return (voltage_inst / 1000.0, voltage_avg / 1000.0, voltage_max / 1000.0)

    def get_12v_pex_current(self):
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x00C8, 4)
        [current_max] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x00CC, 4)
        [current_avg] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x00D0, 4)
        [current_inst] = struct.unpack("I", data)
        return (current_inst / 1000.0, current_avg / 1000.0, current_max / 1000.0)
    
    def get_3v3_pex_voltage(self):
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x002C, 4)
        [voltage_max] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x0030, 4)
        [voltage_avg] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x0034, 4)
        [voltage_inst] = struct.unpack("I", data)
        return (voltage_inst / 1000.0, voltage_avg / 1000.0, voltage_max / 1000.0)

    def get_3v3_pex_current(self):
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x0278, 4)
        [current_max] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x027C, 4)
        [current_avg] = struct.unpack("I", data)
        data = self.ctrl_read(self.ctrl_cms_baseaddr + 0x028000 + 0x0280, 4)
        [current_inst] = struct.unpack("I", data)
        return (current_inst / 1000.0, current_avg / 1000.0, current_max / 1000.0)

    def get_aux_power(self):
        aux_v = self.get_12v_aux_voltage()
        aux_i = self.get_12v_aux_current()
        return (aux_v[0] * aux_i[0], aux_v[1] * aux_i[1], aux_v[2] * aux_i[2])
    
    def get_pex_12v_power(self):
        pex_12v_v = self.get_12v_pex_voltage()
        pex_12v_i = self.get_12v_pex_current()
        return (pex_12v_v[0] * pex_12v_i[0], pex_12v_v[1] * pex_12v_i[1], pex_12v_v[2] * pex_12v_i[2])
    
    def get_pex_3v3_power(self):
        pex_3v3_v = self.get_3v3_pex_voltage()
        pex_3v3_i = self.get_3v3_pex_current()
        return (pex_3v3_v[0] * pex_3v3_i[0], pex_3v3_v[1] * pex_3v3_i[1], pex_3v3_v[2] * pex_3v3_i[2])

    def get_power(self):
        aux_p = self.get_aux_power()
        pex_12v_p = self.get_pex_12v_power()
        pex_3v3_p = self.get_pex_3v3_power()
        return (
            (aux_p[0] + pex_12v_p[0] + pex_3v3_p[0]),
            (aux_p[1] + pex_12v_p[1] + pex_3v3_p[1]),
            (aux_p[2] + pex_12v_p[2] + pex_3v3_p[2])
        )
    # -------------------------------------------------------------------------

    # -- DFX Decoupler --------------------------------------------------------
    # Decouple DFX region
    def set_dfx_decoupling(self, decouple):
        if decouple:
            self.ctrl_write(self.ctrl_dfx_decoupler_baseaddr + 0x0, (0x1).to_bytes(4, 'little'))
        else:
            self.ctrl_write(self.ctrl_dfx_decoupler_baseaddr + 0x0, (0x0).to_bytes(4, 'little'))
    
    def get_dfx_decoupling(self):
        data = self.ctrl_read(self.ctrl_dfx_decoupler_baseaddr + 0x0, 4)
        [status] = struct.unpack("I", data)
        return (status & 1) == 1
    # -------------------------------------------------------------------------

    # -- DMA Firewall ---------------------------------------------------------
    def get_dma_firewall_status(self):
        data = self.ctrl_read(self.ctrl_dma_firewall_baseaddr + 0x0, 4)
        [status] = struct.unpack("I", data)
        return status
    
    def set_dma_firewall_block(self):
        self.ctrl_write(self.ctrl_dma_firewall_baseaddr + 0x4, (0x100_0100).to_bytes(4, 'little'))

    def set_dma_firewall_unblock(self):
        self.ctrl_write(self.ctrl_dma_firewall_baseaddr + 0x4, (0x0).to_bytes(4, 'little'))
        self.ctrl_write(self.ctrl_dma_firewall_baseaddr + 0x8, (0x1).to_bytes(4, 'little'))
    # -------------------------------------------------------------------------

    # -- CTRL Firewall --------------------------------------------------------
    def get_ctrl_firewall_status(self):
        data = self.ctrl_read(self.ctrl_ctrl_firewall_baseaddr + 0x0, 4)
        [status] = struct.unpack("I", data)
        return status
    
    def get_ctrl_firewall_si_status(self):
        data = self.ctrl_read(self.ctrl_ctrl_firewall_baseaddr + 0x100, 4)
        [status] = struct.unpack("I", data)
        return status
    
    def set_ctrl_firewall_block(self):
        self.ctrl_write(self.ctrl_ctrl_firewall_baseaddr + 0x4, (0x100_0100).to_bytes(4, 'little'))
    
    def set_ctrl_firewall_unblock(self):
        self.ctrl_write(self.ctrl_ctrl_firewall_baseaddr + 0x4, (0x0).to_bytes(4, 'little'))
        self.ctrl_write(self.ctrl_ctrl_firewall_baseaddr + 0x8, (0x1).to_bytes(4, 'little'))
    
    def set_ctrl_firewall_disable_block(self):
        self.ctrl_write(self.ctrl_ctrl_firewall_baseaddr + 0x204, (0x0).to_bytes(4, 'little'))
    # -------------------------------------------------------------------------

    # -- User Partition Reset -------------------------------------------------
    # BUGGY DO NOT USE
    # def user_partition_reset(self):
    #     self.set_ctrl_firewall_block()
    #     self.set_dma_firewall_block()
    #     self.set_dfx_decoupling(True)
    #     self.set_dfx_decoupling(False)
    #     self.set_ctrl_firewall_unblock()
    #     self.set_dma_firewall_unblock()
    # -------------------------------------------------------------------------

    # -- HBICAP ---------------------------------------------------------------
    # Get the HBICAP status register
    def get_hbicap_status(self):
        data = self.ctrl_read(self.ctrl_hbicap_baseaddr + 0x110, 4)
        [status] = struct.unpack("I", data)
        return status

    # Check if HBICAP is ready (end-of-startup and idle)
    def get_hbicap_ready(self):
        status = self.get_hbicap_status()
        return status == 5
    
    def hbicap_reset(self):
        self.ctrl_write(self.ctrl_hbicap_baseaddr + 0x10C, (0xC).to_bytes(4, 'little'))

    def set_hbicap_transfer_size(self, size):
        self.ctrl_write(self.ctrl_hbicap_baseaddr + 0x108, size.to_bytes(4, 'little'))

    def get_hbicap_abort_status(self):
        data = self.ctrl_read(self.ctrl_hbicap_baseaddr + 0x118, 4)
        [status] = struct.unpack("I", data)
        return status

    # Write a partial bitstream
    def __write_partial_bitstream(self, data, channel = 0):
        return self.dma_write(self.dma_hbicap_baseaddr, data, channel)
    # -------------------------------------------------------------------------

    # -- DFX ------------------------------------------------------------------
    # Load DFX configuration
    def load_persona(self, bitstream, channel = 0):
        if not self.get_hbicap_ready():
            return -1
        self.set_dfx_decoupling(True)
        self.hbicap_reset()
        self.set_hbicap_transfer_size(int(len(bitstream)/4))
        bytes_written = self.__write_partial_bitstream(bitstream, channel)
        while not self.get_hbicap_ready():
            sleep(0.01)
        self.set_dfx_decoupling(False)
        return bytes_written
    # -------------------------------------------------------------------------
