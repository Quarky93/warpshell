module top (
    output [0:0] ddr4_ch_0_act_n,
    output [16:0] ddr4_ch_0_adr,
    output [1:0] ddr4_ch_0_ba,
    output [0:0] ddr4_ch_0_bg,
    output [0:0] ddr4_ch_0_ck_c,
    output [0:0] ddr4_ch_0_ck_t,
    output [0:0] ddr4_ch_0_cke,
    output [0:0] ddr4_ch_0_cs_n,
    inout [8:0] ddr4_ch_0_dm_n,
    inout [71:0] ddr4_ch_0_dq,
    inout [8:0] ddr4_ch_0_dqs_c,
    inout [8:0] ddr4_ch_0_dqs_t,
    output [0:0] ddr4_ch_0_odt,
    output [0:0] ddr4_ch_0_reset_n,
    output [0:0] ddr4_ch_1_act_n,
    output [16:0] ddr4_ch_1_adr,
    output [1:0] ddr4_ch_1_ba,
    output [0:0] ddr4_ch_1_bg,
    output [0:0] ddr4_ch_1_ck_c,
    output [0:0] ddr4_ch_1_ck_t,
    output [0:0] ddr4_ch_1_cke,
    output [0:0] ddr4_ch_1_cs_n,
    inout [8:0] ddr4_ch_1_dm_n,
    inout [71:0] ddr4_ch_1_dq,
    inout [8:0] ddr4_ch_1_dqs_c,
    inout [8:0] ddr4_ch_1_dqs_t,
    output [0:0] ddr4_ch_1_odt,
    output [0:0] ddr4_ch_1_reset_n,
    output [0:0] ddr4_ch_2_act_n,
    output [16:0] ddr4_ch_2_adr,
    output [1:0] ddr4_ch_2_ba,
    output [0:0] ddr4_ch_2_bg,
    output [0:0] ddr4_ch_2_ck_c,
    output [0:0] ddr4_ch_2_ck_t,
    output [0:0] ddr4_ch_2_cke,
    output [0:0] ddr4_ch_2_cs_n,
    inout [8:0] ddr4_ch_2_dm_n,
    inout [71:0] ddr4_ch_2_dq,
    inout [8:0] ddr4_ch_2_dqs_c,
    inout [8:0] ddr4_ch_2_dqs_t,
    output [0:0] ddr4_ch_2_odt,
    output [0:0] ddr4_ch_2_reset_n,
    output [0:0] ddr4_ch_3_act_n,
    output [16:0] ddr4_ch_3_adr,
    output [1:0] ddr4_ch_3_ba,
    output [0:0] ddr4_ch_3_bg,
    output [0:0] ddr4_ch_3_ck_c,
    output [0:0] ddr4_ch_3_ck_t,
    output [0:0] ddr4_ch_3_cke,
    output [0:0] ddr4_ch_3_cs_n,
    inout [8:0] ddr4_ch_3_dm_n,
    inout [71:0] ddr4_ch_3_dq,
    inout [8:0] ddr4_ch_3_dqs_c,
    inout [8:0] ddr4_ch_3_dqs_t,
    output [0:0] ddr4_ch_3_odt,
    output [0:0] ddr4_ch_3_reset_n,
    input [0:0] ddr4_ref_clk_0_clk_n,
    input [0:0] ddr4_ref_clk_0_clk_p,
    input [0:0] ddr4_ref_clk_1_clk_n,
    input [0:0] ddr4_ref_clk_1_clk_p,
    input [0:0] ddr4_ref_clk_2_clk_n,
    input [0:0] ddr4_ref_clk_2_clk_p,
    input [0:0] ddr4_ref_clk_3_clk_n,
    input [0:0] ddr4_ref_clk_3_clk_p,
    input [7:0] pcie_mgt_grx_n,
    input [7:0] pcie_mgt_grx_p,
    output [7:0] pcie_mgt_gtx_n,
    output [7:0] pcie_mgt_gtx_p,
    input pcie_ref_clk_clk_n,
    input pcie_ref_clk_clk_p
);

shell shell_i (
    .ddr4_ch_0_act_n(ddr4_ch_0_act_n),
    .ddr4_ch_0_adr(ddr4_ch_0_adr),
    .ddr4_ch_0_ba(ddr4_ch_0_ba),
    .ddr4_ch_0_bg(ddr4_ch_0_bg),
    .ddr4_ch_0_ck_c(ddr4_ch_0_ck_c),
    .ddr4_ch_0_ck_t(ddr4_ch_0_ck_t),
    .ddr4_ch_0_cke(ddr4_ch_0_cke),
    .ddr4_ch_0_cs_n(ddr4_ch_0_cs_n),
    .ddr4_ch_0_dm_n(ddr4_ch_0_dm_n),
    .ddr4_ch_0_dq(ddr4_ch_0_dq),
    .ddr4_ch_0_dqs_c(ddr4_ch_0_dqs_c),
    .ddr4_ch_0_dqs_t(ddr4_ch_0_dqs_t),
    .ddr4_ch_0_odt(ddr4_ch_0_odt),
    .ddr4_ch_0_reset_n(ddr4_ch_0_reset_n),
    .ddr4_ch_1_act_n(ddr4_ch_1_act_n),
    .ddr4_ch_1_adr(ddr4_ch_1_adr),
    .ddr4_ch_1_ba(ddr4_ch_1_ba),
    .ddr4_ch_1_bg(ddr4_ch_1_bg),
    .ddr4_ch_1_ck_c(ddr4_ch_1_ck_c),
    .ddr4_ch_1_ck_t(ddr4_ch_1_ck_t),
    .ddr4_ch_1_cke(ddr4_ch_1_cke),
    .ddr4_ch_1_cs_n(ddr4_ch_1_cs_n),
    .ddr4_ch_1_dm_n(ddr4_ch_1_dm_n),
    .ddr4_ch_1_dq(ddr4_ch_1_dq),
    .ddr4_ch_1_dqs_c(ddr4_ch_1_dqs_c),
    .ddr4_ch_1_dqs_t(ddr4_ch_1_dqs_t),
    .ddr4_ch_1_odt(ddr4_ch_1_odt),
    .ddr4_ch_1_reset_n(ddr4_ch_1_reset_n),
    .ddr4_ch_2_act_n(ddr4_ch_2_act_n),
    .ddr4_ch_2_adr(ddr4_ch_2_adr),
    .ddr4_ch_2_ba(ddr4_ch_2_ba),
    .ddr4_ch_2_bg(ddr4_ch_2_bg),
    .ddr4_ch_2_ck_c(ddr4_ch_2_ck_c),
    .ddr4_ch_2_ck_t(ddr4_ch_2_ck_t),
    .ddr4_ch_2_cke(ddr4_ch_2_cke),
    .ddr4_ch_2_cs_n(ddr4_ch_2_cs_n),
    .ddr4_ch_2_dm_n(ddr4_ch_2_dm_n),
    .ddr4_ch_2_dq(ddr4_ch_2_dq),
    .ddr4_ch_2_dqs_c(ddr4_ch_2_dqs_c),
    .ddr4_ch_2_dqs_t(ddr4_ch_2_dqs_t),
    .ddr4_ch_2_odt(ddr4_ch_2_odt),
    .ddr4_ch_2_reset_n(ddr4_ch_2_reset_n),
    .ddr4_ch_3_act_n(ddr4_ch_3_act_n),
    .ddr4_ch_3_adr(ddr4_ch_3_adr),
    .ddr4_ch_3_ba(ddr4_ch_3_ba),
    .ddr4_ch_3_bg(ddr4_ch_3_bg),
    .ddr4_ch_3_ck_c(ddr4_ch_3_ck_c),
    .ddr4_ch_3_ck_t(ddr4_ch_3_ck_t),
    .ddr4_ch_3_cke(ddr4_ch_3_cke),
    .ddr4_ch_3_cs_n(ddr4_ch_3_cs_n),
    .ddr4_ch_3_dm_n(ddr4_ch_3_dm_n),
    .ddr4_ch_3_dq(ddr4_ch_3_dq),
    .ddr4_ch_3_dqs_c(ddr4_ch_3_dqs_c),
    .ddr4_ch_3_dqs_t(ddr4_ch_3_dqs_t),
    .ddr4_ch_3_odt(ddr4_ch_3_odt),
    .ddr4_ch_3_reset_n(ddr4_ch_3_reset_n),
    .ddr4_ref_clk_0_clk_n(ddr4_ref_clk_0_clk_n),
    .ddr4_ref_clk_0_clk_p(ddr4_ref_clk_0_clk_p),
    .ddr4_ref_clk_1_clk_n(ddr4_ref_clk_1_clk_n),
    .ddr4_ref_clk_1_clk_p(ddr4_ref_clk_1_clk_p),
    .ddr4_ref_clk_2_clk_n(ddr4_ref_clk_2_clk_n),
    .ddr4_ref_clk_2_clk_p(ddr4_ref_clk_2_clk_p),
    .ddr4_ref_clk_3_clk_n(ddr4_ref_clk_3_clk_n),
    .ddr4_ref_clk_3_clk_p(ddr4_ref_clk_3_clk_p),
    .pcie_mgt_grx_n(pcie_mgt_grx_n),
    .pcie_mgt_grx_p(pcie_mgt_grx_p),
    .pcie_mgt_gtx_n(pcie_mgt_gtx_n),
    .pcie_mgt_gtx_p(pcie_mgt_gtx_p),
    .pcie_ref_clk_clk_n(pcie_ref_clk_clk_n),
    .pcie_ref_clk_clk_p(pcie_ref_clk_clk_p)
);

endmodule