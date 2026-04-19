module timer#(
    parameter OVERRIDE_TICK_1ms = 0, // 1 for oferriding
    parameter CLK_FREQ_HZ=20_000_000
) (
    input  logic        clk,
    input  logic        rst,
    input  logic        t1ms_ext,

    input  logic        key1_min,   //KEY_JUST_PRESSED STATE
    input  logic        key2_sec,
    input  logic        key3_mode,
    output logic [5:0]  min_o,
    output logic [5:0]  sec_o,
    output logic [9:0]  ms_o,
    output logic        timeout,
    output logic        state_o
);
    logic tick_1ms_int; // (internal) pulse every ms
    localparam CNT_MAX=CLK_FREQ_HZ/1000;
    logic [$clog2(CNT_MAX)-1:0] cnt;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 0;
            tick_1ms_int <= 1'b0;
        end else begin
            if (cnt == CNT_MAX - 1) begin
                cnt <= 0;
                tick_1ms_int <= 1'b1;
            end else begin
                cnt <= cnt + 1;
                tick_1ms_int <= 1'b0;
            end
        end
    end
    generate
        assign tick_1ms = OVERRIDE_TICK_1ms ? t1ms_ext : tick_1ms_int;
    endgenerate


    typedef enum logic { SET, COUNTDOWN } state_t;
    state_t state, next_state;
    assign state_o=state;

    always_ff @( posedge clk or posedge rst ) begin : FSM_SET_STATE_LOGIC
        if (rst) state <= SET;
        else state <= next_state;
    end

    always_comb begin : FSM_NEXT_STATE_LOGIC
        case (state)
            SET:
                if (key3_mode) next_state = COUNTDOWN;
                else next_state = SET;
            COUNTDOWN:
                if (key3_mode || timeout) next_state = SET;
                else next_state = COUNTDOWN;
        endcase
    end


    logic[5:0] set_min, set_sec; // 6bit set time (only 0-59 values are valid)
    always_ff @(posedge clk or posedge rst) begin : SET_TIMER_LOGIC
        if (rst) begin
            set_min <= '0;
            set_sec <= '0;
        end
        else if (state==SET && key1_min) set_min <= (set_min+1)%6'd60;
        else if (state==SET && key2_sec) set_sec <= (set_sec+1)%6'd60;
        else if (next_state == COUNTDOWN && state == SET) begin
            set_min   <= '0;
            set_sec   <= '0;
        end
    end

    logic [5:0]  count_min;
    logic [5:0]  count_sec;
    logic [9:0]  count_ms;

    always_ff @(posedge clk or posedge rst) begin : COUNTDOWN_TIMER_LOGIC
        if (rst) begin
            count_min <= '0;
            count_sec <= '0;
            count_ms  <= '0;
        end
        // Загрузка нового значения при переходе из SET в COUNTDOWN
        else if (next_state == COUNTDOWN && state == SET) begin
            count_min <= set_min;
            count_sec <= set_sec;
            count_ms  <= 10'd0;
        end
        // Логика обратного отсчёта
        else if (state == COUNTDOWN && tick_1ms) begin
            if (count_ms == 10'd0) begin
                if (count_sec == 6'd0 && count_min == 6'd0) begin
                    // Таймер достиг нуля, ничего не делаем, пусть timeout сработает
                    count_min <= count_min;
                    count_sec <= count_sec;
                    count_ms  <= count_ms;
                end else begin
                    count_ms <= 10'd999; // Устанавливаем в 999
                    if (count_sec == 6'd0) begin
                        count_sec <= 6'd59;
                        if (count_min > 6'd0)
                            count_min <= count_min - 1;
                    end else begin
                        count_sec <= count_sec - 1;
                    end
                end
            end else begin
                count_ms <= count_ms - 1;
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin : TIMEOUT_LOGIC
        if (rst)
            timeout <= 1'b0;
        else if (state == COUNTDOWN && count_ms == 10'd0 && count_sec == 6'd0 && count_min == 6'd0)
            timeout <= 1'b1;
        else
            timeout <= 1'b0;
    end

    always_ff @(posedge clk or posedge rst) begin : TIME_FOR_DISPLAY_OUTPUT_MUXING
        if (rst) begin
            min_o <= '0;
            sec_o <= '0;
            ms_o  <= '0;
        end
        else if (state==SET) begin
            min_o <= set_min;
            sec_o <= set_sec;
            ms_o  <= '0;
        end
        else begin
            min_o <= count_min;
            sec_o <= count_sec;
            ms_o  <= count_ms;
        end
    end
endmodule