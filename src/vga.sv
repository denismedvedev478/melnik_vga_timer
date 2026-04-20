module vga(
	input                 clk,           //pixel clock
	input                 rstp,           //reset signal high active
    input  logic [3:0]    min_tens, min_ones,
    input  logic [3:0]    sec_tens, sec_ones,
    input  logic [3:0]    ms_hund, ms_tens, ms_ones,
	output                hs,            //horizontal synchronization
	output                vs,            //vertical synchronization
	output                de,            //video valid
	output[7:0]           rgb_r,         //video red data
	output[7:0]           rgb_g,         //video green data
	output[7:0]           rgb_b          //video blue data
);
//video timing parameter definition

//800x480 33Mhz
parameter H_ACTIVE = 16'd800; 	//horizontal active time (pixels)
parameter H_FP = 16'd40;      	//horizontal front porch (pixels)
parameter H_SYNC = 16'd128;   	//horizontal sync time(pixels)
parameter H_BP = 16'd88;      	//horizontal back porch (pixels)
parameter V_ACTIVE = 16'd480; 	//vertical active Time (lines)
parameter V_FP  = 16'd1;     	//vertical front porch (lines)
parameter V_SYNC  = 16'd3;    	//vertical sync time (lines)
parameter V_BP  = 16'd21;    	//vertical back porch (lines)
parameter HS_POL = 1'b0;		//horizontal sync polarity, 1 : POSITIVE,0 : NEGATIVE;
parameter VS_POL = 1'b0;		//vertical sync polarity, 1 : POSITIVE,0 : NEGATIVE;

parameter H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;//horizontal total time (pixels)
parameter V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;//vertical total time (lines)
//define the RGB values for 8 colors
parameter WHITE_R       = 8'hff;
parameter WHITE_G       = 8'hff;
parameter WHITE_B       = 8'hff;
parameter YELLOW_R      = 8'hff;
parameter YELLOW_G      = 8'hff;
parameter YELLOW_B      = 8'h00;                                
parameter CYAN_R        = 8'h00;
parameter CYAN_G        = 8'hff;
parameter CYAN_B        = 8'hff;                                
parameter GREEN_R       = 8'h00;
parameter GREEN_G       = 8'hff;
parameter GREEN_B       = 8'h00;
parameter MAGENTA_R     = 8'hff;
parameter MAGENTA_G     = 8'h00;
parameter MAGENTA_B     = 8'hff;
parameter RED_R         = 8'hff;
parameter RED_G         = 8'h00;
parameter RED_B         = 8'h00;
parameter BLUE_R        = 8'h00;
parameter BLUE_G        = 8'h00;
parameter BLUE_B        = 8'hff;
parameter BLACK_R       = 8'h00;
parameter BLACK_G       = 8'h00;
parameter BLACK_B       = 8'h00;

logic       hs_reg;                //horizontal sync register
logic       vs_reg;                //vertical sync register
logic       hs_reg_d0;             //delay 1 clock of 'hs_reg'
logic       vs_reg_d0;             //delay 1 clock of 'vs_reg'
logic[11:0] h_cnt;                 //horizontal counter
logic[11:0] v_cnt;                 //vertical counter
logic[11:0] active_x;              //video x position 
logic[11:0] active_y;              //video y position 
logic[7:0]  rgb_r_reg;             //video red data register
logic[7:0]  rgb_g_reg;             //video green data register
logic[7:0]  rgb_b_reg;             //video blue data register
logic       h_active;              //horizontal video active
logic       v_active;              //vertical video active
logic       video_active;          //video active(horizontal active and vertical active)
logic       video_active_d0;       //delay 1 clock of video_active

assign hs           = hs_reg_d0;
assign vs           = vs_reg_d0;
assign video_active = h_active & v_active;
assign de           = video_active_d0;

always_ff @(posedge clk or posedge rstp)
begin
	if(rstp == 1'b1)
		begin
			hs_reg_d0 <= 1'b0;
			vs_reg_d0 <= 1'b0;
			video_active_d0 <= 1'b0;
		end
	else
		begin
			hs_reg_d0 <= hs_reg;
			vs_reg_d0 <= vs_reg;
			video_active_d0 <= video_active;
		end
end

always_ff @(posedge clk or posedge rstp)
begin
	if(rstp == 1'b1)
		h_cnt <= 12'd0;
	else if(h_cnt == H_TOTAL-1)//horizontal counter maximum value
		h_cnt <= 12'd0;
	else
		h_cnt <= h_cnt + 12'd1;
end

always_ff @(posedge clk or posedge rstp)
begin
	if(rstp == 1'b1)
		active_x <= 12'd0;
	else if(h_cnt >= H_FP+H_SYNC+H_BP-1)//horizontal video active
		active_x <= h_cnt - (H_FP[11:0] + H_SYNC[11:0] + H_BP[11:0] - 12'd1);
	else
		active_x <= active_x;
end

always_ff @(posedge clk or posedge rstp)
begin
	if(rstp == 1'b1)
		v_cnt <= 12'd0;
	else if(h_cnt == H_FP-1)    //horizontal sync time
		if(v_cnt == V_TOTAL-1)  //vertical counter maximum value
			v_cnt <= 12'd0;
		else
			v_cnt <= v_cnt + 12'd1;
	else
		v_cnt <= v_cnt;
end

always_ff @(posedge clk or posedge rstp)
begin
    if(rstp == 1'b1)
        active_y <= 12'd0;
    else if(v_active && (h_cnt == H_FP-1)) // момент начала активной строки по горизонтали
        active_y <= v_cnt - (V_FP + V_SYNC + V_BP - 1);
    else
        active_y <= active_y;
end

always_ff @(posedge clk or posedge rstp)
begin
	if(rstp == 1'b1)
		hs_reg <= 1'b0;
	else if(h_cnt == H_FP - 1)          //horizontal sync begin
		hs_reg <= HS_POL;
	else if(h_cnt == H_FP + H_SYNC - 1) //horizontal sync end
		hs_reg <= ~hs_reg;
	else
		hs_reg <= hs_reg;
end

always_ff @(posedge clk or posedge rstp)
begin
	if(rstp == 1'b1)
		h_active <= 1'b0;
	else if(h_cnt == H_FP + H_SYNC + H_BP - 1)  //horizontal active begin
		h_active <= 1'b1;
	else if(h_cnt == H_TOTAL - 1)               //horizontal active end
		h_active <= 1'b0;
	else
		h_active <= h_active;
end

always_ff @(posedge clk or posedge rstp)
begin
	if(rstp == 1'b1)
		vs_reg <= 1'd0;
	else if((v_cnt == V_FP - 1) && (h_cnt == H_FP - 1))          //vertical sync begin
		vs_reg <= HS_POL;
	else if((v_cnt == V_FP + V_SYNC - 1) && (h_cnt == H_FP - 1)) //vertical sync end
		vs_reg <= ~vs_reg;  
	else
		vs_reg <= vs_reg;
end

always_ff @(posedge clk or posedge rstp)
begin
	if(rstp == 1'b1)
		v_active <= 1'd0;
	else if((v_cnt == V_FP + V_SYNC + V_BP - 1) && (h_cnt == H_FP - 1)) //vertical active begin
		v_active <= 1'b1;
	else if((v_cnt == V_TOTAL - 1) && (h_cnt == H_FP - 1))              //vertical active end
		v_active <= 1'b0;   
	else
		v_active <= v_active;
end

time2vga time2vga_inst(
    .clk(clk),
    .rstp(rstp),

    .active_x    (active_x),
    .active_y    (active_y),
    .video_active(video_active),

    .min_tens (min_tens),
    .min_ones (min_ones),
    .sec_tens (sec_tens),
    .sec_ones (sec_ones),
    .ms_hund  (ms_hund ),
    .ms_tens  (ms_tens),
    .ms_ones  (ms_ones),
	
    .r(rgb_r),
    .g(rgb_g),
    .b(rgb_b)
);

endmodule 