from time import sleep
from devices.varium_c1100 import VariumC1100

# Initialize first device
dev = VariumC1100(0)
# Wait for initialization (probably should poll...)
sleep(1)

# Get sensors (Cannot get current without more knowledge of board)
print("fpga temp (inst, avg, max): " + str(dev.get_fpga_temp()))
print("hbm0 temp (inst, avg, max): " + str(dev.get_hbm0_temp()))
print("hbm1 temp (inst, avg, max): " + str(dev.get_hbm1_temp()))
