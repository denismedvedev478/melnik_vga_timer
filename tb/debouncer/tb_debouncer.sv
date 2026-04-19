module tb_debouncer; 

logic clk;
logic aresetn;

logic key2, key2_clean, key2_edge;

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
    key2=1;
    @(READY);

    // ---------- SET MODE ----------
    // установить 1 мин
    repeat (1) begin
        @(posedge clk);
        key2 = 0;
        @(posedge clk);
        key2 = 1;
    end

    // установить 5 сек
    repeat (5) begin
        @(posedge clk);
        key2 = 0;
        @(posedge clk);
        key2 = 1;
    end

    repeat (5) begin
        @(posedge clk);
        key2 = 1;
        @(posedge clk);
        key2 = 0;
    end
    #500;

    repeat (5) begin
        @(posedge clk);
        key2 = 0;
        @(posedge clk);
        key2 = 0;
        @(posedge clk);
        key2 = 0;
        @(posedge clk);
        key2 = 1;
    end

    repeat (5) begin
        @(posedge clk);
        key2 = 1;
        @(posedge clk);
        key2 = 0;
    end
    #50;

    // ---------- SWITCH TO COUNTDOWN ----------
    @(posedge clk);
    key2 = 0;
    @(posedge clk);
    key2 = 1;

    #1000;
    @(posedge clk);
    key2 = 0;
    @(posedge clk);
    key2 = 1;
    @(posedge clk);
    key2 = 0;
    #1000;
    key2 = 0;
    #1000;
    $finish;
end


debouncer #(
    .TIMEOUT_MS(20),
    .CLK_FREQ_HZ(1000) //1khz
)debouncer_key2_inst(
    .clk(clk),
	.rst(~aresetn),
    .btn_raw(key2),
    .btn_clean(key2_clean),
    .btn_edge (key2_edge)
);

endmodule