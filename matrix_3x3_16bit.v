//**************************************************************************
// *** 名称 : matrix_3x3.v
// *** 作者 : xianyu_FPGA
// *** 博客 : https://www.cnblogs.com/xianyufpga/
// *** 日期 : 2020年3月
// *** 描述 : 3x3矩阵，边界采用像素复制，最大支持1024x1024，耗费1clk
//**************************************************************************

module matrix_3x3_16bit
//========================< 参数 >==========================================
#(
parameter COL               = 11'd10                , //图片长度
parameter ROW               = 11'd5                   //图片高度
)
//========================< 端口 >==========================================
(
input   wire                clk                     ,
input   wire                rst_n                   ,
//input ---------------------------------------------
input   wire                din_vld                 ,
input   wire    [23:0]      din                     ,
//output --------------------------------------------
output  reg     [23:0]      matrix_11               ,
output  reg     [23:0]      matrix_12               ,
output  reg     [23:0]      matrix_13               ,
output  reg     [23:0]      matrix_21               ,
output  reg     [23:0]      matrix_22               ,
output  reg     [23:0]      matrix_23               ,
output  reg     [23:0]      matrix_31               ,
output  reg     [23:0]      matrix_32               ,
output  reg     [23:0]      matrix_33                
);
//========================< 信号 >==========================================
reg     [10:0]              cnt_col                 ;
wire                        add_cnt_col             ;
wire                        end_cnt_col             ;
reg     [10:0]              cnt_row                 ;
wire                        add_cnt_row             ;
wire                        end_cnt_row             ;
wire                        wr_en_1                 ;
wire                        wr_en_2                 ;
wire                        rd_en_1                 ;
wire                        rd_en_2                 ;
wire    [23:0]              q_1                     ;
wire    [23:0]              q_2                     ;
wire    [23:0]              row_1                   ;
wire    [23:0]              row_2                   ;
wire    [23:0]              row_3                   ;
//==========================================================================
//==    FIFO例化，show模式，深度为大于两行数据个数
//==========================================================================
fifo_show_2048x16 u1
(
    .clock                  (clk                    ),
    .data                   (din                    ),
    .wrreq                  (wr_en_1                ),
    .rdreq                  (rd_en_1                ),
    .q                      (q_1                    )
);

fifo_show_2048x16 u2
(
    .clock                  (clk                    ),
    .data                   (din                    ),
    .wrreq                  (wr_en_2                ),
    .rdreq                  (rd_en_2                ),
    .q                      (q_2                    )
);
//==========================================================================
//==    行列划分
//==========================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_col <= 11'd0;
    else if(add_cnt_col) begin
        if(end_cnt_col)
            cnt_col <= 11'd0;
        else
            cnt_col <= cnt_col + 11'd1;
    end
end

assign add_cnt_col = din_vld;
assign end_cnt_col = add_cnt_col && cnt_col== COL-11'd1;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_row <= 11'd0;
    else if(add_cnt_row) begin
        if(end_cnt_row)
            cnt_row <= 11'd0;
        else
            cnt_row <= cnt_row + 11'd1;
    end
end

assign add_cnt_row = end_cnt_col;
assign end_cnt_row = add_cnt_row && cnt_row== ROW-11'd1;
//==========================================================================
//==    fifo 读写信号
//==========================================================================
assign wr_en_1 = (cnt_row < ROW - 11'd1) ? din_vld : 1'd0; //不写最后1行
assign rd_en_1 = (cnt_row > 11'd0      ) ? din_vld : 1'd0; //从第1行开始读
assign wr_en_2 = (cnt_row < ROW - 11'd2) ? din_vld : 1'd0; //不写最后2行
assign rd_en_2 = (cnt_row > 11'd1      ) ? din_vld : 1'd0; //从第2行开始读
//==========================================================================
//==    形成 3x3 矩阵，边界采用像素复制
//==========================================================================
//矩阵数据选取
//---------------------------------------------------
assign row_1 = q_2;
assign row_2 = q_1;
assign row_3 = din;

//打拍形成矩阵，1clk
//---------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        {matrix_11, matrix_12, matrix_13} <= {'d0, 'd0, 'd0};
        {matrix_21, matrix_22, matrix_23} <= {'d0, 'd0, 'd0};
        {matrix_31, matrix_32, matrix_33} <= {'d0, 'd0, 'd0};
    end
    //------------------------------------------------------------------------- 第1排矩阵
    else if(cnt_row == 11'd0) begin
        if(cnt_col == 11'd0) begin          //第1个矩阵
            {matrix_11, matrix_12, matrix_13} <= {row_3, row_3, row_3};
            {matrix_21, matrix_22, matrix_23} <= {row_3, row_3, row_3};
            {matrix_31, matrix_32, matrix_33} <= {row_3, row_3, row_3};
        end
        else begin                          //剩余矩阵
            {matrix_11, matrix_12, matrix_13} <= {matrix_12, matrix_13, row_3};
            {matrix_21, matrix_22, matrix_23} <= {matrix_22, matrix_23, row_3};
            {matrix_31, matrix_32, matrix_33} <= {matrix_32, matrix_33, row_3};
        end
    end
    //------------------------------------------------------------------------- 第2排矩阵
    else if(cnt_row == 11'd1) begin
        if(cnt_col == 11'd0) begin          //第1个矩阵
            {matrix_11, matrix_12, matrix_13} <= {row_2, row_2, row_2};
            {matrix_21, matrix_22, matrix_23} <= {row_2, row_2, row_2};
            {matrix_31, matrix_32, matrix_33} <= {row_3, row_3, row_3};
        end
        else begin                          //剩余矩阵
            {matrix_11, matrix_12, matrix_13} <= {matrix_12, matrix_13, row_2};
            {matrix_21, matrix_22, matrix_23} <= {matrix_22, matrix_23, row_2};
            {matrix_31, matrix_32, matrix_33} <= {matrix_32, matrix_33, row_3};
        end
    end
    //------------------------------------------------------------------------- 剩余矩阵
    else begin
        if(cnt_col == 11'd0) begin          //第1个矩阵
            {matrix_11, matrix_12, matrix_13} <= {row_1, row_1, row_1};
            {matrix_21, matrix_22, matrix_23} <= {row_2, row_2, row_2};
            {matrix_31, matrix_32, matrix_33} <= {row_3, row_3, row_3};
        end
        else begin                          //剩余矩阵
            {matrix_11, matrix_12, matrix_13} <= {matrix_12, matrix_13, row_1};
            {matrix_21, matrix_22, matrix_23} <= {matrix_22, matrix_23, row_2};
            {matrix_31, matrix_32, matrix_33} <= {matrix_32, matrix_33, row_3};
        end
    end
end



endmodule