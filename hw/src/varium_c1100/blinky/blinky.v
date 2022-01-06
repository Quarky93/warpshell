module blinky (
    input SYSCLK2_N,
    input SYSCLK2_P,
    output QSFP28_0_ACTIVITY_LED
);
wire sysclk2;
reg [28:0] counter;

// input buffer for sysclk2 (100MHz)
IBUFDS sysclk2_buffer (
    .O(sysclk2),
    .I(SYSCLK2_P),
    .IB(SYSCLK2_N)
);

// counter overflows every 2^29 cycles,
// therefore led will transition every 2^28 cycles / 100MHz = 2.68s
assign QSFP28_0_ACTIVITY_LED = counter[28];

always @(posedge sysclk2) begin
    counter <= counter + 1;
end

endmodule
