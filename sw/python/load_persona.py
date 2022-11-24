from shells.xilinx_u55n_xdma_gen3x8 import XILINX_U55N_XDMA_GEN3X8
import sys

plat = XILINX_U55N_XDMA_GEN3X8(0)

plat.initialize_cms()
plat.enable_hbm_temp_monitoring()
bin_file_name = sys.argv[1]
bitstream = open(bin_file_name, "rb").read()
print("Opening file: ",bin_file_name)
print("ICAP Abort Status: ", plat.get_hbicap_abort_status())
print("AXIL Firewall Status: ", plat.get_axil_firewall_status())
print("DMA Firewall Status: ", plat.get_dma_firewall_status())
print("Bitstream size: ", len(bitstream), " bytes")
print("Loading Configuration...")
print("Written to ICAP: ",  plat.load_persona(bitstream), " bytes")
print("ICAP Abort Status: ", plat.get_hbicap_abort_status())
plat.set_axil_firewall_unblock()
plat.set_dma_firewall_unblock()
plat.set_axil_firewall_disable_block()
print("AXIL Firewall Status: ", plat.get_axil_firewall_status())
print("DMA Firewall Status: ", plat.get_dma_firewall_status())
