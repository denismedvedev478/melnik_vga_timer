module pulse_extender #(
    parameter CLK_FREQ_HZ = 50_000_000   // частота clk в Гц
)(
    input  logic clk,
    input  logic rstp,                   // активный высокий сброс
    input  logic timeout_in,             // короткий импульс (1 такт)
    output logic timeout_out             // расширенный импульс (1 секунда)
);
    localparam COUNT_MAX = CLK_FREQ_HZ - 1;  // 50_000_000 - 1 = 49_999_999

    logic [$clog2(CLK_FREQ_HZ)-1:0] counter;
    logic active;

    always_ff @(posedge clk or posedge rstp) begin
        if (rstp) begin
            active <= 1'b0;
            counter <= '0;
            timeout_out <= 1'b0;
        end else begin
            if (timeout_in && !active) begin
                // Запуск расширителя
                active <= 1'b1;
                counter <= '0;
                timeout_out <= 1'b1;
            end else if (active) begin
                if (counter == COUNT_MAX) begin
                    // Счёт дошел до максимума – выключаем
                    active <= 1'b0;
                    timeout_out <= 1'b0;
                end else begin
                    counter <= counter + 1'b1;
                    timeout_out <= 1'b1;
                end
            end else begin
                timeout_out <= 1'b0;
            end
        end
    end
endmodule