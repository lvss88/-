//**************************************************************************
// *** ���� : Median.v
// *** ���� : xianyu_FPGA
// *** ���� : https://www.cnblogs.com/xianyufpga/
// *** ���� : 2020��3��
// *** ���� : Y��������Median��ֵ�˲�
//**************************************************************************

module Median
//========================< �˿� >==========================================
(
input   wire                clk                     ,
input   wire                rst_n                   ,
//input ---------------------------------------------
input   wire                Y_de                    ,
input   wire                Y_hsync                 ,
input   wire                Y_vsync                 ,
input   wire    [23:0]      Y_data                  ,
//output --------------------------------------------
output  wire                median_de               ,
output  wire                median_hsync            ,
output  wire                median_vsync            ,
output  wire    [23:0]      median_data
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
//median --------------------------------------------
wire    [23:0]              max_data1               ;
wire    [23:0]              mid_data1               ;
wire    [23:0]              min_data1               ;
wire    [23:0]              max_data2               ;
wire    [23:0]              mid_data2               ;
wire    [23:0]              min_data2               ;
wire    [23:0]              max_data3               ;
wire    [23:0]              mid_data3               ;
wire    [23:0]              min_data3               ;
wire    [23:0]              max_min_data            ;
wire    [23:0]              mid_mid_data            ;
wire    [23:0]              min_max_data            ;
//ͬ�� ----------------------------------------------
reg     [ 3:0]              Y_de_r                  ;
reg     [ 3:0]              Y_hsync_r               ;
reg     [ 3:0]              Y_vsync_r               ;
//==========================================================================
//==    matrix_3x3_8bit������3x3���������ʹ������룬�ķ�1clk
//==========================================================================
//--------------------------------------------------- ����˳��
//        {matrix_11, matrix_12, matrix_13}
//        {matrix_21, matrix_22, matrix_23}
//        {matrix_31, matrix_32, matrix_33}
//--------------------------------------------------- ģ������
matrix_3x3_16bit
#(
    .COL                    (1024                    ),
    .ROW                    (768                   )
)
u_matrix_3x3_16bit
(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .din_vld                (Y_de                   ),
    .din                    (Y_data                 ),
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
//==    ��ֵ�˲����ķ�3clk
//==========================================================================
//ÿ�����ؽ������У�clk1
//---------------------------------------------------
//��1��
sort u1
(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .data1                  (matrix_11              ), 
    .data2                  (matrix_12              ), 
    .data3                  (matrix_13              ),
    .max_data               (max_data1              ),
    .mid_data               (mid_data1              ),
    .min_data               (min_data1              )
);

//��2��
sort u2
(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .data1                  (matrix_21              ),
    .data2                  (matrix_22              ),
    .data3                  (matrix_23              ),
    .max_data               (max_data2              ),
    .mid_data               (mid_data2              ),
    .min_data               (min_data2              )
);

//��3��
sort u3
(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .data1                  (matrix_31              ),
    .data2                  (matrix_32              ),
    .data3                  (matrix_33              ),
    .max_data               (max_data3              ),
    .mid_data               (mid_data3              ),
    .min_data               (min_data3              )
);

//���е���Сֵȡ���ֵ
//���е��м�ֵȡ�м�ֵ
//���е����ֵȡ��Сֵ��clk2
//---------------------------------------------------
//min-max
sort u4
(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .data1                  (min_data1              ),
    .data2                  (min_data2              ),
    .data3                  (min_data3              ),
    .max_data               (min_max_data           ),
    .mid_data               (                       ),
    .min_data               (                       )
);

//mid-mid
sort u5
(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .data1                  (mid_data1              ),
    .data2                  (mid_data2              ),
    .data3                  (mid_data3              ),
    .max_data               (                       ),
    .mid_data               (mid_mid_data           ),
    .min_data               (                       )
);

//max-min
sort u6
(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .data1                  (max_data1              ), 
    .data2                  (max_data2              ), 
    .data3                  (max_data3              ),
    .max_data               (                       ),
    .mid_data               (                       ),
    .min_data               (max_min_data           )
);

//ǰ�������ֵ��ȡ�м�ֵ��clk3
//---------------------------------------------------
sort u7
(
    .clk                    (clk                    ),
    .rst_n                  (rst_n                  ),
    .data1                  (max_min_data           ),
    .data2                  (mid_mid_data           ), 
    .data3                  (min_max_data           ),
    .max_data               (                       ),
    .mid_data               (median_data            ),
    .min_data               (                       )
);
//==========================================================================
//==    �ź�ͬ��
//==========================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        Y_de_r    <= 4'b0;
        Y_hsync_r <= 4'b0;
        Y_vsync_r <= 4'b0;
    end
    else begin  
        Y_de_r    <= {Y_de_r[2:0],    Y_de};
        Y_hsync_r <= {Y_hsync_r[2:0], Y_hsync};
        Y_vsync_r <= {Y_vsync_r[2:0], Y_vsync};
    end
end

assign median_de    = Y_de_r[3];
assign median_hsync = Y_hsync_r[3];
assign median_vsync = Y_vsync_r[3];
    


endmodule