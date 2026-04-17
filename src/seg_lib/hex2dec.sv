module hex2dec #(
    parameter HEX_WIDTH = 8,
    parameter DEC_DIGITS = 3
)(
    input  logic [HEX_WIDTH-1:0] hex_in,
    output logic [4*DEC_DIGITS-1:0] dec_out
);

localparam BCD_WIDTH = 4 * DEC_DIGITS;
localparam TOTAL_WIDTH = HEX_WIDTH + BCD_WIDTH;

logic [TOTAL_WIDTH-1:0] shift_reg;

always_comb begin
    shift_reg = {'0, hex_in};
    
    for (int i = 0; i < HEX_WIDTH; i++) begin
        for (int j = 0; j < DEC_DIGITS; j++) begin
            if (shift_reg[TOTAL_WIDTH-1 - 4*j -: 4] >= 5) begin
                shift_reg[TOTAL_WIDTH-1 - 4*j -: 4] += 3;
            end
        end
        shift_reg = shift_reg << 1;
    end
    
    dec_out = shift_reg[TOTAL_WIDTH-1 -: BCD_WIDTH];
end

endmodule