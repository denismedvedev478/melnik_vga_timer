module tb_timer_bcd; 

logic[5:0] minutes;
logic[5:0] seconds;
logic[9:0] milliseconds;
logic      timeout;

logic clk;
logic aresetn;

logic key1_set_min, key2_set_sec, key3_set_mode;


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
    key1_set_min  = 0;
    key2_set_sec  = 0;
    key3_set_mode = 0;

    @(READY);

    // ---------- SET MODE ----------
    // установить 1 мин
    repeat (1) begin
        @(posedge clk);
        key1_set_min = 1;
        @(posedge clk);
        key1_set_min = 0;
    end

    // установить 5 сек
    repeat (5) begin
        @(posedge clk);
        key2_set_sec = 1;
        @(posedge clk);
        key2_set_sec = 0;
    end

    #50;

    // ---------- SWITCH TO COUNTDOWN ----------
    @(posedge clk);
    key3_set_mode = 1;
    @(posedge clk);
    key3_set_mode = 0;

    // ---------- WAIT FOR TIMEOUT ----------
    wait(timeout);

    $display("TIMEOUT reached at time %t", $time);

    #100;
    $finish;
end

logic [3:0] cnt;
logic tick_1ms;
always_ff @(posedge clk or negedge aresetn) begin
    if (!aresetn) begin
        cnt <= 0;
        tick_1ms = 0;
    end else begin
        if (cnt == 9) begin
            cnt <= 0;
            tick_1ms = 1;
        end else begin
            cnt <= cnt + 1;
            tick_1ms = 0;
        end
    end
end

logic [3:0] min_tens, min_ones;
logic [3:0] sec_tens, sec_ones;
logic [3:0] ms_hund, ms_tens, ms_ones;
timer_bcd#(
    .OVERRIDE_TICK_1ms(1),
    .CLK_FREQ_HZ(20_000_000)
) timer_inst(
    .clk(clk),
    .rstp(~aresetn),
    .t1ms_ext(tick_1ms),
    .key1_min (key1_set_min),
    .key2_sec (key2_set_sec),
    .key3_mode(key3_set_mode),
    .min_tens (min_tens),
    .min_ones (min_ones),
    .sec_tens (sec_tens),
    .sec_ones (sec_ones),
    .ms_hund  (ms_hund ),
    .ms_tens  (ms_tens),
    .ms_ones  (ms_ones),
    .timeout(timeout)
);

endmodule