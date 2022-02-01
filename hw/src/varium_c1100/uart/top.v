// Varium C1100 FPGA UART0 example

module uart (input  SYSCLK2_N,
             input  SYSCLK2_P,
             input  FPGA_UART0_RXD,
             output FPGA_UART0_TXD,
             output QSFP28_0_ACTIVITY_LED);

    localparam CLK_HZ       = 100000000;
    localparam BIT_RATE     = 115200;
    localparam PAYLOAD_BITS = 8;

    wire                    sysclk2;
    wire                    resetn;
    wire [PAYLOAD_BITS-1:0] uart_rx_data;
    wire                    uart_rx_valid;
    wire                    uart_rx_break;
    wire                    uart_tx_busy;
    wire                    uart_tx_en;
    wire [PAYLOAD_BITS-1:0] uart_tx_data;

    // TODO: route this out or make it constant.
    assign resetn       = 1'b1;
    assign uart_tx_data = uart_rx_data;
    assign uart_tx_en   = uart_rx_valid;
    assign QSFP28_0_ACTIVITY_LED = uart_rx_valid;

    // input buffer for sysclk2 (100MHz)
    IBUFDS sysclk2_buffer (.O(sysclk2),
                           .I(SYSCLK2_P),
                           .IB(SYSCLK2_N));

    uart_rx #(.BIT_RATE(BIT_RATE),
              .PAYLOAD_BITS(PAYLOAD_BITS),
              .CLK_HZ(CLK_HZ))
    inst_uart_rx (.clk(sysclk2),
                  .resetn(resetn),
                  .uart_rxd(FPGA_UART0_RXD),
                  .uart_rx_en(1'b1),
                  .uart_rx_break(uart_rx_break),
                  .uart_rx_valid(uart_rx_valid),
                  .uart_rx_data(uart_rx_data));

    uart_tx #(.BIT_RATE(BIT_RATE),
              .PAYLOAD_BITS(PAYLOAD_BITS),
              .CLK_HZ(CLK_HZ))
    inst_uart_tx (.clk(sysclk2),
                  .resetn(resetn),
                  .uart_txd(FPGA_UART0_TXD),
                  .uart_tx_en(uart_tx_en),
                  .uart_tx_busy(uart_tx_busy),
                  .uart_tx_data(uart_tx_data));

endmodule
