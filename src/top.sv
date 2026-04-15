module top(
	input       clk,
	input       rst_p,
    input       key1,
    input       key2,
    input       key3,
	output      vga_out_hs, //vga horizontal synchronization         
	output      vga_out_vs, //vga vertical synchronization                  
	output[4:0] vga_out_r,  //vga red
	output[5:0] vga_out_g,  //vga green
	output[4:0] vga_out_b   //vga blue
);

logic      video_clk;
logic      video_hs;
logic      video_vs;
logic      video_de;
logic[7:0] video_r;
logic[7:0] video_g;
logic[7:0] video_b;

assign vga_out_hs = video_hs;
assign vga_out_vs = video_vs;
assign vga_out_r  = video_r[7:3]; //discard low bit data
assign vga_out_g  = video_g[7:2]; //discard low bit data
assign vga_out_b  = video_b[7:3]; //discard low bit data

logic clk_fb;
//generate video pixel clock
PLLE2_BASE #(
    .BANDWIDTH("OPTIMIZED"),  // OPTIMIZED, HIGH, LOW
    .CLKFBOUT_MULT(13),        // Multiply value for all CLKOUT, (2-64)
    .CLKFBOUT_PHASE(0.0),     // Phase offset in degrees of CLKFB, (-360.000-360.000).
    .CLKIN1_PERIOD(20),   // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
    // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
    .CLKOUT0_DIVIDE(4),
    .CLKOUT1_DIVIDE(1),
    .CLKOUT2_DIVIDE(1),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT5_DIVIDE(1),
    // CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT5_DUTY_CYCLE(0.5),
    // CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
    .CLKOUT0_PHASE(0.0),
    .CLKOUT1_PHASE(0.0),
    .CLKOUT2_PHASE(0.0),
    .CLKOUT3_PHASE(0.0),
    .CLKOUT4_PHASE(0.0),
    .CLKOUT5_PHASE(0.0),
    .DIVCLK_DIVIDE(1),        // Master division value, (1-56)
    .REF_JITTER1(0.0),        // Reference input jitter in UI, (0.000-0.999).
    .STARTUP_WAIT("FALSE")    // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
) PLLE2_BASE_inst (
    // Clock Outputs: 1-bit (each) output: User configurable clock outputs
    .CLKOUT0(video_clk),   // 1-bit output: CLKOUT0
    .CLKOUT1(),   // 1-bit output: CLKOUT1
    .CLKOUT2(),   // 1-bit output: CLKOUT2
    .CLKOUT3(),   // 1-bit output: CLKOUT3
    .CLKOUT4(),   // 1-bit output: CLKOUT4
    .CLKOUT5(),   // 1-bit output: CLKOUT5
    // Feedback Clocks: 1-bit (each) output: Clock feedback ports
    .CLKFBOUT(clk_fb),  // 1-bit output: Feedback clock
    .LOCKED(),    // 1-bit output: LOCK
    .CLKIN1(clk),    // 1-bit input: Input clock
    // Control Ports: 1-bit (each) input: PLL control ports
    .PWRDWN(1'b0),    // 1-bit input: Power-down
    .RST(rst_p),       // 1-bit input: Reset
    // Feedback Clocks: 1-bit (each) input: Clock feedback ports
    .CLKFBIN(clk_fb)    // 1-bit input: Feedback clock
);

logic clk_1khz;
clk_div #(
    .DIVIDER(20000) // 20MHz/20_000=1KHz
) clk_div_inst (
    .clk(clk),
	.rst(rst_p),
    .clk_div(clk_1khz)
);

logic key1_edge, key2_edge, key3_edge;
debouncer #(
    .TIMEOUT_MS(20),
    .CLK_FREQ_HZ(20_000_000)
)debouncer_key1_inst(
    .clk(clk),
	.rst(rst_p),
    .btn_raw(key1),
    .btn_edge(key1_edge)
);
debouncer #(
    .TIMEOUT_MS(20),
    .CLK_FREQ_HZ(20_000_000)
)debouncer_key2_inst(
    .clk(clk),
	.rst(rst_p),
    .btn_raw(key2),
    .btn_edge(key2_edge)
);
debouncer #(
    .TIMEOUT_MS(20),
    .CLK_FREQ_HZ(20_000_000)
)debouncer_key3_inst(
    .clk(clk),
	.rst(rst_p),
    .btn_raw(key3),
    .btn_edge(key3_edge)
);

logic[7:0] minutes;
logic[7:0] seconds;
logic[9:0] milliseconds;
logic      timeout;
timer timer_inst(
    .clk(clk),
	.rst(rst_p),
    
    .tick_1ms   (clk_1khz),
    .key1_edge  (key1_edge),
    .key2_edge  (key2_edge),
    .key3_edge  (key3_edge),

    .minutes_out     (minutes),
    .seconds_out     (seconds),
    .milliseconds_out(milliseconds),
    .timeout         (timeout)
);

vga vga_inst(
	.clk(video_clk),
	.rst(rst_p),
    .minutes     (minutes),
    .seconds     (seconds),
    .milliseconds(milliseconds),
	.hs(video_hs),
	.vs(video_vs),
	.de(video_de),
	.rgb_r(video_r),
	.rgb_g(video_g),
	.rgb_b(video_b)
);

endmodule