
/*============================================
#
# Author: Wcc - 1530604142@qq.com
#
# QQ : 1530604142
#
# Last modified: 2020-07-06 19:48
#
# Filename: calculate_histogram.v
#
# Description: 
#
============================================*/
`timescale 1ns / 1ps
module calculate_histogram(
	input 	wire 			clk 		,
	input	wire 			rst 		,
	input 	wire 			pi_hsync	,
	input	wire 			pi_vsync	,
	input	wire 			pi_data_vld	,
	input 	wire 	[7:0]	pi_data 	,

	output 	wire 			po_histo_vld,
	output 	wire 	[63:0]	po_histo_data,
	output  reg  	[7:0]	rd_ram_addr
				
    );
//==========================================
//parameter define
//==========================================
parameter IMG_WIDTH 	= 	480 	;
parameter IMG_HEIGHT 	=	272 	;
parameter GRAY_LEVEL	= 	256		;//�Ҷȼ�

parameter IDLE 		= 4'b0001;//����״̬
parameter CLEAR		= 4'b0010;//���RAM������״̬
parameter CALCULATE = 4'b0100;//ͳ��ͼ��ֱ��ͼ״̬
parameter GET_HISTO = 4'b1000;//���ֱ��ͼ


//==========================================
//internal siganls
//==========================================
reg 	[3:0]	state 		;//״̬�Ĵ���
reg 	[1:0]	vsync_dd	;//��ͬ���źżĴ�

//==========================================
//���RAM�׶�
//==========================================
reg 	[8:0]	cnt_clear 	;
wire			add_cnt_clear;
wire 			end_cnt_clear;
reg 			clear_flag	;//���RAMָʾ�ź�

//==========================================
//ͳ��ֱ��ͼ�׶�
//==========================================
reg 	[12:0]	cnt_row 	;
wire 			add_cnt_row ;
wire 			end_cnt_row	;

reg 			data_vld_dd0;//������Ч��ʱ�ź�
reg 			data_vld_dd1;//������Ч��ʱ�ź�
reg 	[7:0]	pi_data_dd0	;//��Ч������ʱ
reg 	[7:0]	pi_data_dd1	;//��Ч������ʱ
reg 	[63:0]	cal_pixle	;//��ͬ������ͳ��ֵ
reg 	[63:0]	cal_value 	;//д��RAM��ͳ��ֵ
reg 			cal_value_vld;//д��RAM������Ч�ź�
reg 			cal_one_row_done	;//ͳ��һ��ͼ�����ݽ���
wire 	[7:0]	cal_wr_ram_addr;//ͳ��״̬��дRAM�ĵ�ַ
wire 	[7:0]	cal_rd_ram_addr;//ͳ��״̬�¶�RAM�ĵ�ַ

//==========================================
//�������ݽ׶�
//==========================================
reg 			get_data_flag 	;
reg 	[8:0]	cnt_get 		;
wire 			add_cnt_get 	;
wire 			end_cnt_get 	;
reg 			histo_data_vld 	;
wire 	[63:0]	histo_data 		;

//==========================================
//Block RAM Related Signals
//==========================================
reg 			wr_ram_en 	;//дRAMʹ���ź�
reg 	[7:0]	wr_ram_addr	;//дRAM��ַ
reg 	[63:0]	wr_ram_data ;//д��RAM������
reg  	[7:0]	rd_ram_addr ;//��RAM�ĵ�ַ
wire	[63:0]	rd_ram_data	;//��RAM�ж���������


assign po_histo_data = (histo_data_vld) ? histo_data : 32'd0;
assign po_histo_vld = histo_data_vld;


//----------------state machine describe------------------
always @(posedge clk) begin
	if (rst==1'b1) begin
		state <= IDLE ;
	end
	else begin
		case(state)
			IDLE : begin
				//��⵽�µ�һ֡ͼ��
				if (vsync_dd[0] == 1'b1 && vsync_dd[1] == 1'b0) begin
					state <= CLEAR;
				end
				else begin
					state <= IDLE;
				end
			end

			CLEAR : begin
				//��ǰRAM�е������Ѿ����
				if (end_cnt_clear == 1'b1) begin
					state <= CALCULATE;
				end
				else begin
					state <= CLEAR;
				end
			end
			
			CALCULATE : begin
				//��ǰһ��ͼ�����ݵĻҶ�ֱ��ͼ�Ѿ�ͳ�����
				if (end_cnt_row == 1'b1) begin
					state <= GET_HISTO;
				end
				else begin
					state <= CALCULATE;
				end				
			end

			GET_HISTO : begin
				//��RAM�е�ֱ��ͼ����ȫ������
				if (end_cnt_get == 1'b1) begin
					state <= IDLE;
				end
				else begin
					state <= GET_HISTO;
				end
				
			end

			default : begin
				state <= IDLE;
			end

		endcase 
	end
end

//----------------vsync_dd------------------
//���һ֡ͼ��
always @(posedge clk) begin
	if (rst==1'b1) begin
		vsync_dd <= 'd0;
	end
	else begin
		vsync_dd <= {vsync_dd[0], pi_vsync};
	end
end

//==========================================
//during the clear state
//==========================================
//----------------cnt_clear------------------
//�������RAM�ļ�����
always @(posedge clk) begin
	if (rst == 1'b1) begin
		cnt_clear <= 'd0;
	end
	else if (add_cnt_clear) begin
		if(end_cnt_clear)
			cnt_clear <= 'd0;
		else
			cnt_clear <= cnt_clear + 1'b1;
	end
	else begin
		cnt_clear <= 'd0;
	end
end

assign add_cnt_clear = 	state == CLEAR && wr_ram_en == 1'b1;
assign end_cnt_clear = add_cnt_clear &&	cnt_clear == GRAY_LEVEL - 1;

//----------------clear_flag------------------
always @(posedge clk) begin
	if (rst==1'b1) begin
		clear_flag <= 1'b0;
	end
	else if (state == CLEAR ) begin
		if (end_cnt_clear == 1'b1) begin
			clear_flag <= 1'b0;
		end
		else begin
			clear_flag <= 1'b1;
		end
	end
	else begin
		clear_flag <= 1'b0;
	end
end


//==========================================
//during the calculate state
//==========================================

//----------------delay------------------
always @(posedge clk) begin
	if (rst==1'b1) begin
		data_vld_dd0 <= 'd0;
		data_vld_dd1 <= 'd0;
		pi_data_dd0	 <= 'd0;
		pi_data_dd1	 <= 'd0;
	end
	else begin
		data_vld_dd0 <= pi_data_vld;
		data_vld_dd1 <= data_vld_dd0;
		pi_data_dd0	 <= pi_data;
		pi_data_dd1	 <= pi_data_dd0;
	end
end

//----------------cal_pixle------------------
always @(posedge clk) begin
	if (rst==1'b1) begin
		cal_pixle <= 'd1;
	end
	else if (state == CALCULATE && data_vld_dd0 == 1'b1 ) begin
		//�����������ص��ֵ��ͬ��ͳ��ֵ�ص�1
		if (pi_data != pi_data_dd0 ) begin
			cal_pixle <= 'd1;
		end
		//һ��ͼ������ͳ�ƽ���
		else if (pi_data_vld == 1'b0 ) begin
			cal_pixle <= 'd1;
		end
		//�����������ص��ֵ��ͬ
		else if (pi_data == pi_data_dd0) begin
			cal_pixle <= cal_pixle + 1'b1;
		end
	end
	else begin
		cal_pixle <= 'd1;
	end
end

//----------------cal_value------------------
//д��RAM������
always @(posedge clk) begin
	if (rst==1'b1) begin
		cal_value <= 'd0;
		cal_value_vld <= 1'b0;
	end
	else if (state == CALCULATE ) begin
		//������������ֵ��ͬ������ǰͳ�ƽ��д��
		if (pi_data != pi_data_dd0 && data_vld_dd0 == 1'b1) begin
			//��RAM�ж��������ݣ���һ�ĵ���ʱ�����ﱣ֤�����ݶ���
			cal_value <= rd_ram_data + cal_pixle;
			cal_value_vld <= 1'b1;
		end
		//һ��ͼ��ͳ�ƽ���������ǰ���д��
		else if(pi_data_vld == 1'b0 && data_vld_dd0 == 1'b1)begin
			cal_value <= rd_ram_data + cal_pixle;
			cal_value_vld <= 1'b1;
		end
		else begin
			cal_value <= 'd0;
			cal_value_vld <= 1'b0;
		end
	end
	else begin
		cal_value <= 'd0;
		cal_value_vld <= 1'b0;	
	end
end
//----------------cal_wr_ram_addr/cal_rd_ram_addr------------------
assign cal_wr_ram_addr = pi_data_dd1; 	//д������RAM�ĵ�ַ
assign cal_rd_ram_addr = pi_data;		//��������RAM�ĵ�ַ

//----------------cal_one_row_done------------------
always @(posedge clk) begin
	if (rst==1'b1) begin
		cal_one_row_done <= 1'b0;
	end
	//һ��ͼ��ͳ�����
	else if (state == CALCULATE && pi_data_vld == 1'b0 && data_vld_dd0 == 1'b1) begin
		cal_one_row_done <= 1'b1;
	end
	else begin
		cal_one_row_done <= 1'b0;
	end
end

//----------------cnt_row------------------
always @(posedge clk) begin
	if (rst == 1'b1) begin
		cnt_row <= 'd0;
	end
	else if (add_cnt_row) begin
		if(end_cnt_row)
			cnt_row <= 'd0;
		else
			cnt_row <= cnt_row + 1'b1;
	end
end

assign add_cnt_row = cal_one_row_done == 1'b1;
assign end_cnt_row = add_cnt_row &&	cnt_row == IMG_HEIGHT - 1;

//==========================================
//during get histogram data state
//==========================================

//----------------get_data_flag------------------
always @(posedge clk) begin
	if (rst==1'b1) begin
		get_data_flag <= 1'b0;
	end
	else if (state == GET_HISTO) begin
		if (end_cnt_get == 1'b1) begin
			get_data_flag <= 1'b0;	
		end
		else begin
			get_data_flag <= 1'b1;
		end
	end
	else begin
		get_data_flag <= 1'b0;
	end
end

//----------------cnt_get------------------
always @(posedge clk) begin
	if (rst == 1'b1) begin
		cnt_get <= 'd0;
	end
	else if (add_cnt_get) begin
		if(end_cnt_get)
			cnt_get <= 'd0;
		else
			cnt_get <= cnt_get + 1'b1;
	end
	else begin
		cnt_get <= 'd0;
	end
end

assign add_cnt_get = get_data_flag == 1'b1;
assign end_cnt_get = add_cnt_get &&	cnt_get == GRAY_LEVEL - 1;

//----------------histo_data_vld------------------
always @(posedge clk) begin
	if (rst==1'b1) begin
		histo_data_vld <= 1'b0;
	end
	else begin
		histo_data_vld <= get_data_flag;
	end
end

assign histo_data = (histo_data_vld) ? rd_ram_data : 'd0 ;

//==========================================
//signals that related to Block RAM
//==========================================
histogram_ram inst_bram_histo (
  	.clka(clk),    // input wire clka
  	.wea(wr_ram_en),      // input wire [0 : 0] wea
  	.addra(wr_ram_addr),  // input wire [7 : 0] addra
  	.dina(wr_ram_data),    // input wire [31 : 0] dina
  	.clkb(clk),    // input wire clkb
  	.addrb(rd_ram_addr),  // input wire [7 : 0] addrb
  	.doutb(rd_ram_data)  // output wire [31 : 0] doutb
);

//----------------wr_ram_addr,wr_ram_data,wr_ram_en------------------
always @(*) begin
	if (state == CLEAR) begin
		wr_ram_addr = cnt_clear;
		wr_ram_en 	= clear_flag;
		wr_ram_data = 'd0;
	end
	else if (state == CALCULATE) begin
		wr_ram_addr = cal_wr_ram_addr;
		wr_ram_en 	= cal_value_vld;
		wr_ram_data = cal_value;
	end
	else begin
		wr_ram_addr = 'd0;
		wr_ram_en 	= 1'b0;
		wr_ram_data = 'd0;
	end
end

//----------------rd_ram_addr------------------
always @(*) begin
	if (state == CALCULATE) begin
		rd_ram_addr = cal_rd_ram_addr;
	end
	else if (state == GET_HISTO) begin
		rd_ram_addr = cnt_get;
	end
	else begin
		rd_ram_addr = 'd0;
	end
end

endmodule
