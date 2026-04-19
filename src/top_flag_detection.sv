module top_flag_detection(
    input clk, rst_n, key1, key2, key3,
    output logic [3:0] led,
    output logic [7:0] seg_sel, seg_data
);
    logic [31:0] data;
    logic done;
    reg [5:0] count;          // счётчик до 32
    reg started;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            data <= 32'hFFFFFFFF;
            count <= 0;
            started <= 0;
            done <= 0;
        end else begin
            // Ждём первый 0 (старт)
            if (!started && key3 == 1'b0) begin
                started <= 1;
                count <= 0;
                data <= 32'b0;
            end

            // Если начали и ещё не закончили
            else if (started && !done) begin
                data <= {data[30:0], key3}; // сдвиг влево + запись
                count <= count + 1;

                if (count == 6'd31) begin
                    done <= 1;  // 32 бита записано
                end
            end
        end
    end

logic [7:0] seg_data_0;
logic [7:0] seg_data_1;
logic [7:0] seg_data_2;
logic [7:0] seg_data_3;
logic [7:0] seg_data_4;
logic [7:0] seg_data_5;
logic [7:0] seg_data_6;
logic [7:0] seg_data_7;
hex_to_7seg u_hex (
    .hex_cnt(data),
    .seg_data_0(seg_data_0),
    .seg_data_1(seg_data_1),
    .seg_data_2(seg_data_2),
    .seg_data_3(seg_data_3),
    .seg_data_4(seg_data_4),
    .seg_data_5(seg_data_5),
    .seg_data_6(seg_data_6),
    .seg_data_7(seg_data_7)
);
seg_scan u_scan (
    .clk(clk),
    .rst_n(rst_n),
    .seg_sel(seg_sel),
    .seg_data(seg_data),
    .seg_data_0(seg_data_0),
    .seg_data_1(seg_data_1),
    .seg_data_2(seg_data_2),
    .seg_data_3(seg_data_3),
    .seg_data_4(seg_data_4),
    .seg_data_5(seg_data_5),
    .seg_data_6(seg_data_6),
    .seg_data_7(seg_data_7)
);
assign led[0] = done;
assign led[3:1] = 3'b000;
endmodule