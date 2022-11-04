module top #(
    PCIE_LANES = 4,
    DMA_DATA_WIDTH = 128
)(
    input wire pcie_refclk_n,
    input wire pcie_refclk_p,
    input wire pcie_rstn,
    input wire [PCIE_LANES-1:0] pcie_mgt_rxn,
    input wire [PCIE_LANES-1:0] pcie_mgt_rxp,
    output wire [PCIE_LANES-1:0] pcie_mgt_txn,
    output wire [PCIE_LANES-1:0] pcie_mgt_txp,
    input wire [3:0] satellite_gpio,
    input wire satellite_uart_rxd,
    output wire satellite_uart_txd
);
    // -- [user_axi_clk] ----------------------------------------------------------
    wire user_axi_clk;
    // ----------------------------------------------------------------------------

    // -- [user_axi_rstn] ---------------------------------------------------------
    wire user_axi_rstn;
    // ----------------------------------------------------------------------------

    // -- [user_axi_ctrl] ---------------------------------------------------------
    wire [31:0] user_axi_ctrl_araddr;
    wire [2:0] user_axi_ctrl_arprot;
    wire [0:0] user_axi_ctrl_arready;
    wire [0:0] user_axi_ctrl_arvalid;
    wire [31:0] user_axi_ctrl_awaddr;
    wire [2:0] user_axi_ctrl_awprot;
    wire [0:0] user_axi_ctrl_awready;
    wire [0:0] user_axi_ctrl_awvalid;
    wire [0:0] user_axi_ctrl_bready;
    wire [1:0] user_axi_ctrl_bresp;
    wire [0:0] user_axi_ctrl_bvalid;
    wire [31:0] user_axi_ctrl_rdata;
    wire [0:0] user_axi_ctrl_rready;
    wire [1:0] user_axi_ctrl_rresp;
    wire [0:0] user_axi_ctrl_rvalid;
    wire [31:0] user_axi_ctrl_wdata;
    wire [0:0] user_axi_ctrl_wready;
    wire [3:0] user_axi_ctrl_wstrb;
    wire [0:0] user_axi_ctrl_wvalid;
    // ----------------------------------------------------------------------------

    // -- [user_axi_dma] ----------------------------------------------------------
    wire [63:0]user_axi_dma_araddr;
    wire [1:0]user_axi_dma_arburst;
    wire [3:0]user_axi_dma_arcache;
    wire [7:0]user_axi_dma_arlen;
    wire [0:0]user_axi_dma_arlock;
    wire [2:0]user_axi_dma_arprot;
    wire [3:0]user_axi_dma_arqos;
    wire [0:0]user_axi_dma_arready;
    wire [2:0]user_axi_dma_arsize;
    wire [0:0]user_axi_dma_arvalid;
    wire [63:0]user_axi_dma_awaddr;
    wire [1:0]user_axi_dma_awburst;
    wire [3:0]user_axi_dma_awcache;
    wire [7:0]user_axi_dma_awlen;
    wire [0:0]user_axi_dma_awlock;
    wire [2:0]user_axi_dma_awprot;
    wire [3:0]user_axi_dma_awqos;
    wire [0:0]user_axi_dma_awready;
    wire [2:0]user_axi_dma_awsize;
    wire [0:0]user_axi_dma_awvalid;
    wire [0:0]user_axi_dma_bready;
    wire [1:0]user_axi_dma_bresp;
    wire [0:0]user_axi_dma_bvalid;
    wire [DMA_DATA_WIDTH-1:0]user_axi_dma_rdata;
    wire [0:0]user_axi_dma_rlast;
    wire [0:0]user_axi_dma_rready;
    wire [1:0]user_axi_dma_rresp;
    wire [0:0]user_axi_dma_rvalid;
    wire [DMA_DATA_WIDTH-1:0]user_axi_dma_wdata;
    wire [0:0]user_axi_dma_wlast;
    wire [0:0]user_axi_dma_wready;
    wire [DMA_DATA_WIDTH/8-1:0]user_axi_dma_wstrb;
    wire [0:0]user_axi_dma_wvalid;
    // ----------------------------------------------------------------------------

    shell shell_i (
        .pcie_mgt_rxn(pcie_mgt_rxn),
        .pcie_mgt_rxp(pcie_mgt_rxp),
        .pcie_mgt_txn(pcie_mgt_txn),
        .pcie_mgt_txp(pcie_mgt_txp),
        .pcie_refclk_clk_n(pcie_refclk_n),
        .pcie_refclk_clk_p(pcie_refclk_p),
        .pcie_rstn(pcie_rstn),
        .satellite_gpio(satellite_gpio),
        .satellite_uart_rxd(satellite_uart_rxd),
        .satellite_uart_txd(satellite_uart_txd),

        // -- [user_axi_clk] --------------------------------------------------
        .user_axi_clk(user_axi_clk),
        // --------------------------------------------------------------------

        // -- [user_axi_rstn] -------------------------------------------------
        .user_axi_rstn(user_axi_rstn),
        // --------------------------------------------------------------------
        
        // -- [user_axi_ctrl] -------------------------------------------------
        .user_axi_ctrl_araddr(user_axi_ctrl_araddr),
        .user_axi_ctrl_arready(user_axi_ctrl_arready),
        .user_axi_ctrl_arvalid(user_axi_ctrl_arvalid),
        .user_axi_ctrl_awaddr(user_axi_ctrl_awaddr),
        .user_axi_ctrl_awready(user_axi_ctrl_awready),
        .user_axi_ctrl_awvalid(user_axi_ctrl_awvalid),
        .user_axi_ctrl_bready(user_axi_ctrl_bready),
        .user_axi_ctrl_bresp(user_axi_ctrl_bresp),
        .user_axi_ctrl_bvalid(user_axi_ctrl_bvalid),
        .user_axi_ctrl_rdata(user_axi_ctrl_rdata),
        .user_axi_ctrl_rready(user_axi_ctrl_rready),
        .user_axi_ctrl_rresp(user_axi_ctrl_rresp),
        .user_axi_ctrl_rvalid(user_axi_ctrl_rvalid),
        .user_axi_ctrl_wdata(user_axi_ctrl_wdata),
        .user_axi_ctrl_wready(user_axi_ctrl_wready),
        .user_axi_ctrl_wstrb(user_axi_ctrl_wstrb),
        .user_axi_ctrl_wvalid(user_axi_ctrl_wvalid),
        // --------------------------------------------------------------------
        
        // -- [user_axi_dma] --------------------------------------------------
        .user_axi_dma_araddr(user_axi_dma_araddr),
        .user_axi_dma_arlen(user_axi_dma_arlen),
        .user_axi_dma_arready(user_axi_dma_arready),
        .user_axi_dma_arsize(user_axi_dma_arsize),
        .user_axi_dma_arvalid(user_axi_dma_arvalid),
        .user_axi_dma_awaddr(user_axi_dma_awaddr),
        .user_axi_dma_awlen(user_axi_dma_awlen),
        .user_axi_dma_awready(user_axi_dma_awready),
        .user_axi_dma_awsize(user_axi_dma_awsize),
        .user_axi_dma_awvalid(user_axi_dma_awvalid),
        .user_axi_dma_bready(user_axi_dma_bready),
        .user_axi_dma_bresp(user_axi_dma_bresp),
        .user_axi_dma_bvalid(user_axi_dma_bvalid),
        .user_axi_dma_rdata(user_axi_dma_rdata),
        .user_axi_dma_rlast(user_axi_dma_rlast),
        .user_axi_dma_rready(user_axi_dma_rready),
        .user_axi_dma_rresp(user_axi_dma_rresp),
        .user_axi_dma_rvalid(user_axi_dma_rvalid),
        .user_axi_dma_wdata(user_axi_dma_wdata),
        .user_axi_dma_wlast(user_axi_dma_wlast),
        .user_axi_dma_wready(user_axi_dma_wready),
        .user_axi_dma_wstrb(user_axi_dma_wstrb),
        .user_axi_dma_wvalid(user_axi_dma_wvalid),
        // --------------------------------------------------------------------
    );

    user_logic user_logic_i (
        // -- [user_axi_clk] --------------------------------------------------
        .user_axi_clk(user_axi_clk),
        // --------------------------------------------------------------------

        // -- [user_axi_rstn] -------------------------------------------------
        .user_axi_rstn(user_axi_rstn),
        // --------------------------------------------------------------------
        
        // -- [user_axi_ctrl] -------------------------------------------------
        .user_axi_ctrl_araddr(user_axi_ctrl_araddr),
        .user_axi_ctrl_arprot(3'b000),
        .user_axi_ctrl_arready(user_axi_ctrl_arready),
        .user_axi_ctrl_arvalid(user_axi_ctrl_arvalid),
        .user_axi_ctrl_awaddr(user_axi_ctrl_awaddr),
        .user_axi_ctrl_awprot(3'b000),
        .user_axi_ctrl_awready(user_axi_ctrl_awready),
        .user_axi_ctrl_awvalid(user_axi_ctrl_awvalid),
        .user_axi_ctrl_bready(user_axi_ctrl_bready),
        .user_axi_ctrl_bresp(user_axi_ctrl_bresp),
        .user_axi_ctrl_bvalid(user_axi_ctrl_bvalid),
        .user_axi_ctrl_rdata(user_axi_ctrl_rdata),
        .user_axi_ctrl_rready(user_axi_ctrl_rready),
        .user_axi_ctrl_rresp(user_axi_ctrl_rresp),
        .user_axi_ctrl_rvalid(user_axi_ctrl_rvalid),
        .user_axi_ctrl_wdata(user_axi_ctrl_wdata),
        .user_axi_ctrl_wready(user_axi_ctrl_wready),
        .user_axi_ctrl_wstrb(user_axi_ctrl_wstrb),
        .user_axi_ctrl_wvalid(user_axi_ctrl_wvalid),
        // --------------------------------------------------------------------
        
        // -- [user_axi_dma] --------------------------------------------------
        .user_axi_dma_araddr(user_axi_dma_araddr),
        .user_axi_dma_arburst(2'b01),
        .user_axi_dma_arcache(4'b0000),
        .user_axi_dma_arlen(user_axi_dma_arlen),
        .user_axi_dma_arlock(1'b0),
        .user_axi_dma_arprot(3'b000),
        .user_axi_dma_arqos(4'b0000),
        .user_axi_dma_arready(user_axi_dma_arready),
        .user_axi_dma_arsize(user_axi_dma_arsize),
        .user_axi_dma_arvalid(user_axi_dma_arvalid),
        .user_axi_dma_awaddr(user_axi_dma_awaddr),
        .user_axi_dma_awburst(2'b01),
        .user_axi_dma_awcache(4'b0000),
        .user_axi_dma_awlen(user_axi_dma_awlen),
        .user_axi_dma_awlock(1'b0),
        .user_axi_dma_awprot(3'b000),
        .user_axi_dma_awqos(4'b0000),
        .user_axi_dma_awready(user_axi_dma_awready),
        .user_axi_dma_awsize(user_axi_dma_awsize),
        .user_axi_dma_awvalid(user_axi_dma_awvalid),
        .user_axi_dma_bready(user_axi_dma_bready),
        .user_axi_dma_bresp(user_axi_dma_bresp),
        .user_axi_dma_bvalid(user_axi_dma_bvalid),
        .user_axi_dma_rdata(user_axi_dma_rdata),
        .user_axi_dma_rlast(user_axi_dma_rlast),
        .user_axi_dma_rready(user_axi_dma_rready),
        .user_axi_dma_rresp(user_axi_dma_rresp),
        .user_axi_dma_rvalid(user_axi_dma_rvalid),
        .user_axi_dma_wdata(user_axi_dma_wdata),
        .user_axi_dma_wlast(user_axi_dma_wlast),
        .user_axi_dma_wready(user_axi_dma_wready),
        .user_axi_dma_wstrb(user_axi_dma_wstrb),
        .user_axi_dma_wvalid(user_axi_dma_wvalid),
        // --------------------------------------------------------------------
    );
    
endmodule
