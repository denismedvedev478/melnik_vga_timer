module timer (
    input  logic        clk,
    input  logic        rst,
    input  logic        tick_1ms,
    input  logic        key1_edge,
    input  logic        key2_edge,
    input  logic        key3_edge,
    output logic [7:0]  minutes_out,
    output logic [7:0]  seconds_out,
    output logic [9:0]  milliseconds_out,
    output logic        timeout
);
    typedef enum logic { SET, COUNTDOWN } mode_t;
    mode_t mode;

    logic [7:0] set_min, set_sec;   // установленное время
    logic [7:0] cnt_min, cnt_sec;
    logic [9:0] cnt_ms;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            mode <= SET;
            set_min <= 0;
            set_sec <= 0;
            cnt_min <= 0;
            cnt_sec <= 0;
            cnt_ms <= 0;
            timeout <= 1'b0;
        end else begin
            // переключение режима по key3
            if (key3_edge) begin
                if (mode == SET) begin
                    mode <= COUNTDOWN;
                    cnt_min <= set_min;
                    cnt_sec <= set_sec;
                    cnt_ms <= 0;
                    timeout <= 1'b0;
                end else begin
                    mode <= SET;
                end
            end

            // режим установки времени
            if (mode == SET) begin
                if (key1_edge) begin
                    if (set_min < 8'd99) set_min <= set_min + 1;
                    else set_min <= 0;
                end
                if (key2_edge) begin
                    if (set_sec < 8'd59) set_sec <= set_sec + 1;
                    else set_sec <= 0;
                end
            end

            // режим обратного отсчёта
            if (mode == COUNTDOWN && tick_1ms && !timeout) begin
                if (cnt_ms == 0) begin
                    if (cnt_sec == 0 && cnt_min == 0) begin
                        timeout <= 1'b1;  // время вышло
                    end else begin
                        cnt_ms <= 10'd999;
                        if (cnt_sec == 0) begin
                            cnt_sec <= 8'd59;
                            if (cnt_min > 0) cnt_min <= cnt_min - 1;
                        end else begin
                            cnt_sec <= cnt_sec - 1;
                        end
                    end
                end else begin
                    cnt_ms <= cnt_ms - 1;
                end
            end

            // выходные значения
            if (mode == SET) begin
                minutes_out      <= set_min;
                seconds_out      <= set_sec;
                milliseconds_out <= 10'd0;
            end else begin
                minutes_out      <= cnt_min;
                seconds_out      <= cnt_sec;
                milliseconds_out <= cnt_ms;
            end
        end
    end
endmodule