import os
import struct
from time import perf_counter
from shells.xilinx_u55n_xdma_gen3x8 import XILINX_U55N_XDMA_GEN3X8

axi_sum_example_baseaddr = 0x0080_0000

def check_firewall_status(dev):
    if dev.get_ctrl_firewall_status() != 0:
        print('ctrl_firewall blocked!')
        print(dev.get_ctrl_firewall_status())
        print('panic!')
        exit()

    # Check dma_firewall status
    if dev.get_dma_firewall_status() != 0:
        print('dma_firewall blocked!')
        print('panic!')
        exit()

# Start the HLS core
def start_core(dev: XILINX_U55N_XDMA_GEN3X8):
    dev.ctrl_write(axi_sum_example_baseaddr + 0x00, (0x1).to_bytes(4, 'little'))

# Wait until the core is done
def wait_until_done(dev: XILINX_U55N_XDMA_GEN3X8):
    done = False
    while not done:
        ctrl_reg = int.from_bytes(dev.ctrl_read(axi_sum_example_baseaddr + 0x00, 4), 'little')
        done = (ctrl_reg & 0x2) == 0x2

# Set the starting address for input
def set_source_addr(dev: XILINX_U55N_XDMA_GEN3X8, source_baseaddr):
    dev.ctrl_write(axi_sum_example_baseaddr + 0x10, source_baseaddr.to_bytes(8, 'little'))

def set_sink_addr(dev: XILINX_U55N_XDMA_GEN3X8, sink_baseaddr):
    dev.ctrl_write(axi_sum_example_baseaddr + 0x1c, sink_baseaddr.to_bytes(8, 'little'))

def set_n_elements(dev: XILINX_U55N_XDMA_GEN3X8, n_elements):
    dev.ctrl_write(axi_sum_example_baseaddr + 0x28, n_elements.to_bytes(4, 'little'))

def set_n_rounds(dev: XILINX_U55N_XDMA_GEN3X8, n_rounds):
    dev.ctrl_write(axi_sum_example_baseaddr + 0x30, n_rounds.to_bytes(4, 'little'))

dev = XILINX_U55N_XDMA_GEN3X8(0)

check_firewall_status(dev)

# Test host access to HBM @ 0x0000_0000_0000_0000 [8GiB]
# Generate some data
print('--[LOOPBACK TEST]--')
payload_size = 32 * 1024 * 1024
payload = os.urandom(payload_size)
print('Writing to HBM...')
bytes_written = dev.dma_write(dev.dma_user_partition_baseaddr, payload)
print(f'Written: {bytes_written}')
loopback_data = dev.dma_read(dev.dma_user_partition_baseaddr, payload_size)
if loopback_data == payload:
    print('loopback test success!')
else:
    print('loopback test failed')
    exit()

check_firewall_status(dev)
print('--[TEST AXIL SEQUENTIAL TRANSACTIONS]--')
hello_world = bytes('Hello World', 'ascii')
dev.ctrl_write(dev.ctrl_mgmt_ram_baseaddr, hello_world)
print(dev.ctrl_read(dev.ctrl_mgmt_ram_baseaddr, len(hello_world)))

check_firewall_status(dev)

# TEST AXI SUM EXAMPLE CORE
print('--[AXI SUM EXAMPLE TEST]--')
rounds = 1000
set_source_addr(dev, 0x0000_0000_0000_0000)
# + 256MiB
set_sink_addr(dev, 0x0000_0000_1000_0000)
set_n_elements(dev, int(payload_size / 32))
set_n_rounds(dev, rounds)
t_start = perf_counter()
start_core(dev)
wait_until_done(dev)
t_end = perf_counter()
latency = t_end - t_start
print(f'{latency * 1000} ms')
print(f'{payload_size * rounds / latency / (1024 * 1024 * 1024.0)} GiB/s')
