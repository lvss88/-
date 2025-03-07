//**************************************************************************
// *** ���� : Erode.v
// *** ���� : ����FPGA
// *** ���� : https://www.cnblogs.com/xianyufpga/
// *** ���� : 2020��3��
// *** ���� : Erode��ʴ�����������Ϊ��ֵͼ��
//**************************************************************************

module Erode
//========================< �˿� >==========================================
(
input   wire                clk                     ,
input   wire                rst_n                   ,
//input ---------------------------------------------
input   wire                RGB_de                  ,
input   wire                RGB_hsync               ,
input   wire                RGB_vsync               ,
input   wire    [23:0]      RGB_data                ,
//output --------------------------------------------
output  wire                erode_de                ,
output  wire                erode_hsync             ,
output  wire                erode_vsync             ,
output  wire    [23:0]      erode_data
);
//========================< �ź� >==========================================
//matrix_3x3 ----------------------------------------
wire    [23:0]              matrix_11               ;
wire    [23:0]              matrix_12               ;
wire    [23:0]              matrix_13               ;
wire    [23:0]              matrix_21               ;
wire    [23:0]              matrix_22               ;
wire    [23:0]              matrix_23               ;
wire    [23:0]              matrix_31               ;
wire    [23:0]              matrix_32               ;
wire    [23:0]              matrix_33               ;
//erode ---------------------------------------------
reg                         erode_1                 ;
reg                         erode_2                 ;
reg                         erode_3                 ;
reg                         erode                   ;
//ͬ�� ----------------------------------------------
reg     [ 2:0]              RGB_de_r                ;
reg     [ 2:0]              RGB_hsync_r             ;
reg     [ 2:0]              RGB_vsync_r             ;
//==========================================================================
//==    matrix_3x3_16bit������3x3���������ʹ������룬�ķ�1clk
//==========================================================================
//--------------------------------------------------- ����˳��
//        {matrix_11, matrix_12, matrix_13}
//        {matrix_21, matrix_22, matrix_23}
//        {matrix_31, matrix_32, matrix_33}
//--------------------------------------------------- ģ������
matrix_3x3_16bit
#(
    .COL                    (1024                   ),
    .ROW                    (768                    )
)
u_matrix_3x3_16bit
(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .din_vld                (RGB_de                 ),
    .din                    (RGB_data               ),
    .matrix_11              (matrix_11              ),
    .matrix_12              (matrix_12              ),
    .matrix_13              (matrix_13              ),
    .matrix_21              (matrix_21              ),
    .matrix_22              (matrix_22              ),
    .matrix_23              (matrix_23              ),
    .matrix_31              (matrix_31              ),
    .matrix_32              (matrix_32              ),
    .matrix_33              (matrix_33              )
);
//==========================================================================
//==    ��ʴ���ķ�2clk
//==========================================================================
//clk1�����и�������
//---------------------------------------------------
always @ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        erode_1 <= 'd0;
        erode_2 <= 'd0;
        erode_3 <= 'd0;
    end
    else begin
        erode_1 <= matrix_11 && matrix_12 && matrix_13;
        erode_2 <= matrix_21 && matrix_22 && matrix_23;
        erode_3 <= matrix_31 && matrix_32 && matrix_33;
    end
end

//clk2��ȫ������
//---------------------------------------------------
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        erode <= 'd0;
    end
    else begin
        erode <= erode_1 && erode_2 && erode_3;
    end
end
//==========================================================================
//==    ��ʴ�������
//==========================================================================
assign erode_data = erode ? 'hffff : 'h0000;

//==========================================================================
//==    �ź�ͬ��
//==========================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        RGB_de_r    <= 3'b0;
        RGB_hsync_r <= 3'b0;
        RGB_vsync_r <= 3'b0;
    end
    else begin  
        RGB_de_r    <= {RGB_de_r[1:0],    RGB_de};
        RGB_hsync_r <= {RGB_hsync_r[1:0], RGB_hsync};
        RGB_vsync_r <= {RGB_vsync_r[1:0], RGB_vsync};
    end
end

assign erode_de    = RGB_de_r[2];
assign erode_hsync = RGB_hsync_r[2];
assign erode_vsync = RGB_vsync_r[2];
    


endmodule