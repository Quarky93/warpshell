module xdma_gen4_x1_minimal (
    input PCIE_REFCLK1_N,
    input PCIE_REFCLK1_P,
    input SYSCLK2_N,
    input SYSCLK2_P,
    // input SYSCLK3_N,
    // input SYSCLK3_P,
    input MSP_GPIO0,
    input MSP_GPIO1,
    input MSP_GPIO2,
    input MSP_GPIO3,
    input FPGA_RXD_MSP_65,
    output FPGA_TXD_MSP_65,
    input PCIE_PERST_LS_65,
    input PEX_RX0_N,
    input PEX_RX0_P,
    output PEX_TX0_N,
    output PEX_TX0_P
);

wire [3:0] MSP_GPIO;
assign MSP_GPIO[0] = MSP_GPIO0;
assign MSP_GPIO[1] = MSP_GPIO1;
assign MSP_GPIO[2] = MSP_GPIO2;
assign MSP_GPIO[3] = MSP_GPIO3;

shell shell_i (
    .pcie_clk_clk_n(PCIE_REFCLK1_N),
    .pcie_clk_clk_p(PCIE_REFCLK1_P),
    .pcie_mgt_rxn(PEX_RX0_N),
    .pcie_mgt_rxp(PEX_RX0_P),
    .pcie_mgt_txn(PEX_TX0_N),
    .pcie_mgt_txp(PEX_TX0_P),
    .pcie_rstn(PCIE_PERST_LS_65),
    .shell_clk_clk_n(SYSCLK2_N),
    .shell_clk_clk_p(SYSCLK2_P),
    .satellite_gpio(MSP_GPIO),
    .satellite_uart_rxd(FPGA_RXD_MSP_65),
    .satellite_uart_txd(FPGA_TXD_MSP_65)
);

endmodule
