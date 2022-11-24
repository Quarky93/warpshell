from shells.xilinx_u55n_xdma_gen3x8 import XILINX_U55N_XDMA_GEN3X8

dev = XILINX_U55N_XDMA_GEN3X8(0)

print('Reseting user partition...')
dev.user_partition_reset()

# Check ctrl_firewall status
if dev.get_ctrl_firewall_status() == 0:
    print('ctrl_firewall status normal')
else:
    print('ctrl_firewall blocked!')
    print(dev.get_ctrl_firewall_status())
    print('panic!')
    exit()

# Check dma_firewall status
if dev.get_dma_firewall_status() == 0:
    print('dma_firewall status normal')
else:
    print('dma_firewall blocked!')
    print('panic!')
    exit()
