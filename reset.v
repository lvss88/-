
module reset_dly(
	input clk,
	input rst_n,
	output rst_n_dly
);
reg[27:0] cnt = 28'd0;
reg rst_n_reg;
assign rst_n_dly = rst_n_reg;
always@(posedge clk)
   if(rst_n==1'b0)
        cnt <= 0;
    else
    	if(cnt != 28'h3ffffff)
	    	cnt <= cnt + 1'd1;
	    else
		    cnt <= cnt;
always@(posedge clk)
	rst_n_reg <= (cnt == 28'h3ffffff);
endmodule 
