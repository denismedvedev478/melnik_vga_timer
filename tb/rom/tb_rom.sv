module tb_rom; 
parameter PIX_DEP = 8;
parameter GLYPH_W = 40;
parameter GLYPH_H = 50;
parameter SYM_NUM = 12;

// dont change
parameter NUM_ADDR = GLYPH_H*SYM_NUM;  //600 //кол-во адресов
parameter ADDR_W   = $clog2(NUM_ADDR); //10
parameter WORD_W   = GLYPH_W*PIX_DEP;   //320

logic clk;
logic aresetn;
logic[$clog2(GLYPH_H)-1:0] y_offset;
logic             fetch;
logic[3:0]        char;
logic[WORD_W-1:0] line;

event READY;
initial begin
    fork
        begin 
            clk = 0;
            forever #5 clk = ~clk; // 100 MHz
        end
        begin
            aresetn = 0;
            #20 aresetn = 1;
            ->READY;
        end
    join_none
end


initial begin
    y_offset <= '0;
    fetch <= '0;
    char <= '0;
    @(READY);
    @(posedge clk);
    @(posedge clk);
    y_offset <= 10;
    fetch <= 1;
    char <= '0;
    @(posedge clk);
    fetch <= 0;
    @(posedge clk);
    $display("%d %d: %h\n",char, y_offset, line) ;
    @(posedge clk) $finish;
end

timer_char_line timer_char_line_inst (
    .clk     (clk),
    .rst_n   (aresetn),
    .y_offset(y_offset),
    .fetch   (fetch),
    .char    (char),
    .line(line)
);

endmodule