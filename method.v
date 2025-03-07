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
ֱ��ͼ���⻯
****************************************************************************/ 


top_r
#(
    .H_DISP (1024  )      ,   //ͼ����
    .V_DISP (768   )         //ͼ��߶�
)
top_r_tb
(
    .clk(video_clk)                 ,
    .rst_n(rst_n)               ,
    .RGB_hsync(hs)           ,   //������������ͬ��
    .RGB_vsync(vs)           ,   //���������ݳ�ͬ��
    //.RGB_data({vout_data,8'd0})            ,   //����������
    .RGB_data(RGB_data)    ,//�����ɫ���ԣ���ֻ��Ҫ�� data_r �� data_b ����λ�ü���
    .RGB_de(de)              ,   //����������ʹ�v

    .VGA_hsync(VGA_hsync)           ,   //VGA��ͬ�{
    .VGA_vsync(VGA_vsync)           ,   //VGA��ͬ�{
    .VGA_data(VGA_data)            ,   //VGA����
    .VGA_de(VGA_de)                  //VGA����ʹ��

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
��ֵ�˲� 1
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
    //��ֵ�˲� --------------------------------------
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
//output reg [7:0]	 hsv_v, //HSV����
//output [7:0] aa,
//output [7:0] bb
);
/*************************************************************************
��ֵ�˲� 2
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
    //��ֵ�˲� --------------------------------------
    .median_de              (median_de_2              ),
    .median_hsync           (median_hsync_2           ),
    .median_vsync           (median_vsync_2           ),
    .median_data            (median_data_2            )
);
*/
/*************************************************************************
ֱ��ͼͳ�� 1
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
ֱ��ͼͳ�� 2
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
ֱ��ͼͳ�� 1
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
choose--1  ����ʮ��
/****************************************************************************/
choose  tb_1 (
	.clk(video_clk) 		,
	.rst(rst_n)  		,
	.po_histo_vld(po_histo_vld_1) ,
	.po_histo_data(po_histo_data_1) 	,//�����ڶ�ʮ�� [31:0]
    .rd_addr(rd_ram_addr_1),
	.enn(en_1)  
    );
/*************************************************************************
choose--2  ����ʮ��
/****************************************************************************/
choose  tb_2 (
	.clk(video_clk) 		,
	.rst(rst_n)  		,
	.po_histo_vld(po_histo_vld_2) ,
	.po_histo_data(po_histo_data_2) 	,//�����ڶ�ʮ�� [31:0]
    .rd_addr(rd_ram_addr_2),
	.enn(en_2)  
    );
/*************************************************************************
choose--3  ����ʮ��
/****************************************************************************/
choose  tb_3 (
	.clk(video_clk) 		,
	.rst(rst_n)  		,
	.po_histo_vld(po_histo_vld_3) ,
	.po_histo_data(po_histo_data_3) 	,//�����ڶ�ʮ�� [31:0]
    .rd_addr(rd_ram_addr_3),
	.enn(en_3)  
    );

/*************************************************************************
���
/****************************************************************************/
wire    [3:0]    led          ;


led led_tb (
	.clk(video_clk) 		,
	.rst(rst_n) 		    ,
    .en_N(en_1)              ,//ȱ����ʹ��
    .en_P(en_2)        ,//ȱ�׵�ʹ��
    .en_K(en_3)        ,//ȱ�ص�ʹ��  
    .led(led)       

    );
endmodule