module rgbhsv(
input clk,
input rst_n,

input RGB_vsync,
input RGB_hsync,
input RGB_de   ,

input [23:0]RGB_data, 


output face_vsync,
output face_hsync,
output face_de,
output  wire  [23:0]  face_data,
output  reg  [7:0]  hsv_h_1,
output  reg  [7:0]  hsv_h_2,
output  reg  [7:0]  hsv_h_3
//output reg [7:0]	 hsv_v, //HSV数据
//output [7:0] aa,
//output [7:0] bb
);

wire[8:0]hsv_h; //取值范围：0~360
wire [8:0]hsv_s;//取值范围：0~1,表示方式：1bit整数+8bit小数
wire [7:0]hsv_v;


wire [7:0]rgb_r;
wire [7:0]rgb_g;
wire [7:0]rgb_b;


reg [7:0]max;
reg	[7:0]min;

reg	[13:0]rgb_r_r;
reg	[13:0]rgb_g_r;
reg	[13:0]rgb_b_r;

reg [13:0]rgb_r_r2;
reg	[13:0]rgb_g_r2;
reg	[13:0]rgb_b_r2;
reg	[7:0]max_r;

wire [7:0]max_min;
assign	max_min=max-min;
reg  [7:0]max_min_r;
wire [13:0]max60;
assign max60=max*60;

assign rgb_r = RGB_data[23:16]	; 
assign rgb_g = RGB_data[15:8]	; 
assign rgb_b = RGB_data[7:0]	; 

wire [13:0] g_b;
wire [13:0] b_r;
wire [13:0] r_g;
assign	g_b=(rgb_g_r>=rgb_b_r)?(rgb_g_r-rgb_b_r):(rgb_b_r-rgb_g_r);
assign  b_r=(rgb_b_r>=rgb_r_r)?(rgb_b_r-rgb_r_r):(rgb_r_r-rgb_b_r);
assign  r_g=(rgb_r_r>=rgb_g_r)?(rgb_r_r-rgb_g_r):(rgb_g_r-rgb_r_r);


reg [13:0]temp;
reg	[13:0]hsv_h_r;
reg	[15:0]hsv_s_r;
reg	[7:0]hsv_v_r;




always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		rgb_r_r<=0;
		rgb_g_r<=0;
		rgb_b_r<=0;
	end
	else begin
		rgb_r_r<=60*rgb_r;
        rgb_g_r<=60*rgb_g;
        rgb_b_r<=60*rgb_b;
	end
end	

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		rgb_r_r2<=0;
        rgb_g_r2<=0;
	    rgb_b_r2<=0;
	end
	else begin
		rgb_r_r2<=rgb_r_r;
	    rgb_g_r2<=rgb_g_r;
	    rgb_b_r2<=rgb_b_r;
	end
end
	
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		max<=0;
	else if((rgb_r>=rgb_b)&&(rgb_r>=rgb_g))
		max<=rgb_r;
	else if((rgb_g>=rgb_b)&&(rgb_g>=rgb_r))
		max<=rgb_g;
	else if((rgb_b>=rgb_r)&&(rgb_b>=rgb_g))
		max<=rgb_b;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		min<=0;
	else if((rgb_r<=rgb_b)&&(rgb_r<=rgb_g))
		min<=rgb_r;
	else if((rgb_g<=rgb_b)&&(rgb_g<=rgb_r))
		min<=rgb_g;
	else if((rgb_b<=rgb_r)&&(rgb_b<=rgb_g))
		min<=rgb_b;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		max_min_r<=0;
	else
		max_min_r<=max_min;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		temp<=0;
	else if(max_min!=0)begin
		if(rgb_r_r==max60)
			temp<=g_b/{6'b0,max_min};
		else if(rgb_g_r==max60)
			temp<=b_r/{6'b0,max_min};
		else if(rgb_b_r==max60)
			temp<=r_g/{6'b0,max_min};
	end
	else if(max_min==0)
		temp<=0;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		max_r<=0;
	else
		max_r<=max;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		hsv_h_r<=0;
	else if(max_r==0)
		hsv_h_r<=0;
	else if(rgb_r_r2==60*max_r)
		hsv_h_r<=(rgb_g_r2>=rgb_b_r2)?temp:(14'd360-temp);
	else if(rgb_g_r2==60*max_r)
		hsv_h_r<=(rgb_b_r2>=rgb_r_r2)?(temp+120):(14'd120-temp);
	else if(rgb_b_r2==60*max_r)
		hsv_h_r<=(rgb_r_r2>=rgb_g_r2)?(temp+240):(14'd240-temp);
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		hsv_s_r<=0;
	else if(max_r==0)
		hsv_s_r<=0;
	else
		hsv_s_r<={max_min_r,8'b0}/{8'b0,max_r};
end


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		hsv_v_r<=0;
	else
		hsv_v_r<=max_r;
end
	
reg [2:0]vs_delay;
reg	[2:0]hs_delay;
reg	[2:0]de_delay;

	
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		vs_delay<=0;
        hs_delay<=0;
        de_delay<=0;
	end
	else begin
		vs_delay <= { vs_delay[1:0],RGB_vsync};
        hs_delay <= { hs_delay[1:0],RGB_hsync};
        de_delay <= { de_delay[1:0],RGB_de};
	end
end

assign face_vsync=vs_delay[2];
assign face_hsync=hs_delay[2];
assign face_de=de_delay[2];

assign hsv_h=hsv_h_r[8:0];
assign hsv_s=hsv_s_r[8:0];
assign hsv_v=hsv_v_r;
reg [7:0] aa;
reg [7:0] bb;

reg [7:0] disp_r;
reg [7:0] disp_g;
reg [7:0] disp_b;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        disp_r <= 'h0;
        disp_g <= 'h0;
        disp_b <= 'h0;
    end else begin 
        if(hsv_h>=9'd359)//防止溢出//hsv_h取值范围：0~360
            disp_b <= 8'd255; 
        else 
            disp_b <= {hsv_h,8'd0}/9'd360;
        //
        if(hsv_s>9'd255)//hsv_s取值范围：0~256
            disp_g <= 8'd255; 
        else
            disp_g <= hsv_s ;
        //
        disp_r <= hsv_v;
    end
end

assign face_data = {disp_r,disp_g,disp_b};


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
    hsv_h_1<='d0;
    hsv_h_2<='d0;
    hsv_h_3<='d0;
    end
    else if(hsv_h>'d30&&hsv_h<'d45)//N
    hsv_h_1<=hsv_h[7:0];
    else if(hsv_h>'d60&&hsv_h<'d80)//P
    hsv_h_2<=hsv_h[7:0];
    else if(hsv_h>'d100&&hsv_h<'d120)//K
    hsv_h_3<=hsv_h[7:0];
end

endmodule
