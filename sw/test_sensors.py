from devices.varium_c1100 import VariumC1100

# Initialize first device
dev = VariumC1100(0)

# Get sensors (Cannot get current without more knowledge of board)
print("fpga temp: " + str(dev.get_fpga_temp()))
