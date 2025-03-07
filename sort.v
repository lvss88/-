//**************************************************************************
// *** ���� : sort.v
// *** ���� : xianyu_FPGA
// *** ���� : https://www.cnblogs.com/xianyufpga/
// *** ���� : 2020��3��
// *** ���� : ��3�����ݽ������У��ó����ֵ���м�ֵ����Сֵ
//**************************************************************************

module sort
//========================< �˿� >==========================================
(
//system --------------------------------------------
input   wire                clk                     ,
input   wire                rst_n                   ,
//input ---------------------------------------------
input   wire    [23:0]      data1                   ,
input   wire    [23:0]      data2                   ,
input   wire    [23:0]      data3                   ,
//output --------------------------------------------
output  reg     [23:0]      max_data                , //���ֵ
output  reg     [23:0]      mid_data                , //�м�ֵ
output  reg     [23:0]      min_data                  //��Сֵ
);
//==========================================================================
//==    ���ֵ
//==========================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        max_data <= 'd0;
    else if(data1 >= data2 && data1 >= data3) 
        max_data <= data1;
    else if(data2 >= data1 && data2 >= data3)
        max_data <= data2;
    else if(data3 >= data1 && data3 >= data2)
        max_data <= data3;
end
//==========================================================================
//==    �м�ֵ
//==========================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        mid_data <= 'd0;
    else if((data2 >= data1 && data1 >= data3) || (data3 >= data1 && data1 >= data2))
        mid_data <= data1;
    else if((data1 >= data2 && data2 >= data3) || (data3 >= data2 && data2 >= data1))
        mid_data <= data2;
    else if((data1 >= data3 && data3 >= data2) || (data1 >= data3 && data3 >= data2))
        mid_data <= data3;
end
//==========================================================================
//==    ��Сֵ
//==========================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        min_data <= 'd0;
    else if(data3 >= data2 && data2 >= data1)
        min_data <= data1;
    else if(data3 >= data1 && data1 >= data2)
        min_data <= data2;
    else if(data1 >= data2 && data2 >= data3)
        min_data <= data3;
end



endmodule 
