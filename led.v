module led(
	input 	wire 			clk 		,
	input	wire 			rst 		,
    input   wire            en_N        ,//ȱ����ʹ��
    input   wire            en_P        ,//ȱ�׵�ʹ��
    input   wire            en_K        ,//ȱ�ص�ʹ��  
    output  reg   [3:0]     led

    );

always@(posedge clk or negedge rst )begin
if(~rst)
led<='b0000;
else if(en_K&&en_P&&en_N)
led<='b0111;
else if(en_N&&en_P)
led<='b0110;
else if(en_N&&en_K)
led<='b0101;
else if(en_K&&en_P)
led<='b0011;
else if(en_N)
led<='b0100;
else if(en_P)
led<='b0010;
else if(en_K)
led<='b0001;
else 
led<='b1111;
end



endmodule



