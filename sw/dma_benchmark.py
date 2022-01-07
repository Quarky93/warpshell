import os
from time import perf_counter
from devices.varium_c1100 import VariumC1100

dev = VariumC1100(0)

hbm_base_addr = 0x0000_0000_0000_0000
size = 1 * 1024 * 1024 * 1024

print("Generate Random Payload...")
payload = os.urandom(size)

print("Writing 1GB...")
t_start = perf_counter()
dev.axi_write(hbm_base_addr, payload)
t_end = perf_counter()
time = t_end - t_start
throughput = size / time
print(str(time) + " s")
print(str(throughput / 1024 / 1024) + " MB/s")

print("Reading...")
t_start = perf_counter()
data = dev.axi_read(hbm_base_addr, size)
t_end = perf_counter()
time = t_end - t_start
throughput = size / time
print(str(time) + " s")
print(str(throughput / 1024 / 1024) + " MB/s")
if data == payload:
    print("Memory Integrity Check Passed!")
else:
    print("Memory Integrity Check Failed!")
