`timescale 1 ns/1 ns

module top_r
#(
    parameter               H_DISP = 1024        ,   //ͼ����
    parameter               V_DISP = 768            //ͼ��߶�
)
(
    input   wire            clk                 ,
    input   wire            rst_n               ,
    input   wire            RGB_hsync           ,   //������������ͬ��
    input   wire            RGB_vsync           ,   //���������ݳ�ͬ��
    input   wire    [23:0]  RGB_data            ,   //����������
    input   wire            RGB_de              ,   //����������ʹ�v

    output  wire            VGA_hsync           ,   //VGA��ͬ�{
    output  wire            VGA_vsync           ,   //VGA��ͬ�{
    output  wire    [23:0]  VGA_data            ,   //VGA����
    output  wire            VGA_de                  //VGA����ʹ��

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




//    wire                    img_hsync           ;   //������������ͬ��
//    wire                    img_vsync           ;   //���������ݳ�ͬ��
//    wire    [23:0]          img_data            ;   //����������
//    wire    [7:0]           img_data_R          ;   //����������R����
//    wire    [7:0]           img_data_G          ;   //����������G����
//    wire    [7:0]           img_data_B          ;   //����������B����
//    wire                    img_de              ;   //����������ʹ�v
    
//    wire    [7:0]           VGA_data_R          ;   //����������R����
//    wire    [7:0]           VGA_data_G          ;   //����������G����
//    wire    [7:0]           VGA_data_B          ;   //����������B����

//    wire                    YCbCr_hsync         ;   //������������ͬ��
//    wire                    YCbCr_vsync         ;   //���������ݳ�ͬ��
//    wire    [23:0]          YCbCr_data          ;   //����������B����
//    wire                    YCbCr_de            ;   //����������ʹ�v

//    wire    [7:0]           Y_data              ;   //Y��������

//    wire                    hist_hsync          ;   //hist��ͬ�{
//    wire                    hist_vsync          ;   //hist��ͬ�{
//    wire    [7:0]           hist_data           ;   //hist����
//    wire                    hist_de             ;   //hist����ʹ��

//assign VGA_data = {VGA_data_R,VGA_data_G,VGA_data_B};
//assign VGA_data = {hist_data,hist_data,hist_data};
//assign VGA_data = {YCbCr_data[23:16],YCbCr_data[23:16],YCbCr_data[23:16]};
//assign Y_data = YCbCr_data[23:16];

//img_gen
//#(
//    .H_DISP                 (H_DISP             ),  //ͼ����
//    .V_DISP                 (V_DISP             )   //ͼ��߶�
//)
//u_img_gen
//(
//    .clk                    (clk                ),  //ʱ��
//    .rst_n                  (rst_n              ),  //��λ
//
//    .img_hsync              (img_hsync          ),  //img��ͬ�{
//    .img_vsync              (img_vsync          ),  //img��ͬ�{
//    .img_data               (img_data           ),  //img����
//    .img_de                 (img_de             )   //img����ʹ��
//);

//rgb2ycbcr u_rgb2ycbcr
//(
//    .clk                    (clk                ),
//    .rst_n                  (rst_n              ),
//    .RGB_hsync              (img_hsync          ),   //RGB��ͬ�{
//    .RGB_vsync              (img_vsync          ),   //RGB��ͬ�{
//    .RGB_data               (img_data           ),   //RGB����
//    .RGB_de                 (img_de             ),   //RGB����ʹ��
//
//    .YCbCr_hsync            (VGA_hsync          ),   //YCbCr��ͬ�{
//    .YCbCr_vsync            (VGA_vsync          ),   //YCbCr��ͬ�{
//    .YCbCr_data             (VGA_data           ),   //YCbCr����
//    .YCbCr_de               (VGA_de             )    //YCbCr����ʹ��
//);

////  �ź�ͬ��
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
    .H_DISP                 (H_DISP             ),  //ͼ����
    .V_DISP                 (V_DISP             )   //ͼ��߶�
)
u_hist_equalization_R
(
    .clk                    (clk                ),
    .rst_n                  (rst_n              ),
    .Y_hsync                (RGB_hsync          ),  //Y������ͬ�{
    .Y_vsync                (RGB_vsync          ),  //Y������ͬ�{
    .Y_data                 (RGB_data[23:16]    ),  //Y��������
    .Y_de                   (RGB_de             ),  //Y��������ʹ��

    .hist_hsync             (VGA_hsync          ),  //hist��ͬ�{
    .hist_vsync             (VGA_vsync          ),  //hist��ͬ�{
    .hist_data              (VGA_data[23:16]    ),  //hist����
    .hist_de                (VGA_de             )   //hist����ʹ��
);

hist_equalization
#(
    .H_DISP                 (H_DISP             ),  //ͼ����
    .V_DISP                 (V_DISP             )   //ͼ��߶�
)
u_hist_equalization_G
(
    .clk                    (clk                ),
    .rst_n                  (rst_n              ),
    .Y_hsync                (RGB_hsync          ),  //Y������ͬ�{
    .Y_vsync                (RGB_vsync          ),  //Y������ͬ�{
    .Y_data                 (RGB_data[15:8]     ),  //Y��������
    .Y_de                   (RGB_de             ),  //Y��������ʹ��

    .hist_hsync             (),  //hist��ͬ�{
    .hist_vsync             (),  //hist��ͬ�{
    .hist_data              (VGA_data[15:8]     ),  //hist����
    .hist_de                ()   //hist����ʹ��
);

hist_equalization
#(
    .H_DISP                 (H_DISP             ),  //ͼ����
    .V_DISP                 (V_DISP             )   //ͼ��߶�
)
u_hist_equalization_B
(
    .clk                    (clk                ),
    .rst_n                  (rst_n              ),
    .Y_hsync                (RGB_hsync          ),  //Y������ͬ�{
    .Y_vsync                (RGB_vsync          ),  //Y������ͬ�{
    .Y_data                 (RGB_data[7:0]      ),  //Y��������
    .Y_de                   (RGB_de             ),  //Y��������ʹ��

    .hist_hsync             (),  //hist��ͬ�{
    .hist_vsync             (),  //hist��ͬ�{
    .hist_data              (VGA_data[7:0]      ),  //hist����
    .hist_de                ()   //hist����ʹ��
);

endmodule