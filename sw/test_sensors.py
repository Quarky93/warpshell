from time import sleep
from devices.varium_c1100 import VariumC1100

# Initialize first device
dev = VariumC1100(0)

# Get sensors (Cannot get current without more knowledge of board)
while True:
    print("fpga temp (inst, avg, max): " + str(dev.get_fpga_temp()))
    print("hbm0 temp (inst, avg, max): " + str(dev.get_hbm0_temp()))
    print("hbm1 temp (inst, avg, max): " + str(dev.get_hbm1_temp()))

    print("vccint voltage (inst, avg, max): " + str(dev.get_vccint_voltagte()))
    print("vccint current (inst, avg, max): " + str(dev.get_vccint_current()))
    sleep(0.5)