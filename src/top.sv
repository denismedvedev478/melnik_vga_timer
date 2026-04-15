module top(
	input       clk,
	input       rst_n,
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

//generate video pixel clock
video_pll video_pll_inst(
	.inclk0(clk),
	.c0(video_clk));


logic clk_1khz;
clk_div #(
    .DIVIDER(20000) // 20MHz/20_000=1KHz
) clk_div_inst (
    .clk(clk),
	.rst(~rst_n),
    .clk_div(clk_1khz)
);

logic key1_edge, key2_edge, key3_edge;
debouncer #(
    .TIMEOUT_MS(20),
    .CLK_FREQ_HZ(20_000_000)
)debouncer_key1_inst(
    .clk(clk),
	.rst(~rst_n),
    .btn_raw(key1),
    .btn_edge(key1_edge)
);
debouncer #(
    .TIMEOUT_MS(20),
    .CLK_FREQ_HZ(20_000_000)
)debouncer_key2_inst(
    .clk(clk),
	.rst(~rst_n),
    .btn_raw(key2),
    .btn_edge(key2_edge)
);
debouncer #(
    .TIMEOUT_MS(20),
    .CLK_FREQ_HZ(20_000_000)
)debouncer_key3_inst(
    .clk(clk),
	.rst(~rst_n),
    .btn_raw(key3),
    .btn_edge(key3_edge)
);

logic[7:0] minutes;
logic[7:0] seconds;
logic[7:0] milliseconds;
logic      timeout;
timer timer_inst(
    .clk(clk),
	.rst(~rst_n),
    
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
	.rst(~rst_n),
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