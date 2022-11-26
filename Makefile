TARGET_BOARD=xilinx_u55n
TARGET_SHELL=xdma_gen3x8

# -- U55N --
xilinx_u55n_xdma_gen3x8:
	mkdir -p ./build/$(TARGET_BOARD)/$(TARGET_SHELL)/
	cd ./build/$(TARGET_BOARD)/$(TARGET_SHELL)/; \
	vivado -mode batch -source ../../../hw/shells/$(TARGET_BOARD)/$(TARGET_SHELL)/build.tcl

edit_xilinx_u55n_xdma_gen3x8:
	rm -rf ./build/edit/$(TARGET_BOARD)/$(TARGET_SHELL)/
	mkdir -p ./build/edit/$(TARGET_BOARD)/$(TARGET_SHELL)/
	cd ./build/edit/$(TARGET_BOARD)/$(TARGET_SHELL)/; \
	vivado -mode batch -source ../../../../hw/shells/$(TARGET_BOARD)/$(TARGET_SHELL)/edit.tcl

clean:
	rm -rf ./build
