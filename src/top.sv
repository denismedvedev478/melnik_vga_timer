module top(
    input       clk,
    input       rst_n,
    input       key1,
    input       key2,
    input       key3,
    output      vga_out_hs, //vga horizontal synchronization         
    output      vga_out_vs, //vga vertical synchronization                  
    output[3:0] vga_out_r,  //vga red
    output[3:0] vga_out_g,  //vga green
    output[3:0] vga_out_b   //vga blue
);

parameter CLK_FREQ_HZ = 40_000_000;
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
clk_wiz_0_main main_video_clock_domain( // Clock in ports
  .clk_in1(clk),
  .reset(~rst_n),
  .clk_out1(video_clk)
);

logic key1_edge, key2_edge, key3_edge;
debouncer #(
    .TIMEOUT_MS(20),
    .CLK_FREQ_HZ(CLK_FREQ_HZ)
)debouncer_key1_inst(
    .clk(video_clk),
	.rstp(~rst_n),
    .btn_raw(key1),
    .btn_edge(key1_edge)
);
debouncer #(
    .TIMEOUT_MS(20),
    .CLK_FREQ_HZ(CLK_FREQ_HZ)
)debouncer_key2_inst(
    .clk(video_clk),
	.rstp(~rst_n),
    .btn_raw(key2),
    .btn_edge(key2_edge)
);
debouncer #(
    .TIMEOUT_MS(20),
    .CLK_FREQ_HZ(CLK_FREQ_HZ)
)debouncer_key3_inst(
    .clk(video_clk),
	.rstp(~rst_n),
    .btn_raw(key3),
    .btn_edge(key3_edge)
);

logic[5:0] min_hex;
logic[5:0] sec_hex;
logic[9:0] ms_hex;
//assign led[3:1] = {key3, key2, key1};


logic [3:0] min_tens, min_ones;
logic [3:0] sec_tens, sec_ones;
logic [3:0] ms_hund, ms_tens, ms_ones;
timer_bcd#(
    .OVERRIDE_TICK_1ms(0),
    .CLK_FREQ_HZ(CLK_FREQ_HZ)
) timer_bcd_inst(
    .clk(video_clk),
    .rstp(~rst_n),
    .t1ms_ext(1),
    .key1_min (key1_edge),
    .key2_sec (key2_edge),
    .key3_mode(key3_edge),
    .min_tens (min_tens),
    .min_ones (min_ones),
    .sec_tens (sec_tens),
    .sec_ones (sec_ones),
    .ms_hund  (ms_hund ),
    .ms_tens  (ms_tens),
    .ms_ones  (ms_ones),
    .timeout(timeout_bcd)
);

logic timeout_long;

pulse_extender #(
    .CLK_FREQ_HZ(CLK_FREQ_HZ)   // укажите вашу реальную частоту
) ext_inst (
    .clk(clk),
    .rstp(~rst_n),
    .timeout_in(timeout_bcd),      // исходный 1-тактовый сигнал
    .timeout_out(timeout_long) // расширенный до 1 секунды
);

vga vga_inst(
	.clk(video_clk),
	.rstp(~rst_n),
    .timeout  (timeout_long),
    .min_tens (min_tens),
    .min_ones (min_ones),
    .sec_tens (sec_tens),
    .sec_ones (sec_ones),
    .ms_hund  (ms_hund ),
    .ms_tens  (ms_tens),
    .ms_ones  (ms_ones),
	.hs(video_hs),
	.vs(video_vs),
	.de(video_de),
	.rgb_r(video_r),
	.rgb_g(video_g),
	.rgb_b(video_b)
);

/*color_bar cbi(
	.clk(video_clk),
	.rst(~rst_n),
	.hs(video_hs),
	.vs(video_vs),
	.de(video_de),
	.rgb_r(video_r),
	.rgb_g(video_g),
	.rgb_b(video_b)
);*/

endmodule