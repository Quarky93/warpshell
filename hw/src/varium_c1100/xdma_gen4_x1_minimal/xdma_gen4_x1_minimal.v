module xdma_gen4_x1_minimal (
    input Vp_Vn_v_n,
    input Vp_Vn_v_p,
    input PCIE_REFCLK1_N,
    input PCIE_REFCLK1_P,
    input SYSCLK2_N,
    input SYSCLK2_P,
    // input SYSCLK3_N,
    // input SYSCLK3_P,
    input PCIE_PERST_LS_65,
    input PEX_RX0_N,
    input PEX_RX0_P,
    output PEX_TX0_N,
    output PEX_TX0_P,
    output HBM_CATTRIP_LS
);

shell shell_i (
    .Vp_Vn_v_n(Vp_Vn_v_n),
    .Vp_Vn_v_p(Vp_Vn_v_p),
    .hbm_cattrip(HBM_CATTRIP_LS),
    .pcie_clk_clk_n(PCIE_REFCLK1_N),
    .pcie_clk_clk_p(PCIE_REFCLK1_P),
    .pcie_mgt_rxn(PEX_RX0_N),
    .pcie_mgt_rxp(PEX_RX0_P),
    .pcie_mgt_txn(PEX_TX0_N),
    .pcie_mgt_txp(PEX_TX0_P),
    .pcie_rstn(PCIE_PERST_LS_65),
    .shell_clk_clk_n(SYSCLK2_N),
    .shell_clk_clk_p(SYSCLK2_P)
);

endmodule
