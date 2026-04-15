module clk_div #(
    parameter DIVIDER = 20000 // 20MHz/20_000=1KHz
)(
    input  logic clk,
    input  logic rst,
    output logic clk_div
);
    logic [$clog2(DIVIDER)-1:0] cnt;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 0;
            clk_div <= 1'b0;
        end else begin
            if (cnt == DIVIDER - 1) begin
                cnt <= 0;
                clk_div <= 1'b1;
            end else begin
                cnt <= cnt + 1;
                clk_div <= 1'b0;
            end
        end
    end
endmodule