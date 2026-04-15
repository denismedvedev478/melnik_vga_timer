module time2vga (
    input  logic        clk,
    input  logic        rst,

    input  logic [11:0] active_x,
    input  logic [11:0] active_y,
    input  logic        video_active,

    input  logic [7:0]  minutes,
    input  logic [7:0]  seconds,
    input  logic [9:0]  milliseconds,

    output logic [7:0]  r,
    output logic [7:0]  g,
    output logic [7:0]  b
);

parameter DIGIT_W = 40;
parameter DIGIT_H = 50;
parameter GLYPH_SIZE = DIGIT_W * DIGIT_H; // 2000

parameter X_OFFSET = 200;
parameter Y_OFFSET = 300;

// ---------------- BCD ----------------
logic [3:0] min_tens, min_ones;
logic [3:0] sec_tens, sec_ones;
logic [3:0] ms_hund, ms_tens, ms_ones;

assign min_tens = minutes / 10;
assign min_ones = minutes % 10;

assign sec_tens = seconds / 10;
assign sec_ones = seconds % 10;

assign ms_hund = milliseconds / 100;
assign ms_tens = (milliseconds / 10) % 10;
assign ms_ones = milliseconds % 10;

// ---------------- область вывода ----------------
logic in_rect;

assign in_rect =
    (active_x >= X_OFFSET) &&
    (active_x < X_OFFSET + 9*DIGIT_W) &&
    (active_y >= Y_OFFSET) &&
    (active_y < Y_OFFSET + DIGIT_H);

// локальные координаты
logic [11:0] rel_x, rel_y;
assign rel_x = active_x - X_OFFSET;
assign rel_y = active_y - Y_OFFSET;

// символ
logic [3:0] symbol_index;
logic [5:0] local_x, local_y;

assign symbol_index = rel_x / DIGIT_W;
assign local_x      = rel_x % DIGIT_W;
assign local_y      = rel_y;

// ---------------- выбор символа ----------------
logic [3:0] symbol_id;

always_comb begin
    case (symbol_index)
        0: symbol_id = min_tens;
        1: symbol_id = min_ones;
        2: symbol_id = 10; // ':'
        3: symbol_id = sec_tens;
        4: symbol_id = sec_ones;
        5: symbol_id = 11; // '.'
        6: symbol_id = ms_hund;
        7: symbol_id = ms_tens;
        8: symbol_id = ms_ones;
        default: symbol_id = 0;
    endcase
end

// ---------------- адрес BRAM ----------------
logic [14:0] font_addr;
assign font_addr =
    symbol_id * GLYPH_SIZE +
    local_y   * DIGIT_W +
    local_x;

// ---------------- ROM ----------------
logic pixel;

font_rom font_rom_i (
    .clk(clk),
    .addr(font_addr),
    .data(pixel)
);

// ---------------- pipeline (1 такт задержки BRAM) ----------------
logic [3:0] symbol_index_d;
logic       in_rect_d;
logic       video_active_d;

always_ff @(posedge clk) begin
    symbol_index_d <= symbol_index;
    in_rect_d      <= in_rect;
    video_active_d <= video_active;
end

// ---------------- цвет ----------------
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        r <= 0; g <= 0; b <= 0;
    end else if (video_active_d && in_rect_d && pixel) begin
        case (symbol_index_d)
            0,1: begin r <= 8'hFF; g <= 0;      b <= 0;      end // минуты
            3,4: begin r <= 0;      g <= 8'hFF; b <= 0;      end // секунды
            6,7,8:begin r <= 0;      g <= 0;      b <= 8'hFF; end // миллисекунды
            default: begin r <= 8'hFF; g <= 8'hFF; b <= 8'hFF; end
        endcase
    end else begin
        r <= 0; g <= 0; b <= 0;
    end
end

endmodule