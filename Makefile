xilinx_u55n_xdma_gen3x8: ./hw/shells/xilinx_u55n/xdma_gen3x8/*
	mkdir -p ./build/xilinx_u55n_xdma_gen3x8/
	cd ./build/xilinx_u55n_xdma_gen3x8/; \
	vivado -mode batch -source ../../hw/shells/xilinx_u55n/xdma_gen3x8/build.tcl -tclargs gen3 8

edit_xilinx_u55n_xdma_gen3x8:
	mkdir -p ./build/edit_xilinx_u55n_xdma_gen3x8/
	cd ./build/edit_xilinx_u55n_xdma_gen3x8/; \
	vivado -mode batch -source ../../scripts/edit_bd.tcl -tclargs xcu55n-fsvh2892-2L-e shell ../../hw/shells/xilinx_u55n/xdma_gen3x8/shell.tcl

clean:
	rm -rf ./build
