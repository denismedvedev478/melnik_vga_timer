module font_rom (
    input  logic        clk,
    input  logic [4:0]  char,   // 0..11
    input  logic [5:0]  x,      // 0..49
    input  logic [5:0]  y,      // 0..39
    output logic        pixel
);
    localparam CHAR_W = 50;
    localparam CHAR_H = 40;
    localparam CHARS = 12;
    localparam TOTAL_BITS = CHARS * CHAR_W * CHAR_H; // 24000
    localparam TOTAL_BYTES = TOTAL_BITS / 8;         // 3000

    (* rom_style = "block" *) logic [7:0] mem [0:TOTAL_BYTES-1];

    initial begin
        $readmemh("font.hex", mem);
    end

    // вычисляем битовый адрес (0..23999)
    logic [14:0] bit_addr;
    assign bit_addr = (char * CHAR_H + y) * CHAR_W + x;

    logic [7:0] byte_data;
    logic [2:0] bit_pos;

    always_ff @(posedge clk) begin
        byte_data <= mem[bit_addr[14:3]];  // номер байта (старшие 12 бит)
        bit_pos   <= bit_addr[2:0];        // номер бита в байте (0..7)
        // Поправка порядка битов: первый пиксель (x=0) в старшем бите
        pixel <= byte_data[7 - bit_pos];
    end
endmodule