`timescale 1 ns/1 ns

module top_r
#(
    parameter               H_DISP = 1024        ,   //图像宽度
    parameter               V_DISP = 768            //图像高度
)
(
    input   wire            clk                 ,
    input   wire            rst_n               ,
    input   wire            RGB_hsync           ,   //待处理数据行同步
    input   wire            RGB_vsync           ,   //待处理数据场同步
    input   wire    [23:0]  RGB_data            ,   //待处理数捿
    input   wire            RGB_de              ,   //待处理数据使胿

    output  wire            VGA_hsync           ,   //VGA行同歿
    output  wire            VGA_vsync           ,   //VGA场同歿
    output  wire    [23:0]  VGA_data            ,   //VGA数据
    output  wire            VGA_de                  //VGA数据使能

);
reg       VGA_vsync_r;
wire      pose;
reg [2:0] count;

assign pose=VGA_vsync&&~VGA_vsync_r;

always @(posedge clk) begin
	VGA_vsync_r <= VGA_vsync;
end

always @(posedge clk) begin
	if(!rst_n)
		count <= 3'b0;
	//else if(~VGA_vsync && VGA_vsync_r)
	else if(count==3'd2)
	count <=count;
	else if(pose)
		count <= 3'b1+count;
		
end

always @(posedge clk) begin
	if(!rst_n)
		count <= 3'b0;
	//else if(~VGA_vsync && VGA_vsync_r)
	else if(count==3'd2)
	count <=count;
	else if(pose)
		count <= 3'b1+count;
		
end




//    wire                    img_hsync           ;   //待处理数据行同步
//    wire                    img_vsync           ;   //待处理数据场同步
//    wire    [23:0]          img_data            ;   //待处理数捿
//    wire    [7:0]           img_data_R          ;   //待处理数据R分量
//    wire    [7:0]           img_data_G          ;   //待处理数据G分量
//    wire    [7:0]           img_data_B          ;   //待处理数据B分量
//    wire                    img_de              ;   //待处理数据使胿
    
//    wire    [7:0]           VGA_data_R          ;   //待处理数据R分量
//    wire    [7:0]           VGA_data_G          ;   //待处理数据G分量
//    wire    [7:0]           VGA_data_B          ;   //待处理数据B分量

//    wire                    YCbCr_hsync         ;   //待处理数据行同步
//    wire                    YCbCr_vsync         ;   //待处理数据场同步
//    wire    [23:0]          YCbCr_data          ;   //待处理数据B分量
//    wire                    YCbCr_de            ;   //待处理数据使胿

//    wire    [7:0]           Y_data              ;   //Y分量数据

//    wire                    hist_hsync          ;   //hist行同歿
//    wire                    hist_vsync          ;   //hist场同歿
//    wire    [7:0]           hist_data           ;   //hist数据
//    wire                    hist_de             ;   //hist数据使能

//assign VGA_data = {VGA_data_R,VGA_data_G,VGA_data_B};
//assign VGA_data = {hist_data,hist_data,hist_data};
//assign VGA_data = {YCbCr_data[23:16],YCbCr_data[23:16],YCbCr_data[23:16]};
//assign Y_data = YCbCr_data[23:16];

//img_gen
//#(
//    .H_DISP                 (H_DISP             ),  //图像宽度
//    .V_DISP                 (V_DISP             )   //图像高度
//)
//u_img_gen
//(
//    .clk                    (clk                ),  //时钟
//    .rst_n                  (rst_n              ),  //复位
//
//    .img_hsync              (img_hsync          ),  //img行同歿
//    .img_vsync              (img_vsync          ),  //img场同歿
//    .img_data               (img_data           ),  //img数据
//    .img_de                 (img_de             )   //img数据使能
//);

//rgb2ycbcr u_rgb2ycbcr
//(
//    .clk                    (clk                ),
//    .rst_n                  (rst_n              ),
//    .RGB_hsync              (img_hsync          ),   //RGB行同歿
//    .RGB_vsync              (img_vsync          ),   //RGB场同歿
//    .RGB_data               (img_data           ),   //RGB数据
//    .RGB_de                 (img_de             ),   //RGB数据使能
//
//    .YCbCr_hsync            (VGA_hsync          ),   //YCbCr行同歿
//    .YCbCr_vsync            (VGA_vsync          ),   //YCbCr场同歿
//    .YCbCr_data             (VGA_data           ),   //YCbCr数据
//    .YCbCr_de               (VGA_de             )    //YCbCr数据使能
//);

////  信号同步
//always @(posedge clk or negedge rst_n) begin
//    if(!rst_n) begin
//        img_data_r0 <= 24'd0;
//        img_data_r0 <= 24'd0;
//        img_data_r0 <= 24'd0;
//    end
//    else begin  
//        img_data_r0 <= img_data;
//        img_data_r1 <= img_data_r0;
//        img_data_r2 <= img_data_r1;
//    end
//end

hist_equalization
#(
    .H_DISP                 (H_DISP             ),  //图像宽度
    .V_DISP                 (V_DISP             )   //图像高度
)
u_hist_equalization_R
(
    .clk                    (clk                ),
    .rst_n                  (rst_n              ),
    .Y_hsync                (RGB_hsync          ),  //Y分量行同歿
    .Y_vsync                (RGB_vsync          ),  //Y分量场同歿
    .Y_data                 (RGB_data[23:16]    ),  //Y分量数据
    .Y_de                   (RGB_de             ),  //Y分量数据使能

    .hist_hsync             (VGA_hsync          ),  //hist行同歿
    .hist_vsync             (VGA_vsync          ),  //hist场同歿
    .hist_data              (VGA_data[23:16]    ),  //hist数据
    .hist_de                (VGA_de             )   //hist数据使能
);

hist_equalization
#(
    .H_DISP                 (H_DISP             ),  //图像宽度
    .V_DISP                 (V_DISP             )   //图像高度
)
u_hist_equalization_G
(
    .clk                    (clk                ),
    .rst_n                  (rst_n              ),
    .Y_hsync                (RGB_hsync          ),  //Y分量行同歿
    .Y_vsync                (RGB_vsync          ),  //Y分量场同歿
    .Y_data                 (RGB_data[15:8]     ),  //Y分量数据
    .Y_de                   (RGB_de             ),  //Y分量数据使能

    .hist_hsync             (),  //hist行同歿
    .hist_vsync             (),  //hist场同歿
    .hist_data              (VGA_data[15:8]     ),  //hist数据
    .hist_de                ()   //hist数据使能
);

hist_equalization
#(
    .H_DISP                 (H_DISP             ),  //图像宽度
    .V_DISP                 (V_DISP             )   //图像高度
)
u_hist_equalization_B
(
    .clk                    (clk                ),
    .rst_n                  (rst_n              ),
    .Y_hsync                (RGB_hsync          ),  //Y分量行同歿
    .Y_vsync                (RGB_vsync          ),  //Y分量场同歿
    .Y_data                 (RGB_data[7:0]      ),  //Y分量数据
    .Y_de                   (RGB_de             ),  //Y分量数据使能

    .hist_hsync             (),  //hist行同歿
    .hist_vsync             (),  //hist场同歿
    .hist_data              (VGA_data[7:0]      ),  //hist数据
    .hist_de                ()   //hist数据使能
);

endmodule