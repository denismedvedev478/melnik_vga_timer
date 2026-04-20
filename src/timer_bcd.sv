module timer_bcd #(
    parameter OVERRIDE_TICK_1ms = 0,
    parameter CLK_FREQ_HZ = 20_000_000
)(
    input  logic clk,
    input  logic rstp,
    input  logic t1ms_ext,

    input  logic key1_min,
    input  logic key2_sec,
    input  logic key3_mode,

    output logic [3:0] min_tens, min_ones,
    output logic [3:0] sec_tens, sec_ones,
    output logic [3:0] ms_hund, ms_tens, ms_ones,

    output logic timeout,
    output logic state_o
);

    // ---------------- 1ms tick ----------------
    logic tick_1ms, tick_1ms_int;

    localparam CNT_MAX = CLK_FREQ_HZ / 1000;
    logic [$clog2(CNT_MAX)-1:0] cnt;

    always_ff @(posedge clk or posedge rstp) begin : OVERRIDE_TICK_1MS
        if (rstp) begin
            cnt <= 0;
            tick_1ms_int <= 0;
        end else begin
            if (cnt == CNT_MAX - 1) begin
                cnt <= 0;
                tick_1ms_int <= 1;
            end else begin
                cnt <= cnt + 1;
                tick_1ms_int <= 0;
            end
        end
    end
    assign tick_1ms = OVERRIDE_TICK_1ms ? t1ms_ext : tick_1ms_int;

    /////////////////////////////////////////////////////////////// FSM
    typedef enum logic { SET, COUNTDOWN } state_t;
    state_t state, next_state;

    assign state_o = state;

    always_ff @(posedge clk or posedge rstp)
        if (rstp) state <= SET;
        else      state <= next_state;

    always_comb begin
        case (state)
            SET:       next_state = key3_mode ? COUNTDOWN : SET;
            COUNTDOWN: next_state = (key3_mode || timeout) ? SET : COUNTDOWN;
        endcase
    end

    /////////////////////////////////////////////////////////////// SET
    logic [3:0] set_min_t, set_min_o;
    logic [3:0] set_sec_t, set_sec_o;

    always_ff @(posedge clk or posedge rstp) begin : SET_TIMER_LOGIC
        if (rstp) begin
            set_min_t <= 0; set_min_o <= 0;
            set_sec_t <= 0; set_sec_o <= 0;
        end
        else if (state == SET && key1_min) begin
            if (set_min_o == 9) begin
                set_min_o <= 0;
                if (set_min_t == 5) set_min_t <= 0;
                else set_min_t <= set_min_t + 1;
            end else set_min_o <= set_min_o + 1;
        end
        else if (state == SET && key2_sec) begin
            if (set_sec_o == 9) begin
                set_sec_o <= 0;
                if (set_sec_t == 5) set_sec_t <= 0;
                else set_sec_t <= set_sec_t + 1;
            end else set_sec_o <= set_sec_o + 1;
        end
        else if (next_state == COUNTDOWN && state == SET) begin
            set_min_t <= 0; set_min_o <= 0;
            set_sec_t <= 0; set_sec_o <= 0;
        end
    end

    ////////////////////////////////////////////////////////// COUNTDOWN
    logic [3:0] c_min_t, c_min_o;
    logic [3:0] c_sec_t, c_sec_o;
    logic [3:0] c_ms_h, c_ms_t, c_ms_o;

    always_ff @(posedge clk or posedge rstp) begin : COUNTDOWN_TIMER_LOGIC
        if (rstp) begin
            c_min_t<=0; c_min_o<=0;
            c_sec_t<=0; c_sec_o<=0;
            c_ms_h<=0; c_ms_t<=0; c_ms_o<=0;
        end

        else if (next_state == COUNTDOWN && state == SET) begin
            c_min_t <= set_min_t;
            c_min_o <= set_min_o;
            c_sec_t <= set_sec_t;
            c_sec_o <= set_sec_o;
            c_ms_h  <= 0;
            c_ms_t  <= 0;
            c_ms_o  <= 0;
        end

        else if (state == COUNTDOWN && tick_1ms) begin

            // MS
            if (c_ms_o == 0) begin
                c_ms_o <= 9;

                if (c_ms_t == 0) begin
                    c_ms_t <= 9;

                    if (c_ms_h == 0) begin
                        c_ms_h <= 9;

                        // SEC
                        if (c_sec_o == 0) begin
                            c_sec_o <= 9;

                            if (c_sec_t == 0) begin
                                c_sec_t <= 5;

                                // MIN
                                if (c_min_o == 0) begin
                                    c_min_o <= 9;
                                    if (c_min_t != 0)
                                        c_min_t <= c_min_t - 1;
                                end else c_min_o <= c_min_o - 1;

                            end else c_sec_t <= c_sec_t - 1;

                        end else c_sec_o <= c_sec_o - 1;

                    end else c_ms_h <= c_ms_h - 1;

                end else c_ms_t <= c_ms_t - 1;

            end else c_ms_o <= c_ms_o - 1;
        end
    end

    ////////////////////////////////////////////////////////// TIMEOUT
    always_ff @(posedge clk or posedge rstp) begin : TIMEOUT_LOGIC
        if (rstp)
            timeout <= 0;
        else if (state == COUNTDOWN &&
                 c_min_t==0 && c_min_o==0 &&
                 c_sec_t==0 && c_sec_o==0 &&
                 c_ms_h==0 && c_ms_t==0 && c_ms_o==0)
            timeout <= 1;
        else
            timeout <= 0;
    end

    ////////////////////////////////////////////////////////// OUTPUT MUX
    always_ff @(posedge clk or posedge rstp) begin : TIME_FOR_DISPLAY_OUTPUT_MUXING
        if (rstp) begin
            min_tens<=0; min_ones<=0;
            sec_tens<=0; sec_ones<=0;
            ms_hund<=0;  ms_tens<=0; ms_ones<=0;
        end
        else if (state == SET) begin
            min_tens <= set_min_t;
            min_ones <= set_min_o;
            sec_tens <= set_sec_t;
            sec_ones <= set_sec_o;
            ms_hund  <= 0;
            ms_tens  <= 0;
            ms_ones  <= 0;
        end else begin
            min_tens <= c_min_t;
            min_ones <= c_min_o;
            sec_tens <= c_sec_t;
            sec_ones <= c_sec_o;
            ms_hund  <= c_ms_h;
            ms_tens  <= c_ms_t;
            ms_ones  <= c_ms_o;
        end
    end

endmodule