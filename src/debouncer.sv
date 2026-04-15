module debouncer #(
    parameter TIMEOUT_MS = 20,          // 20 мс
    parameter CLK_FREQ_HZ = 65000000    // 65 MHz
)(
    input  logic clk,
    input  logic rst,
    input  logic btn_raw,
    output logic btn_clean,
    output logic btn_edge
);
    localparam MAX_CNT = TIMEOUT_MS * (CLK_FREQ_HZ / 1000); // 20 * 65000 = 1_300_000
    localparam CNT_WIDTH = $clog2(MAX_CNT);

    logic [CNT_WIDTH-1:0] cnt;
    logic btn_sync, btn_prev;

    // синхронизация
    always_ff @(posedge clk or posedge rst) begin
        if (rst) btn_sync <= 1'b0;
        else     btn_sync <= btn_raw;
    end

    // счётчик стабильного состояния
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 0;
            btn_clean <= 1'b0;
        end else begin
            if (btn_sync == btn_clean)
                cnt <= 0;
            else if (cnt == MAX_CNT - 1) begin
                btn_clean <= btn_sync;
                cnt <= 0;
            end else
                cnt <= cnt + 1;
        end
    end

    // детектор фронта
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_prev <= 1'b0;
            btn_edge <= 1'b0;
        end else begin
            btn_prev <= btn_clean;
            btn_edge <= btn_clean & ~btn_prev;
        end
    end
endmodule