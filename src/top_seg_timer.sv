module top_seg_timer(
	input       clk,
	input       rstp,
    input       key1,
    input       key2,
    input       key3,
    output logic [3:0] led,
    output logic [7:0] seg_sel,
    output logic [7:0] seg_data
);
logic key1_edge, key2_edge, key3_edge;
debouncer #(
    .TIMEOUT_MS(20),
    .CLK_FREQ_HZ(20_000_000)
)debouncer_key1_inst(
    .clk(clk),
	.rst(rstp),
    .btn_raw(key1),
    .btn_edge(key1_edge)
);
debouncer #(
    .TIMEOUT_MS(20),
    .CLK_FREQ_HZ(20_000_000)
)debouncer_key2_inst(
    .clk(clk),
	.rst(rstp),
    .btn_raw(key2),
    .btn_edge(key2_edge)
);
debouncer #(
    .TIMEOUT_MS(20),
    .CLK_FREQ_HZ(20_000_000)
)debouncer_key3_inst(
    .clk(clk),
	.rst(rstp),
    .btn_raw(key3),
    .btn_edge(key3_edge)
);

logic[5:0] minutes;
logic[5:0] seconds;
logic[9:0] milliseconds;
assign led[3:1] = {key3, key2, key1};
timer#(
    .OVERRIDE_TICK_1ms(0),
    .CLK_FREQ_HZ(20_000_000)
) timer_inst(
    .clk(clk),
    .rst(rstp),
    .t1ms_ext(tick_1ms),
    .key1_min (key1_edge),
    .key2_sec (key2_edge),
    .key3_mode(key3_edge),
    .min_o  (minutes),
    .sec_o  (seconds),
    .ms_o   (milliseconds),
    .timeout(timeout),
    .state_o(led[0])
);

logic[7:0] min_dec;
hex2dec #(
    .HEX_WIDTH(6),
    .DEC_DIGITS(2)
) hex2dec_min_inst (
    .hex_in(minutes),
    .dec_out(min_dec)
);
logic[7:0] sec_dec;
hex2dec #(
    .HEX_WIDTH(6),
    .DEC_DIGITS(2)
) hex2dec_sec_inst (
    .hex_in(seconds),
    .dec_out(sec_dec)
);
logic[11:0] ms_dec;
hex2dec #(
    .HEX_WIDTH(10),
    .DEC_DIGITS(3)
) hex2dec_ms_inst (
    .hex_in(milliseconds),
    .dec_out(ms_dec)
);

logic[4*(3+2+2)-1:0] dec_timer_seg;
assign dec_timer_seg = {min_dec, sec_dec, ms_dec};
logic[7:0] seg_data_0, seg_data_1, seg_data_2, seg_data_3; 
logic[7:0] seg_data_4, seg_data_5, seg_data_6, seg_data_7;
hex_to_7seg u_hex (
    .hex_in    ({'0, dec_timer_seg}),
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
    .rst_n(~rstp),
    .seg_data_0(seg_data_0),
    .seg_data_1(seg_data_1),
    .seg_data_2(seg_data_2),
    .seg_data_3(seg_data_3),
    .seg_data_4(seg_data_4),
    .seg_data_5(seg_data_5),
    .seg_data_6(seg_data_6),
    .seg_data_7(seg_data_7),
    .seg_sel   (seg_sel),
    .seg_data  (seg_data)
);
endmodule