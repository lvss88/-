module method(
input video_clk,
input rst_n,
input hs,
input vs,
input[23:0] RGB_data,
input de,
output [3:0] led,
output face_vsync,
output face_hsync,
output face_de,
output [23:0] face_data
);

/*************************************************************************
直方图均衡化
****************************************************************************/ 


top_r
#(
    .H_DISP (1024  )      ,   //图像宽度
    .V_DISP (768   )         //图像高度
)
top_r_tb
(
    .clk(video_clk)                 ,
    .rst_n(rst_n)               ,
    .RGB_hsync(hs)           ,   //待处理数据行同步
    .RGB_vsync(vs)           ,   //待处理数据场同步
    //.RGB_data({vout_data,8'd0})            ,   //待处理数捿
    .RGB_data(RGB_data)    ,//如果颜色不对，则只需要将 data_r 与 data_b 互换位置即可
    .RGB_de(de)              ,   //待处理数据使胿

    .VGA_hsync(VGA_hsync)           ,   //VGA行同歿
    .VGA_vsync(VGA_vsync)           ,   //VGA场同歿
    .VGA_data(VGA_data)            ,   //VGA数据
    .VGA_de(VGA_de)                  //VGA数据使能

);


/*************************************************************************
Convert video data to YCBCR
****************************************************************************/ 
/*************************************************************************
YCBCR to sobel algorithm
****************************************************************************/ 
/*sobel sobel_m0
(
.rst                            (~rst_n                   ),
.pclk                           (video_clk                ),
.threshold                      (8'd40                    ),
.ycbcr_hs                       (ycbcr_hs                 ),
.ycbcr_vs                       (ycbcr_vs                 ),
.ycbcr_de                       (ycbcr_de                 ),
.data_in                        (ycbcr_y                  ),
.data_out                       (sobel_out                ),
.sobel_hs                       (sobel_hs                 ),
.sobel_vs                       (sobel_vs                 ),
.sobel_de                       (sobel_de                 )
);*/
/*************************************************************************
中值滤波 1
****************************************************************************/ 

wire                        median_de_1               ;
wire                        median_hsync_1            ;
wire                        median_vsync_1            ;
wire    [23:0]              median_data_1             ;

Median u_Median
(
    .clk                    (video_clk                    ),
    .rst_n                  (rst_n                  ),
    //-----------------------------------------------
    .Y_de                   (VGA_de               ),
    .Y_hsync                (VGA_hsync             ),
    .Y_vsync                (VGA_vsync             ),
    .Y_data                 (VGA_data              ), 
    //中值滤波 --------------------------------------
    .median_de              (median_de_1              ),
    .median_hsync           (median_hsync_1           ),
    .median_vsync           (median_vsync_1           ),
    .median_data            (median_data_1            )
);

/*************************************************************************
hsv
/****************************************************************************/
wire [7:0] hsv_h_1;
wire [7:0] hsv_h_2;
wire [7:0] hsv_h_3;
rgbhsv  rgbhsv_tb(
.clk(video_clk),
.rst_n(rst_n),
.RGB_vsync(median_vsync_1),
.RGB_hsync(median_hsync_1),
.RGB_de(median_de_1),
.RGB_data(median_data_1), 
.face_vsync(face_vsync),
.face_hsync(face_hsync),
.face_de(face_de),
.face_data(face_data),
.hsv_h_1(hsv_h_1),
.hsv_h_2(hsv_h_2),
.hsv_h_3(hsv_h_3)
//output reg [7:0]	 hsv_v, //HSV数据
//output [7:0] aa,
//output [7:0] bb
);
/*************************************************************************
中值滤波 2
****************************************************************************/ 
/*
wire                        median_de_2               ;
wire                        median_hsync_2            ;
wire                        median_vsync_2            ;
wire    [23:0]              median_data_2             ;

Median u_Median_2
(
    .clk                    (video_clk                    ),
    .rst_n                  (rst_n                  ),
    //-----------------------------------------------
    .Y_de                   (face_de               ),
    .Y_hsync                (face_hsync             ),
    .Y_vsync                (face_vsync             ),
    .Y_data                 (face_data              ), 
    //中值滤波 --------------------------------------
    .median_de              (median_de_2              ),
    .median_hsync           (median_hsync_2           ),
    .median_vsync           (median_vsync_2           ),
    .median_data            (median_data_2            )
);
*/
/*************************************************************************
直方图统计 1
****************************************************************************/ 
wire 	[63:0]	po_histo_data_1;
wire  	[7:0]	rd_ram_addr_1;
calculate_histogram  calculate_histogram_1   (
	.clk(video_clk) 		,
	.rst(~rst_n) 		,
	.pi_hsync(face_hsync)	,
	.pi_vsync(face_vsync)	,
	.pi_data_vld(face_de)	,
	.pi_data(hsv_h_1) 	,//[7:0]

	.po_histo_vld(po_histo_vld_1),
	.po_histo_data(po_histo_data_1),
	.rd_ram_addr(rd_ram_addr_1)
				
    );
/*************************************************************************
直方图统计 2
****************************************************************************/ 
wire 	[63:0]	po_histo_data_2;
wire  	[7:0]	rd_ram_addr_2;
calculate_histogram  calculate_histogram_2 (
	.clk(video_clk) 		,
	.rst(~rst_n) 		,
	.pi_hsync(face_hsync)	,
	.pi_vsync(face_vsync)	,
	.pi_data_vld(face_de)	,
	.pi_data(hsv_h_2) 	,//[7:0]

	.po_histo_vld(po_histo_vld_2),
	.po_histo_data(po_histo_data_2),
	.rd_ram_addr(rd_ram_addr_2)
				
    );
/*************************************************************************
直方图统计 1
****************************************************************************/ 
wire 	[63:0]	po_histo_data_3;
wire  	[7:0]	rd_ram_addr_3;
calculate_histogram   calculate_histogram_3 (
	.clk(video_clk) 		,
	.rst(~rst_n) 		,
	.pi_hsync(face_hsync)	,
	.pi_vsync(face_vsync)	,
	.pi_data_vld(face_de)	,
	.pi_data(hsv_h_3) 	,//[7:0]

	.po_histo_vld(po_histo_vld_3),
	.po_histo_data(po_histo_data_3),
	.rd_ram_addr(rd_ram_addr_3)	
    );
/*************************************************************************
choose--1  最大的十个
/****************************************************************************/
choose  tb_1 (
	.clk(video_clk) 		,
	.rst(rst_n)  		,
	.po_histo_vld(po_histo_vld_1) ,
	.po_histo_data(po_histo_data_1) 	,//控制在二十个 [31:0]
    .rd_addr(rd_ram_addr_1),
	.enn(en_1)  
    );
/*************************************************************************
choose--2  最大的十个
/****************************************************************************/
choose  tb_2 (
	.clk(video_clk) 		,
	.rst(rst_n)  		,
	.po_histo_vld(po_histo_vld_2) ,
	.po_histo_data(po_histo_data_2) 	,//控制在二十个 [31:0]
    .rd_addr(rd_ram_addr_2),
	.enn(en_2)  
    );
/*************************************************************************
choose--3  最大的十个
/****************************************************************************/
choose  tb_3 (
	.clk(video_clk) 		,
	.rst(rst_n)  		,
	.po_histo_vld(po_histo_vld_3) ,
	.po_histo_data(po_histo_data_3) 	,//控制在二十个 [31:0]
    .rd_addr(rd_ram_addr_3),
	.enn(en_3)  
    );

/*************************************************************************
点灯
/****************************************************************************/
wire    [3:0]    led          ;


led led_tb (
	.clk(video_clk) 		,
	.rst(rst_n) 		    ,
    .en_N(en_1)              ,//缺氮的使能
    .en_P(en_2)        ,//缺磷的使能
    .en_K(en_3)        ,//缺钾的使能  
    .led(led)       

    );
endmodule