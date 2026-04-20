module time2vga (
    input  logic        clk,
    input  logic        rstp,

    input  logic        timeout,
    input  logic [11:0] active_x,
    input  logic [11:0] active_y,
    input  logic        video_active,

    input  logic[3:0]   min_tens,
    input  logic[3:0]   min_ones,
    input  logic[3:0]   sec_tens,
    input  logic[3:0]   sec_ones,
    input  logic[3:0]   ms_hund,
    input  logic[3:0]   ms_tens,
    input  logic[3:0]   ms_ones,

    output logic [7:0]  r,
    output logic [7:0]  g,
    output logic [7:0]  b
);
    localparam GLYPH_W   = 40;
    localparam GLYPH_H   = 50;
    localparam SYM_NUM   = 15;
    localparam X_OFFSET  = 200;
    localparam Y_OFFSET  = 300;
    localparam NUM_ADDR  = GLYPH_H * SYM_NUM; // 600
    localparam ADDR_W    = $clog2(NUM_ADDR);  // 10
    localparam WORD_W    = GLYPH_W * 8; // 320

    logic in_rect;
    assign in_rect = (active_x >= X_OFFSET) && (active_x < X_OFFSET + 12*GLYPH_W) &&
                     (active_y >= Y_OFFSET) && (active_y < Y_OFFSET + GLYPH_H);
                     
    logic [11:0] rel_x, rel_y;
    assign rel_x = active_x - X_OFFSET;
    assign rel_y = active_y - Y_OFFSET;

    logic [3:0] symbol_index;          // 0..8
    logic [5:0] local_x;               // 0..39 (6 бит)
    logic [5:0] local_y;               // 0..49 (6 бит)

    assign symbol_index = rel_x / GLYPH_W;
    assign local_x      = rel_x % GLYPH_W;
    assign local_y      = rel_y;       // 0..49

    //////////////////////////////////////// SYM_ID
    logic [3:0] symbol_id;
    always_ff @(posedge clk or posedge rstp) begin
        if (rstp)
            symbol_id <= '0;
        else
            case (symbol_index)
                0: symbol_id = min_tens;
                1: symbol_id = min_ones;
                2: symbol_id = 10;      // ':'
                3: symbol_id = sec_tens;
                4: symbol_id = sec_ones;
                5: symbol_id = 11;      // '.'
                6: symbol_id = ms_hund;
                7: symbol_id = ms_tens;
                8: symbol_id = ms_ones;
                9: symbol_id = 12;      // "В"
                10: symbol_id = 13;      // "С"
                11: symbol_id = 14;      // "Ё"
                default: symbol_id = 0;
            endcase
    end

    ///////////////////////////// raddr obsolete
    logic [ADDR_W-1:0] rom_addr;
    assign rom_addr = symbol_id * GLYPH_H + local_y;

    //////////////////////////////////////// ROM
    logic [WORD_W-1:0] line_data;
    timer_char_line #(
        .PIX_DEP(8),
        .GLYPH_W(GLYPH_W),
        .GLYPH_H(GLYPH_H),
        .SYM_NUM(SYM_NUM)
    ) rom_inst (
        .clk(clk),
        .rst_n(~rstp),
        .char(symbol_id),
        .y_offset(local_y),
        .fetch(1),
        .line(line_data)
    );

    logic [3:0] symbol_index_d;
    logic [5:0] local_x_d;
    logic       in_rect_d;
    logic       video_active_d;

    always_ff @(posedge clk) begin
        symbol_index_d <= symbol_index;
        local_x_d      <= local_x;
        in_rect_d      <= in_rect;
        video_active_d <= video_active;
    end

    // just convert LE to BE with stream
    logic [7:0] pixel;
   assign pixel = line_data[(GLYPH_W-1-local_x_d)*8 +: 8];

    //////////////////////////////////////// COLOR
    logic [7:0] r_t, g_t, b_t;
    always_comb begin
        case (symbol_index_d)
            0,1: begin r_t = pixel; g_t = 8'h00; b_t = 8'h00; end
            3,4: begin r_t = 8'h00; g_t = pixel; b_t = 8'h00; end
            6,7,8: begin r_t = 8'h00; g_t = 8'h00; b_t = pixel; end
            default: begin r_t = pixel; g_t = pixel; b_t = pixel; end
        endcase
    end

    always_ff @(posedge clk or posedge rstp) begin
        if (rstp) begin
            r <= 0;
            g <= 0;
            b <= 0;
        end else if (video_active_d && in_rect_d && symbol_index_d >=9) begin
            r <= timeout ? pixel : '0;
            g <= timeout ? pixel : '0;
            b <= timeout ? pixel : '0;
        end
        else if (video_active_d && in_rect_d) begin
            r <= r_t;
            g <= g_t;
            b <= b_t;
        end else begin
            r <= 0;
            g <= 0;
            b <= 0;
        end
    end

endmodule