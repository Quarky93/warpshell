module top (
    // -- PCIE --------------------------------------------------------------------------------------------------------
    input pcie_refclk_clk_n,
    input pcie_refclk_clk_p,
    input pcie_rstn,
    input [7:0] pcie_mgt_rxn,
    input [7:0] pcie_mgt_rxp,
    output [7:0] pcie_mgt_txn,
    output [7:0] pcie_mgt_txp,
    // ----------------------------------------------------------------------------------------------------------------
    // -- SATELLITE CONTROLLER ----------------------------------------------------------------------------------------
    input [3:0] satellite_gpio,
    input satellite_uart_rxd,
    output satellite_uart_txd
    // ----------------------------------------------------------------------------------------------------------------
);
wire shell_axi_clk;
wire [63:0]shell_axi_dma_araddr;
wire [1:0]shell_axi_dma_arburst;
wire [3:0]shell_axi_dma_arcache;
wire [7:0]shell_axi_dma_arlen;
wire [0:0]shell_axi_dma_arlock;
wire [2:0]shell_axi_dma_arprot;
wire [3:0]shell_axi_dma_arqos;
wire shell_axi_dma_arready;
wire [2:0]shell_axi_dma_arsize;
wire shell_axi_dma_arvalid;
wire [63:0]shell_axi_dma_awaddr;
wire [1:0]shell_axi_dma_awburst;
wire [3:0]shell_axi_dma_awcache;
wire [7:0]shell_axi_dma_awlen;
wire [0:0]shell_axi_dma_awlock;
wire [2:0]shell_axi_dma_awprot;
wire [3:0]shell_axi_dma_awqos;
wire shell_axi_dma_awready;
wire [2:0]shell_axi_dma_awsize;
wire shell_axi_dma_awvalid;
wire shell_axi_dma_bready;
wire [1:0]shell_axi_dma_bresp;
wire shell_axi_dma_bvalid;
wire [255:0]shell_axi_dma_rdata;
wire shell_axi_dma_rlast;
wire shell_axi_dma_rready;
wire [1:0]shell_axi_dma_rresp;
wire shell_axi_dma_rvalid;
wire [255:0]shell_axi_dma_wdata;
wire shell_axi_dma_wlast;
wire shell_axi_dma_wready;
wire [31:0]shell_axi_dma_wstrb;
wire shell_axi_dma_wvalid;
wire [31:0]shell_axil_ctrl_araddr;
wire [2:0]shell_axil_ctrl_arprot;
wire shell_axil_ctrl_arready;
wire shell_axil_ctrl_arvalid;
wire [31:0]shell_axil_ctrl_awaddr;
wire [2:0]shell_axil_ctrl_awprot;
wire shell_axil_ctrl_awready;
wire shell_axil_ctrl_awvalid;
wire shell_axil_ctrl_bready;
wire [1:0]shell_axil_ctrl_bresp;
wire shell_axil_ctrl_bvalid;
wire [31:0]shell_axil_ctrl_rdata;
wire shell_axil_ctrl_rready;
wire [1:0]shell_axil_ctrl_rresp;
wire shell_axil_ctrl_rvalid;
wire [31:0]shell_axil_ctrl_wdata;
wire shell_axil_ctrl_wready;
wire [3:0]shell_axil_ctrl_wstrb;
wire shell_axil_ctrl_wvalid;
wire [0:0]shell_rstn;

wire bscan_bscanid_en;
wire bscan_capture;
wire bscan_drck;
wire bscan_reset;
wire bscan_runtest;
wire bscan_sel;
wire bscan_shift;
wire bscan_tck;
wire bscan_tdi;
wire bscan_tdo;
wire bscan_tms;
wire bscan_update;

user user_partition (
    // -- BSCAN --
    .bscan_bscanid_en(bscan_bscanid_en),
    .bscan_capture(bscan_capture),
    .bscan_drck(bscan_drck),
    .bscan_reset(bscan_reset),
    .bscan_runtest(bscan_runtest),
    .bscan_sel(bscan_sel),
    .bscan_shift(bscan_shift),
    .bscan_tck(bscan_tck),
    .bscan_tdi(bscan_tdi),
    .bscan_tdo(bscan_tdo),
    .bscan_tms(bscan_tms),
    .bscan_update(bscan_update),
    // -- SHELL <> USER --
    .shell_axi_clk(shell_axi_clk),
    .shell_rstn(shell_rstn),
    // -- SHELL AXIL CTRL --
    .shell_axil_ctrl_araddr(shell_axil_ctrl_araddr),
    .shell_axil_ctrl_arprot(shell_axil_ctrl_arprot),
    .shell_axil_ctrl_arready(shell_axil_ctrl_arready),
    .shell_axil_ctrl_arvalid(shell_axil_ctrl_arvalid),
    .shell_axil_ctrl_awaddr(shell_axil_ctrl_awaddr),
    .shell_axil_ctrl_awprot(shell_axil_ctrl_awprot),
    .shell_axil_ctrl_awready(shell_axil_ctrl_awready),
    .shell_axil_ctrl_awvalid(shell_axil_ctrl_awvalid),
    .shell_axil_ctrl_bready(shell_axil_ctrl_bready),
    .shell_axil_ctrl_bresp(shell_axil_ctrl_bresp),
    .shell_axil_ctrl_bvalid(shell_axil_ctrl_bvalid),
    .shell_axil_ctrl_rdata(shell_axil_ctrl_rdata),
    .shell_axil_ctrl_rready(shell_axil_ctrl_rready),
    .shell_axil_ctrl_rresp(shell_axil_ctrl_rresp),
    .shell_axil_ctrl_rvalid(shell_axil_ctrl_rvalid),
    .shell_axil_ctrl_wdata(shell_axil_ctrl_wdata),
    .shell_axil_ctrl_wready(shell_axil_ctrl_wready),
    .shell_axil_ctrl_wstrb(shell_axil_ctrl_wstrb),
    .shell_axil_ctrl_wvalid(shell_axil_ctrl_wvalid),
    // -- SHELL AXI DMA --
    .shell_axi_dma_araddr(shell_axi_dma_araddr),
    .shell_axi_dma_arburst(shell_axi_dma_arburst),
    .shell_axi_dma_arcache(shell_axi_dma_arcache),
    .shell_axi_dma_arlen(shell_axi_dma_arlen),
    .shell_axi_dma_arlock(shell_axi_dma_arlock),
    .shell_axi_dma_arprot(shell_axi_dma_arprot),
    .shell_axi_dma_arqos(shell_axi_dma_arqos),
    .shell_axi_dma_arready(shell_axi_dma_arready),
    .shell_axi_dma_arsize(shell_axi_dma_arsize),
    .shell_axi_dma_arvalid(shell_axi_dma_arvalid),
    .shell_axi_dma_awaddr(shell_axi_dma_awaddr),
    .shell_axi_dma_awburst(shell_axi_dma_awburst),
    .shell_axi_dma_awcache(shell_axi_dma_awcache),
    .shell_axi_dma_awlen(shell_axi_dma_awlen),
    .shell_axi_dma_awlock(shell_axi_dma_awlock),
    .shell_axi_dma_awprot(shell_axi_dma_awprot),
    .shell_axi_dma_awqos(shell_axi_dma_awqos),
    .shell_axi_dma_awready(shell_axi_dma_awready),
    .shell_axi_dma_awsize(shell_axi_dma_awsize),
    .shell_axi_dma_awvalid(shell_axi_dma_awvalid),
    .shell_axi_dma_bready(shell_axi_dma_bready),
    .shell_axi_dma_bresp(shell_axi_dma_bresp),
    .shell_axi_dma_bvalid(shell_axi_dma_bvalid),
    .shell_axi_dma_rdata(shell_axi_dma_rdata),
    .shell_axi_dma_rlast(shell_axi_dma_rlast),
    .shell_axi_dma_rready(shell_axi_dma_rready),
    .shell_axi_dma_rresp(shell_axi_dma_rresp),
    .shell_axi_dma_rvalid(shell_axi_dma_rvalid),
    .shell_axi_dma_wdata(shell_axi_dma_wdata),
    .shell_axi_dma_wlast(shell_axi_dma_wlast),
    .shell_axi_dma_wready(shell_axi_dma_wready),
    .shell_axi_dma_wstrb(shell_axi_dma_wstrb),
    .shell_axi_dma_wvalid(shell_axi_dma_wvalid)
);

shell shell_partition (
    // -- BSCAN --
    .bscan_bscanid_en(bscan_bscanid_en),
    .bscan_capture(bscan_capture),
    .bscan_drck(bscan_drck),
    .bscan_reset(bscan_reset),
    .bscan_runtest(bscan_runtest),
    .bscan_sel(bscan_sel),
    .bscan_shift(bscan_shift),
    .bscan_tck(bscan_tck),
    .bscan_tdi(bscan_tdi),
    .bscan_tdo(bscan_tdo),
    .bscan_tms(bscan_tms),
    .bscan_update(bscan_update),
    // -- PCIE --
    .pcie_refclk_clk_n(pcie_refclk_clk_n),
    .pcie_refclk_clk_p(pcie_refclk_clk_p),
    .pcie_rstn(pcie_rstn),
    .pcie_mgt_rxn(pcie_mgt_rxn),
    .pcie_mgt_rxp(pcie_mgt_rxp),
    .pcie_mgt_txn(pcie_mgt_txn),
    .pcie_mgt_txp(pcie_mgt_txp),
    // -- SATELLITE CONTROLLER --
    .satellite_gpio(satellite_gpio),
    .satellite_uart_rxd(satellite_uart_rxd),
    .satellite_uart_txd(satellite_uart_txd),
    // -- SHELL <> USER --
    .shell_axi_clk(shell_axi_clk),
    .shell_rstn(shell_rstn),
    // -- SHELL AXIL CTRL --
    .shell_axil_ctrl_araddr(shell_axil_ctrl_araddr),
    .shell_axil_ctrl_arprot(shell_axil_ctrl_arprot),
    .shell_axil_ctrl_arready(shell_axil_ctrl_arready),
    .shell_axil_ctrl_arvalid(shell_axil_ctrl_arvalid),
    .shell_axil_ctrl_awaddr(shell_axil_ctrl_awaddr),
    .shell_axil_ctrl_awprot(shell_axil_ctrl_awprot),
    .shell_axil_ctrl_awready(shell_axil_ctrl_awready),
    .shell_axil_ctrl_awvalid(shell_axil_ctrl_awvalid),
    .shell_axil_ctrl_bready(shell_axil_ctrl_bready),
    .shell_axil_ctrl_bresp(shell_axil_ctrl_bresp),
    .shell_axil_ctrl_bvalid(shell_axil_ctrl_bvalid),
    .shell_axil_ctrl_rdata(shell_axil_ctrl_rdata),
    .shell_axil_ctrl_rready(shell_axil_ctrl_rready),
    .shell_axil_ctrl_rresp(shell_axil_ctrl_rresp),
    .shell_axil_ctrl_rvalid(shell_axil_ctrl_rvalid),
    .shell_axil_ctrl_wdata(shell_axil_ctrl_wdata),
    .shell_axil_ctrl_wready(shell_axil_ctrl_wready),
    .shell_axil_ctrl_wstrb(shell_axil_ctrl_wstrb),
    .shell_axil_ctrl_wvalid(shell_axil_ctrl_wvalid),
    // -- SHELL AXI DMA --
    .shell_axi_dma_araddr(shell_axi_dma_araddr),
    .shell_axi_dma_arburst(shell_axi_dma_arburst),
    .shell_axi_dma_arcache(shell_axi_dma_arcache),
    .shell_axi_dma_arlen(shell_axi_dma_arlen),
    .shell_axi_dma_arlock(shell_axi_dma_arlock),
    .shell_axi_dma_arprot(shell_axi_dma_arprot),
    .shell_axi_dma_arqos(shell_axi_dma_arqos),
    .shell_axi_dma_arready(shell_axi_dma_arready),
    .shell_axi_dma_arsize(shell_axi_dma_arsize),
    .shell_axi_dma_arvalid(shell_axi_dma_arvalid),
    .shell_axi_dma_awaddr(shell_axi_dma_awaddr),
    .shell_axi_dma_awburst(shell_axi_dma_awburst),
    .shell_axi_dma_awcache(shell_axi_dma_awcache),
    .shell_axi_dma_awlen(shell_axi_dma_awlen),
    .shell_axi_dma_awlock(shell_axi_dma_awlock),
    .shell_axi_dma_awprot(shell_axi_dma_awprot),
    .shell_axi_dma_awqos(shell_axi_dma_awqos),
    .shell_axi_dma_awready(shell_axi_dma_awready),
    .shell_axi_dma_awsize(shell_axi_dma_awsize),
    .shell_axi_dma_awvalid(shell_axi_dma_awvalid),
    .shell_axi_dma_bready(shell_axi_dma_bready),
    .shell_axi_dma_bresp(shell_axi_dma_bresp),
    .shell_axi_dma_bvalid(shell_axi_dma_bvalid),
    .shell_axi_dma_rdata(shell_axi_dma_rdata),
    .shell_axi_dma_rlast(shell_axi_dma_rlast),
    .shell_axi_dma_rready(shell_axi_dma_rready),
    .shell_axi_dma_rresp(shell_axi_dma_rresp),
    .shell_axi_dma_rvalid(shell_axi_dma_rvalid),
    .shell_axi_dma_wdata(shell_axi_dma_wdata),
    .shell_axi_dma_wlast(shell_axi_dma_wlast),
    .shell_axi_dma_wready(shell_axi_dma_wready),
    .shell_axi_dma_wstrb(shell_axi_dma_wstrb),
    .shell_axi_dma_wvalid(shell_axi_dma_wvalid)
);
endmodule
