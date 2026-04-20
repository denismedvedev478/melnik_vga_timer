module top(
    input       clk,
    input       rst_n,
    input       key1,
    input       key2,
    input       key3,
    output logic [3:0] led,
    output      vga_out_hs, //vga horizontal synchronization         
    output      vga_out_vs, //vga vertical synchronization                  
    output[4:0] vga_out_r,  //vga red
    output[5:0] vga_out_g,  //vga green
    output[4:0] vga_out_b,   //vga blue
    output logic [7:0] seg_sel,
    output logic [7:0] seg_data
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
/*video_pll video_pll_inst(
	.inclk0(clk),
	.c0(video_clk));*/
clk_wiz_0 video_pll_clk_wiz_0(
  // Status and control signals
    .clk_in1 (clk),
    .reset   (~rst_n),  
    .clk_out1(video_clk)
);

logic key1_edge, key2_edge, key3_edge;
debouncer #(
    .TIMEOUT_MS(20),
    .CLK_FREQ_HZ(20_000_000)
)debouncer_key1_inst(
    .clk(clk),
	.rstp(~rst_n),
    .btn_raw(key1),
    .btn_edge(key1_edge)
);
debouncer #(
    .TIMEOUT_MS(20),
    .CLK_FREQ_HZ(20_000_000)
)debouncer_key2_inst(
    .clk(clk),
	.rstp(~rst_n),
    .btn_raw(key2),
    .btn_edge(key2_edge)
);
debouncer #(
    .TIMEOUT_MS(20),
    .CLK_FREQ_HZ(20_000_000)
)debouncer_key3_inst(
    .clk(clk),
	.rstp(~rst_n),
    .btn_raw(key3),
    .btn_edge(key3_edge)
);

logic[5:0] min_hex;
logic[5:0] sec_hex;
logic[9:0] ms_hex;
//assign led[3:1] = {key3, key2, key1};
timer#(
    .OVERRIDE_TICK_1ms(0),
    .CLK_FREQ_HZ(20_000_000)
) timer_inst(
    .clk(clk),
    .rstp(~rst_n),
    .t1ms_ext('0),
    .key1_min (key1_edge),
    .key2_sec (key2_edge),
    .key3_mode(key3_edge),
    .min_o  (min_hex),
    .sec_o  (sec_hex),
    .ms_o   (ms_hex),
    .timeout(timeout),
    .state_o(led[0])
);

logic [3:0] min_tens, min_ones;
logic [3:0] sec_tens, sec_ones;
logic [3:0] ms_hund, ms_tens, ms_ones;
timer_bcd#(
    .OVERRIDE_TICK_1ms(1),
    .CLK_FREQ_HZ(20_000_000)
) timer_bcd_inst(
    .clk(clk),
    .rstp(~aresetn),
    .t1ms_ext(tick_1ms),
    .key1_min (key1_set_min),
    .key2_sec (key2_set_sec),
    .key3_mode(key3_set_mode),
    .min_tens (min_tens),
    .min_ones (min_ones),
    .sec_tens (sec_tens),
    .sec_ones (sec_ones),
    .ms_hund  (ms_hund ),
    .ms_tens  (ms_tens),
    .ms_ones  (ms_ones),
    .timeout(timeout)
);

logic[7:0] min_dec;
hex2dec #(
    .HEX_WIDTH(6),
    .DEC_DIGITS(2)
) hex2dec_min_inst (
    .hex_in(min_hex),
    .dec_out(min_dec)
);
logic[7:0] sec_dec;
hex2dec #(
    .HEX_WIDTH(6),
    .DEC_DIGITS(2)
) hex2dec_sec_inst (
    .hex_in(sec_hex),
    .dec_out(sec_dec)
);
logic[11:0] ms_dec;
hex2dec #(
    .HEX_WIDTH(10),
    .DEC_DIGITS(3)
) hex2dec_ms_inst (
    .hex_in(ms_hex),
    .dec_out(ms_dec)
);

logic[4*(3+2+2)-1:0] dec_timer_seg;
assign dec_timer_seg = {min_dec, sec_dec, ms_dec};
logic [7:0] seg_data_0;
logic [7:0] seg_data_1;
logic [7:0] seg_data_2;
logic [7:0] seg_data_3;
logic [7:0] seg_data_4;
logic [7:0] seg_data_5;
logic [7:0] seg_data_6;
logic [7:0] seg_data_7;
hex_to_7seg u_hex (
    .hex_cnt(dec_timer_seg),
    .seg_data_0(seg_data_0),
    .seg_data_1(seg_data_1),
    .seg_data_2(seg_data_2),
    .seg_data_3(seg_data_3),
    .seg_data_4(seg_data_4),
    .seg_data_5(seg_data_5),
    .seg_data_6(seg_data_6),
    .seg_data_7(seg_data_7)
);
seg_scan u_scan (
    .clk(clk),
    .rst_n(rst_n),
    .seg_sel(seg_sel),
    .seg_data(seg_data),
    .seg_data_0(seg_data_0),
    .seg_data_1(seg_data_1),
    .seg_data_2(seg_data_2),
    .seg_data_3(seg_data_3),
    .seg_data_4(seg_data_4),
    .seg_data_5(seg_data_5),
    .seg_data_6(seg_data_6),
    .seg_data_7(seg_data_7)
);

vga vga_inst(
	.clk(video_clk),
	.rstp(~rst_n),
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

endmodule