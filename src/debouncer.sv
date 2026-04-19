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

    localparam integer TIMEOUT_TICKS = (CLK_FREQ_HZ / 1000) * TIMEOUT_MS;
    localparam integer CNT_WIDTH = $clog2(TIMEOUT_TICKS);


    logic btn_sync_0, btn_sync_1;
    always_ff @(posedge clk) begin
        btn_sync_0 <= btn_raw;
        btn_sync_1 <= btn_sync_0;
    end


    logic [CNT_WIDTH-1:0] cnt;
    logic btn_state;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt        <= 0;
            btn_state  <= 1'b1;
            btn_clean  <= 1'b1;
            btn_edge   <= 1'b0;
        end else begin
            btn_edge <= 1'b0;

            if (btn_sync_1 != btn_state) begin
                if (cnt == TIMEOUT_TICKS-1) begin
                    cnt       <= 0;
                    btn_state <= btn_sync_1;
                    btn_clean <= btn_sync_1;

                    if (btn_state == 1'b1 && btn_sync_1 == 1'b0) begin
                        btn_edge <= 1'b1;
                    end

                end else begin
                    cnt <= cnt + 1;
                end
            end else begin
                cnt <= 0;
            end
        end
    end

endmodule