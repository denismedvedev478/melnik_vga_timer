module timer#(
    parameter CLK_FREQ_HZ=20_000_000
) (
    input  logic        clk,
    input  logic        rst,
    input  logic        t1ms_override,
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
    assign tick_1ms = t1ms_override ? t1ms_ext : tick_1ms_int;

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
        else if (state==SET && key1_min) set_min <= set_min+1;
        else if (state==SET && key2_sec) set_sec <= set_sec+1;
    end

    logic[21:0] timer;
    always_ff @(posedge clk or posedge rst) begin : COUNTDOWN_TIMER_LOGIC
        if (rst) begin
            timer <= '0;
        end
        else if (next_state==COUNTDOWN && state==SET)
            timer <= (set_min*60+set_sec)*1000;
        else if (state==COUNTDOWN && tick_1ms)
            timer <= timer-1;
    end

    always_ff @(posedge clk or posedge rst) begin : TIMEOUT_LOGIC
        if (rst)
            timeout <= '0;
        else if (state==COUNTDOWN && timer=='0)
            timeout <= 1;
    end


    logic[5:0] timer_min, timer_sec; logic[9:0] timer_ms;
    assign timer_min = (timer / 21'd1000) / 21'd60;
    assign timer_sec = (timer / 21'd1000);
    assign timer_ms  = (timer % 21'd1000);
    always_comb begin : TIME_FOR_DISPLAY_OUTPUT_MUXING
        if (state==SET) begin
            min_o = set_min;
            sec_o = set_sec;
            ms_o  = '0;
        end
        else begin
            min_o = timer_min;
            sec_o = timer_sec;
            ms_o  = timer_ms;
        end
    end
endmodule