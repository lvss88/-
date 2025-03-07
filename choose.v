module  choose(
	input 	wire 			clk 		,
	input	wire 			rst 		,
	input 	wire 			po_histo_vld,
	input 	wire 	[31:0]	po_histo_data	,//控制在二十个
    input 	wire    [7:0]   rd_addr,
	
	output   		 enn  
    );
reg [7:0]    rd_addr_r;
// 1
reg [7:0]    rd_addr_1; 
reg [63:0]   rd_data_1;
// 2
reg [7:0]    rd_addr_2; 
reg [63:0]   rd_data_2;
// 3
reg [7:0]    rd_addr_3; 
reg [63:0]   rd_data_3;
// 4
reg [7:0]    rd_addr_4; 
reg [63:0]   rd_data_4;
// 5
reg [7:0]    rd_addr_5; 
reg [63:0]   rd_data_5;
// 6
reg [7:0]    rd_addr_6; 
reg [63:0]   rd_data_6;
// 7
reg [7:0]    rd_addr_7; 
reg [63:0]   rd_data_7;
// 8
reg [7:0]    rd_addr_8; 
reg [63:0]   rd_data_8;
// 9
reg [7:0]    rd_addr_9; 
reg [63:0]   rd_data_9;
// 10
reg [7:0]    rd_addr_10; 
reg [63:0]   rd_data_10;

//最小值
reg [7:0]    rd_addr_min;
reg [63:0]   rd_data_min;

reg [3:0]  mark				;

reg [63:0] max_rd_data_1  ;
reg [63:0] max_rd_data_2  ;
reg [63:0] max_rd_data_3  ;
reg [63:0] max_rd_data_4  ;
reg [63:0] max_rd_data_5  ;
reg [63:0] max_rd_data_6  ;
reg [63:0] max_rd_data_7  ;
reg [63:0] max_rd_data_8  ;
reg [63:0] max_rd_data_9  ;
reg [63:0] max_rd_data_10 ;
                         
reg [7:0] max_rd_addr_1   ;
reg [7:0] max_rd_addr_2   ;
reg [7:0] max_rd_addr_3   ;
reg [7:0] max_rd_addr_4   ;
reg [7:0] max_rd_addr_5   ;
reg [7:0] max_rd_addr_6   ;
reg [7:0] max_rd_addr_7   ;
reg [7:0] max_rd_addr_8   ;
reg [7:0] max_rd_addr_9   ;
reg [7:0] max_rd_addr_10  ;

reg       wr_down_r		  ;
reg       en			  ;

always@(posedge clk or negedge rst )begin
if(~rst)
rd_addr_r<='d0;
else 
rd_addr_r<=rd_addr;
end
/*
//在十个中找出最小值
always@(posedge clk or negedge rst )begin
if(~rst)begin
rd_data_min<='d0;
end
else if((po_histo_data<rd_data_1)&&(po_histo_data<rd_data_2)&&(po_histo_data<rd_data_3)&&(po_histo_data<rd_data_4)&&(po_histo_data<rd_data_5)&&(po_histo_data<rd_data_6)&&(po_histo_data<rd_data_7)&&(po_histo_data<rd_data_8)&&(po_histo_data<rd_data_9)&&(po_histo_data<rd_data_10))
rd_data_min<=po_histo_data
end
*/

//下降沿
reg wr_reg;
always@(posedge clk or negedge rst)
    	if(~rst) begin
        wr_reg		<=		1'b0;
		
	end
	else begin
		wr_reg		<=		po_histo_vld;

		
	end

assign wr_down=	~po_histo_vld&wr_reg;
always@(*)begin
if(~rst)begin

rd_data_min<='d0;
mark<='d0;

end
else if(wr_down_r)begin
rd_data_min<='d0;
mark<='d0;
end

else if((rd_data_1<=rd_data_2)&&(rd_data_1<=rd_data_3)&&(rd_data_1<=rd_data_4)&&(rd_data_1<=rd_data_5)&&(rd_data_1<=rd_data_6)&&(rd_data_1<=rd_data_7)&&(rd_data_1<=rd_data_8)&&(rd_data_1<=rd_data_9)&&(rd_data_1<=rd_data_10)&&po_histo_vld)  begin

rd_data_min<=rd_data_1;
mark<='d1;

end
else if((rd_data_2<=rd_data_1)&&(rd_data_2<=rd_data_3)&&(rd_data_2<=rd_data_4)&&(rd_data_2<=rd_data_5)&&(rd_data_2<=rd_data_6)&&(rd_data_2<=rd_data_7)&&(rd_data_2<=rd_data_8)&&(rd_data_2<=rd_data_9)&&(rd_data_2<=rd_data_10)&&po_histo_vld)  begin

rd_data_min<=rd_data_2;
mark<='d2;

end
else if((rd_data_3<=rd_data_1)&&(rd_data_3<=rd_data_2)&&(rd_data_3<=rd_data_4)&&(rd_data_3<=rd_data_5)&&(rd_data_3<=rd_data_6)&&(rd_data_3<=rd_data_7)&&(rd_data_3<=rd_data_8)&&(rd_data_3<=rd_data_9)&&(rd_data_3<=rd_data_10)&&po_histo_vld)  begin

rd_data_min<=rd_data_3;
mark<='d3;

end
else if((rd_data_4<=rd_data_1)&&(rd_data_4<=rd_data_2)&&(rd_data_4<=rd_data_3)&&(rd_data_4<=rd_data_5)&&(rd_data_4<=rd_data_6)&&(rd_data_4<=rd_data_7)&&(rd_data_4<=rd_data_8)&&(rd_data_4<=rd_data_9)&&(rd_data_4<=rd_data_10)&&po_histo_vld)  begin

rd_data_min<=rd_data_4;
mark<='d4;

end
else if((rd_data_5<=rd_data_1)&&(rd_data_5<=rd_data_2)&&(rd_data_5<=rd_data_3)&&(rd_data_5<=rd_data_4)&&(rd_data_5<=rd_data_6)&&(rd_data_5<=rd_data_7)&&(rd_data_5<=rd_data_8)&&(rd_data_5<=rd_data_9)&&(rd_data_5<=rd_data_10)&&po_histo_vld)  begin

rd_data_min<=rd_data_5;
mark<='d5;

end
else if((rd_data_6<=rd_data_1)&&(rd_data_6<=rd_data_2)&&(rd_data_6<=rd_data_3)&&(rd_data_6<=rd_data_4)&&(rd_data_6<=rd_data_5)&&(rd_data_6<=rd_data_7)&&(rd_data_6<=rd_data_8)&&(rd_data_6<=rd_data_9)&&(rd_data_6<=rd_data_10)&&po_histo_vld)  begin

rd_data_min<=rd_data_6;
mark<='d6;

end
else if((rd_data_7<=rd_data_1)&&(rd_data_7<=rd_data_2)&&(rd_data_7<=rd_data_3)&&(rd_data_7<=rd_data_4)&&(rd_data_7<=rd_data_5)&&(rd_data_7<=rd_data_6)&&(rd_data_7<=rd_data_8)&&(rd_data_7<=rd_data_9)&&(rd_data_7<=rd_data_10)&&po_histo_vld)  begin

rd_data_min<=rd_data_7;
mark<='d7;

end
else if((rd_data_8<=rd_data_1)&&(rd_data_8<=rd_data_2)&&(rd_data_8<=rd_data_3)&&(rd_data_8<=rd_data_4)&&(rd_data_8<=rd_data_5)&&(rd_data_8<=rd_data_6)&&(rd_data_8<=rd_data_7)&&(rd_data_8<=rd_data_9)&&(rd_data_8<=rd_data_10)&&po_histo_vld)  begin

rd_data_min<=rd_data_8;
mark<='d8;

end
else if((rd_data_9<=rd_data_1)&&(rd_data_9<=rd_data_2)&&(rd_data_9<=rd_data_3)&&(rd_data_9<=rd_data_4)&&(rd_data_9<=rd_data_5)&&(rd_data_9<=rd_data_6)&&(rd_data_9<=rd_data_7)&&(rd_data_9<=rd_data_8)&&(rd_data_9<=rd_data_10)&&po_histo_vld)  begin

rd_data_min<=rd_data_9;
mark<='d9;

end
else if((rd_data_10<=rd_data_1)&&(rd_data_10<=rd_data_2)&&(rd_data_10<=rd_data_3)&&(rd_data_10<=rd_data_4)&&(rd_data_10<=rd_data_5)&&(rd_data_10<=rd_data_6)&&(rd_data_10<=rd_data_7)&&(rd_data_10<=rd_data_8)&&(rd_data_10<=rd_data_9)&&po_histo_vld)  begin

rd_data_min<=rd_data_10;
mark<='d10;

end
end

//找出前十个最大值
always@(* )begin
if(~rst)begin
rd_data_1<='d0;
rd_data_2<='d0;
rd_data_3<='d0;
rd_data_4<='d0;
rd_data_5<='d0;
rd_data_6<='d0;
rd_data_7<='d0;
rd_data_8<='d0;
rd_data_9<='d0;
rd_data_10<='d0;

//地址
rd_addr_1<='d0;
rd_addr_2<='d0;
rd_addr_3<='d0;
rd_addr_4<='d0;
rd_addr_5<='d0;
rd_addr_6<='d0;
rd_addr_7<='d0;
rd_addr_8<='d0;
rd_addr_9<='d0;
rd_addr_10<='d0;
end
//初始化
else if (wr_down_r)begin
rd_data_1<='d0;
rd_data_2<='d0;
rd_data_3<='d0;
rd_data_4<='d0;
rd_data_5<='d0;
rd_data_6<='d0;
rd_data_7<='d0;
rd_data_8<='d0;
rd_data_9<='d0;
rd_data_10<='d0;

rd_addr_1<='d0;
rd_addr_2<='d0;
rd_addr_3<='d0;
rd_addr_4<='d0;
rd_addr_5<='d0;
rd_addr_6<='d0;
rd_addr_7<='d0;
rd_addr_8<='d0;
rd_addr_9<='d0;
rd_addr_10<='d0;
end


//1
else if((po_histo_data>rd_data_min)&&(po_histo_data!=rd_data_1)&&(po_histo_data!=rd_data_2)&&(po_histo_data!=rd_data_3)&&(po_histo_data!=rd_data_4)&&(po_histo_data!=rd_data_5)&&(po_histo_data!=rd_data_6)&&(po_histo_data!=rd_data_7)&&(po_histo_data!=rd_data_8)&&(po_histo_data!=rd_data_9)&&(po_histo_data!=rd_data_10)&&(mark=='d1)&&po_histo_vld) begin
rd_data_1<=po_histo_data;
rd_addr_1<=rd_addr_r;
end

//2
else if((po_histo_data>rd_data_min)&&(po_histo_data!=rd_data_1)&&(po_histo_data!=rd_data_2)&&(po_histo_data!=rd_data_3)&&(po_histo_data!=rd_data_4)&&(po_histo_data!=rd_data_5)&&(po_histo_data!=rd_data_6)&&(po_histo_data!=rd_data_7)&&(po_histo_data!=rd_data_8)&&(po_histo_data!=rd_data_9)&&(po_histo_data!=rd_data_10)&&(mark=='d2)&&po_histo_vld) begin
rd_data_2<=po_histo_data;
rd_addr_2<=rd_addr_r;
end

//3
else if((po_histo_data>rd_data_min)&&(po_histo_data!=rd_data_1)&&(po_histo_data!=rd_data_2)&&(po_histo_data!=rd_data_3)&&(po_histo_data!=rd_data_4)&&(po_histo_data!=rd_data_5)&&(po_histo_data!=rd_data_6)&&(po_histo_data!=rd_data_7)&&(po_histo_data!=rd_data_8)&&(po_histo_data!=rd_data_9)&&(po_histo_data!=rd_data_10)&&(mark=='d3)&&po_histo_vld) begin
rd_data_3<=po_histo_data;
rd_addr_3<=rd_addr_r;
end

//4
else if((po_histo_data>rd_data_min)&&(po_histo_data!=rd_data_1)&&(po_histo_data!=rd_data_2)&&(po_histo_data!=rd_data_3)&&(po_histo_data!=rd_data_4)&&(po_histo_data!=rd_data_5)&&(po_histo_data!=rd_data_6)&&(po_histo_data!=rd_data_7)&&(po_histo_data!=rd_data_8)&&(po_histo_data!=rd_data_9)&&(po_histo_data!=rd_data_10)&&(mark=='d4)&&po_histo_vld) begin
rd_data_4<=po_histo_data;
rd_addr_4<=rd_addr_r;
end

//5
else if((po_histo_data>rd_data_min)&&(po_histo_data!=rd_data_1)&&(po_histo_data!=rd_data_2)&&(po_histo_data!=rd_data_3)&&(po_histo_data!=rd_data_4)&&(po_histo_data!=rd_data_5)&&(po_histo_data!=rd_data_6)&&(po_histo_data!=rd_data_7)&&(po_histo_data!=rd_data_8)&&(po_histo_data!=rd_data_9)&&(po_histo_data!=rd_data_10)&&(mark=='d5)&&po_histo_vld) begin
rd_data_5<=po_histo_data;
rd_addr_5<=rd_addr_r;
end

//6
else if((po_histo_data>rd_data_min)&&(po_histo_data!=rd_data_1)&&(po_histo_data!=rd_data_2)&&(po_histo_data!=rd_data_3)&&(po_histo_data!=rd_data_4)&&(po_histo_data!=rd_data_5)&&(po_histo_data!=rd_data_6)&&(po_histo_data!=rd_data_7)&&(po_histo_data!=rd_data_8)&&(po_histo_data!=rd_data_9)&&(po_histo_data!=rd_data_10)&&(mark=='d6)&&po_histo_vld) begin
rd_data_6<=po_histo_data;
rd_addr_6<=rd_addr_r;
end

//7
else if((po_histo_data>rd_data_min)&&(po_histo_data!=rd_data_1)&&(po_histo_data!=rd_data_2)&&(po_histo_data!=rd_data_3)&&(po_histo_data!=rd_data_4)&&(po_histo_data!=rd_data_5)&&(po_histo_data!=rd_data_6)&&(po_histo_data!=rd_data_7)&&(po_histo_data!=rd_data_8)&&(po_histo_data!=rd_data_9)&&(po_histo_data!=rd_data_10)&&(mark=='d7)&&po_histo_vld) begin
rd_data_7<=po_histo_data;
rd_addr_7<=rd_addr_r;
end

//8
else if((po_histo_data>rd_data_min)&&(po_histo_data!=rd_data_1)&&(po_histo_data!=rd_data_2)&&(po_histo_data!=rd_data_3)&&(po_histo_data!=rd_data_4)&&(po_histo_data!=rd_data_5)&&(po_histo_data!=rd_data_6)&&(po_histo_data!=rd_data_7)&&(po_histo_data!=rd_data_8)&&(po_histo_data!=rd_data_9)&&(po_histo_data!=rd_data_10)&&(mark=='d8)&&po_histo_vld) begin
rd_data_8<=po_histo_data;
rd_addr_8<=rd_addr_r;
end

//9
else if((po_histo_data>rd_data_min)&&(po_histo_data!=rd_data_1)&&(po_histo_data!=rd_data_2)&&(po_histo_data!=rd_data_3)&&(po_histo_data!=rd_data_4)&&(po_histo_data!=rd_data_5)&&(po_histo_data!=rd_data_6)&&(po_histo_data!=rd_data_7)&&(po_histo_data!=rd_data_8)&&(po_histo_data!=rd_data_9)&&(po_histo_data!=rd_data_10)&&(mark=='d9)&&po_histo_vld) begin
rd_data_9<=po_histo_data;
rd_addr_9<=rd_addr_r;
end

//10
else if((po_histo_data>rd_data_min)&&(po_histo_data!=rd_data_1)&&(po_histo_data!=rd_data_2)&&(po_histo_data!=rd_data_3)&&(po_histo_data!=rd_data_4)&&(po_histo_data!=rd_data_5)&&(po_histo_data!=rd_data_6)&&(po_histo_data!=rd_data_7)&&(po_histo_data!=rd_data_8)&&(po_histo_data!=rd_data_9)&&(po_histo_data!=rd_data_10)&&(mark=='d10)&&po_histo_vld) begin
rd_data_10<=po_histo_data;
rd_addr_10<=rd_addr_r;
end

end
//最终结果



always@(*)begin
if(~rst)begin
en<=1'b0;

max_rd_data_1<='d0;
max_rd_data_2<='d0;
max_rd_data_3<='d0;
max_rd_data_4<='d0;
max_rd_data_5<='d0;
max_rd_data_6<='d0;
max_rd_data_7<='d0;
max_rd_data_8<='d0;
max_rd_data_9<='d0;
max_rd_data_10<='d0;

max_rd_addr_1<='d0;
max_rd_addr_2<='d0;
max_rd_addr_3<='d0;
max_rd_addr_4<='d0;
max_rd_addr_5<='d0;
max_rd_addr_6<='d0;
max_rd_addr_7<='d0;
max_rd_addr_8<='d0;
max_rd_addr_9<='d0;
max_rd_addr_10<='d0;

end

else if(wr_down_r)begin

en<=1'b0;

max_rd_data_1<='d0;
max_rd_data_2<='d0;
max_rd_data_3<='d0;
max_rd_data_4<='d0;
max_rd_data_5<='d0;
max_rd_data_6<='d0;
max_rd_data_7<='d0;
max_rd_data_8<='d0;
max_rd_data_9<='d0;
max_rd_data_10<='d0;

max_rd_addr_1<='d0;
max_rd_addr_2<='d0;
max_rd_addr_3<='d0;
max_rd_addr_4<='d0;
max_rd_addr_5<='d0;
max_rd_addr_6<='d0;
max_rd_addr_7<='d0;
max_rd_addr_8<='d0;
max_rd_addr_9<='d0;
max_rd_addr_10<='d0;

end
else if(wr_down)begin
en<=1'b1;

max_rd_data_1<=rd_data_1;
max_rd_data_2<=rd_data_2;
max_rd_data_3<=rd_data_3;
max_rd_data_4<=rd_data_4;
max_rd_data_5<=rd_data_5;
max_rd_data_6<=rd_data_6;
max_rd_data_7<=rd_data_7;
max_rd_data_8<=rd_data_8;
max_rd_data_9<=rd_data_9;
max_rd_data_10<=rd_data_10;


max_rd_addr_1<=rd_addr_1;
max_rd_addr_2<=rd_addr_2;
max_rd_addr_3<=rd_addr_3;
max_rd_addr_4<=rd_addr_4;
max_rd_addr_5<=rd_addr_5;
max_rd_addr_6<=rd_addr_6;
max_rd_addr_7<=rd_addr_7;
max_rd_addr_8<=rd_addr_8;
max_rd_addr_9<=rd_addr_9;
max_rd_addr_10<=rd_addr_10;

end

end

always@(posedge clk or negedge rst )begin
if(~rst)
wr_down_r<='d0;
else 
wr_down_r<=wr_down;
end

//reg [63:0] sum;
//reg [63:0] max_sum;
wire [127:0] percentage;
wire [63:0] all;
reg [63:0] sum;
assign all=272*480;

always@(*)begin

if(~rst)begin
sum<='d0;
end

else if(en)begin
sum<=max_rd_data_1+max_rd_data_2+max_rd_data_3+max_rd_data_4+max_rd_data_5+max_rd_data_6+max_rd_data_7+max_rd_data_8+max_rd_data_9+max_rd_data_10;
end

end
//使能信号
reg enn;
always@(*)begin
if(sum>='d7000)
enn<='d1;
else 
enn<='d0;
end

endmodule