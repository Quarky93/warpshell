xilinx_u55n_xdma_gen3x8: ./hw/shells/xilinx_u55n/xdma_gen3x8/*
	mkdir -p ./build/xilinx_u55n_xdma_gen3x8/
	cd ./build/xilinx_u55n_xdma_gen3x8/; \
	vivado -mode batch -source ../../hw/shells/xilinx_u55n/xdma_gen3x8/build.tcl

edit_xilinx_u55n_xdma_gen3x8_shell:
	mkdir -p ./build/edit_xilinx_u55n_xdma_gen3x8/
	cd ./build/edit_xilinx_u55n_xdma_gen3x8/; \
	vivado -mode batch -source ../../hw/shells/xilinx_u55n/xdma_gen3x8/edit.tcl -tclargs shell

edit_xilinx_u55n_xdma_gen3x8_user:
	mkdir -p ./build/edit_xilinx_u55n_xdma_gen3x8/
	cd ./build/edit_xilinx_u55n_xdma_gen3x8/; \
	vivado -mode batch -source ../../hw/shells/xilinx_u55n/xdma_gen3x8/edit.tcl -tclargs user

clean:
	rm -rf ./build
