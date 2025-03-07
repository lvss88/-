//**************************************************************************
// *** ���� : matrix_3x3.v
// *** ���� : xianyu_FPGA
// *** ���� : https://www.cnblogs.com/xianyufpga/
// *** ���� : 2020��3��
// *** ���� : 3x3���󣬱߽�������ظ��ƣ����֧��1024x1024���ķ�1clk
//**************************************************************************

module matrix_3x3_16bit
//========================< ���� >==========================================
#(
parameter COL               = 11'd10                , //ͼƬ����
parameter ROW               = 11'd5                   //ͼƬ�߶�
)
//========================< �˿� >==========================================
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
//========================< �ź� >==========================================
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
//==    FIFO������showģʽ�����Ϊ�����������ݸ���
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
//==    ���л���
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
//==    fifo ��д�ź�
//==========================================================================
assign wr_en_1 = (cnt_row < ROW - 11'd1) ? din_vld : 1'd0; //��д���1��
assign rd_en_1 = (cnt_row > 11'd0      ) ? din_vld : 1'd0; //�ӵ�1�п�ʼ��
assign wr_en_2 = (cnt_row < ROW - 11'd2) ? din_vld : 1'd0; //��д���2��
assign rd_en_2 = (cnt_row > 11'd1      ) ? din_vld : 1'd0; //�ӵ�2�п�ʼ��
//==========================================================================
//==    �γ� 3x3 ���󣬱߽�������ظ���
//==========================================================================
//��������ѡȡ
//---------------------------------------------------
assign row_1 = q_2;
assign row_2 = q_1;
assign row_3 = din;

//�����γɾ���1clk
//---------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        {matrix_11, matrix_12, matrix_13} <= {'d0, 'd0, 'd0};
        {matrix_21, matrix_22, matrix_23} <= {'d0, 'd0, 'd0};
        {matrix_31, matrix_32, matrix_33} <= {'d0, 'd0, 'd0};
    end
    //------------------------------------------------------------------------- ��1�ž���
    else if(cnt_row == 11'd0) begin
        if(cnt_col == 11'd0) begin          //��1������
            {matrix_11, matrix_12, matrix_13} <= {row_3, row_3, row_3};
            {matrix_21, matrix_22, matrix_23} <= {row_3, row_3, row_3};
            {matrix_31, matrix_32, matrix_33} <= {row_3, row_3, row_3};
        end
        else begin                          //ʣ�����
            {matrix_11, matrix_12, matrix_13} <= {matrix_12, matrix_13, row_3};
            {matrix_21, matrix_22, matrix_23} <= {matrix_22, matrix_23, row_3};
            {matrix_31, matrix_32, matrix_33} <= {matrix_32, matrix_33, row_3};
        end
    end
    //------------------------------------------------------------------------- ��2�ž���
    else if(cnt_row == 11'd1) begin
        if(cnt_col == 11'd0) begin          //��1������
            {matrix_11, matrix_12, matrix_13} <= {row_2, row_2, row_2};
            {matrix_21, matrix_22, matrix_23} <= {row_2, row_2, row_2};
            {matrix_31, matrix_32, matrix_33} <= {row_3, row_3, row_3};
        end
        else begin                          //ʣ�����
            {matrix_11, matrix_12, matrix_13} <= {matrix_12, matrix_13, row_2};
            {matrix_21, matrix_22, matrix_23} <= {matrix_22, matrix_23, row_2};
            {matrix_31, matrix_32, matrix_33} <= {matrix_32, matrix_33, row_3};
        end
    end
    //------------------------------------------------------------------------- ʣ�����
    else begin
        if(cnt_col == 11'd0) begin          //��1������
            {matrix_11, matrix_12, matrix_13} <= {row_1, row_1, row_1};
            {matrix_21, matrix_22, matrix_23} <= {row_2, row_2, row_2};
            {matrix_31, matrix_32, matrix_33} <= {row_3, row_3, row_3};
        end
        else begin                          //ʣ�����
            {matrix_11, matrix_12, matrix_13} <= {matrix_12, matrix_13, row_1};
            {matrix_21, matrix_22, matrix_23} <= {matrix_22, matrix_23, row_2};
            {matrix_31, matrix_32, matrix_33} <= {matrix_32, matrix_33, row_3};
        end
    end
end



endmodule