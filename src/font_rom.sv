module font_rom (
    input  logic        clk,
    input  logic [14:0] addr, // 24000 < 2^15
    output logic        data
);
    (* rom_style = "block" *) logic mem [0:23999];

    initial begin
        $readmemh("font.hex", mem);
    end

    always_ff @(posedge clk) begin
        data <= mem[addr];
    end

endmodule