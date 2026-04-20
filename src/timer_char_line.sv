module timer_char_line #(
    parameter PIX_DEP = 8,
    parameter GLYPH_W = 40,
    parameter GLYPH_H = 50,
    parameter SYM_NUM = 15,
    
    // dont change
    parameter NUM_ADDR = GLYPH_H*SYM_NUM,  //600 //кол-во адресов
    parameter ADDR_W   = $clog2(NUM_ADDR), //10
    parameter WORD_W   = GLYPH_W*PIX_DEP   //320
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic[$clog2(GLYPH_H)-1:0] y_offset,
    input  logic             fetch,
    input  logic[3:0]        char,
    output logic[WORD_W-1:0] line
);
    logic[ADDR_W-1:0] gl_addr;
    logic[WORD_W-1:0] gl_word;

    // 1) определить адрес с учётом y_active и записать в gl_addr
    // 2) знать, что порядок глифов в памяти - SYMBOLS = "0123456789:."
    assign gl_addr = char*GLYPH_H + y_offset;

    (* rom_style = "block" *) logic [WORD_W-1:0] mem [0:NUM_ADDR-1];

    initial $readmemh("font.hex", mem);    

    always_ff @(posedge clk) begin
        if (fetch)
            gl_word <= mem[gl_addr];
    end
    assign line = gl_word;

endmodule