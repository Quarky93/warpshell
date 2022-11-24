from shells.xilinx_u55n_xdma_gen3x8 import XILINX_U55N_XDMA_GEN3X8
import sys

dev = XILINX_U55N_XDMA_GEN3X8(0)

dev.initialize_cms()
dev.enable_hbm_temp_monitoring()
bin_file_name = sys.argv[1]
bitstream = open(bin_file_name, "rb").read()
print("Opening file: ",bin_file_name)
if dev.get_hbicap_abort_status():
    print("ICAP ERROR!")
dev.set_ctrl_firewall_block()
dev.set_dma_firewall_block()
print("Bitstream size: ", len(bitstream), " bytes")
print("Loading Configuration...")
print("Written to ICAP: ",  dev.load_persona(bitstream), " bytes")
print("ICAP Abort Status: ", dev.get_hbicap_abort_status())
dev.set_ctrl_firewall_unblock()
dev.set_dma_firewall_unblock()
print("CTRL Firewall Status: ", dev.get_ctrl_firewall_status())
print("DMA Firewall Status: ", dev.get_dma_firewall_status())
