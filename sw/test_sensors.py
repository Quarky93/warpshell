from devices.varium_c1100 import VariumC1100

# Initialize first device
dev = VariumC1100(0)

print(dev.get_register_map_id())
# Get sensors (Cannot get current without more knowledge of board)
print("fpga temp: " + str(dev.get_fpga_temp()))
