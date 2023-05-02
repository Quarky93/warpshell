# Supported boards and targets:
#   xilinx_u55n [xdma_gen3x8 xdma_gen4x4]
#   xilinx_u250 [xdma_gen3x8]
#   sqrl_cle215 [xdma_gen2x4]

TARGET_BOARD=xilinx_u55n
TARGET_SHELL=xdma_gen4x4

build_shell:
	mkdir -p ./build/$(TARGET_BOARD)/$(TARGET_SHELL)/
	cd ./build/$(TARGET_BOARD)/$(TARGET_SHELL)/; \
	vivado -mode batch -source ../../../hw/shells/$(TARGET_BOARD)/$(TARGET_SHELL)/build.tcl

edit_shell:
	rm -rf ./build/edit/$(TARGET_BOARD)/$(TARGET_SHELL)/
	mkdir -p ./build/edit/$(TARGET_BOARD)/$(TARGET_SHELL)/
	cd ./build/edit/$(TARGET_BOARD)/$(TARGET_SHELL)/; \
	vivado -mode batch -source ../../../../hw/shells/$(TARGET_BOARD)/$(TARGET_SHELL)/edit.tcl

clean:
	rm -rf ./build
