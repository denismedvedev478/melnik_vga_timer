//// DEPRECATED MODULE ////
module font_rom #(
    parameter PIX_DEP = 8,
    parameter GLYPH_W = 40,
    parameter GLYPH_H = 50,
    parameter SYM_NUM = 12,
    
    // dont change
    parameter NUM_ADDR = GLYPH_H*SYM_NUM,  //600 //кол-во адресов
    parameter ADDR_W   = $clog2(NUM_ADDR), //10
    parameter WORD_W   = GLYPH_W*PIX_DEP   //320
)(
    input  logic             clk,
    input  logic[ADDR_W-1:0] addr_i,
    output logic[WORD_W-1:0] word_o
);
    (* rom_style = "block" *) logic [WORD_W-1:0] mem [0:NUM_ADDR-1];

    initial begin
        $readmemh("font.hex", mem);
    end

    always_ff @(posedge clk) begin
        word_o <= mem[addr_i];
    end
endmodule