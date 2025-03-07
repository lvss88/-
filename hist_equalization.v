module hist_equalization

#(
    parameter H_DISP            = 12'd1024          ,   //ͼ����
    parameter V_DISP            = 12'd768               //ͼ��߶�
)
(
    input   wire                clk                 ,
    input   wire                rst_n               ,
    input   wire                Y_hsync             ,   //Y������ͬ�{
    input   wire                Y_vsync             ,   //Y������ͬ�{
    input   wire    [ 7:0]      Y_data              ,   //Y��������
    input   wire                Y_de                ,   //Y��������ʹ��

    output  reg                 hist_hsync          ,   //hist��ͬ�{
    output  reg                 hist_vsync          ,   //hist��ͬ�{
    output  wire    [ 7:0]      hist_data           ,   //hist����
    output  reg                 hist_de                 //hist����ʹ��
);

    reg                         Y_vsync_r           ;
    reg                         Y_hsync_r           ;
    reg     [ 7:0]              Y_data_r            ;
    reg                         Y_de_r              ;
    wire                        hist_cnt_yes        ;
    wire                        hist_cnt_not        ;
    reg     [63:0]              hist_cnt            ;
    //  ram1 
    wire                        wr_en_1             ;
    wire    [63:0]              wr_data_1           ;
    wire    [ 7:0]              wr_addr_1           ;
    wire    [ 7:0]              rd_addr_1           ;
    wire    [63:0]              rd_data_1           ;
    //  ram2 
    wire                        wr_en_2             ;
    wire    [63:0]              wr_data_2           ;
    wire    [ 7:0]              wr_addr_2           ;
    wire    [ 7:0]              rd_addr_2           ;
    wire    [63:0]              rd_data_2           ;
    //  ram2 
    wire                        Y_vsync_stop        ;
    reg     [ 7:0]              addr_cnt            ;
    reg     [ 7:0]              addr_cnt_r1         ;
    reg     [ 7:0]              addr_cnt_r2         ;
    reg     [ 7:0]              addr_cnt_r3         ;
    reg     [ 7:0]              addr_cnt_r4         ;
    reg                         addr_flag           ;
    reg                         addr_flag_r1        ;
    reg                         addr_flag_r2        ;
    reg                         addr_flag_r3        ;
    reg                         addr_flag_r4        ;
    reg     [63:0]              sum                 ;
    
    reg     [63:0]              step_1              ;
    reg     [ 7:0]              step_2              ;

always @(posedge clk) begin
    Y_vsync_r   <= Y_vsync;
    Y_hsync_r   <= Y_hsync;
    Y_data_r    <= Y_data;
    Y_de_r      <= Y_de;
end

//  ǰһ֡��ֱ��ͼ�Ҷ�ͳ��
//����ǰ���Ľ��б��{
assign hist_cnt_yes = Y_de_r && Y_data_r == Y_data; //��ȣ���������
assign hist_cnt_not = Y_de_r && Y_data_r != Y_data; //���ȣ�ֻ��һد

//  �Ҷȼ���
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        hist_cnt <= 64'b1;
    end
    else if(hist_cnt_not) begin
        hist_cnt <= 64'b1;
    end
    else if(hist_cnt_yes) begin
        hist_cnt <= hist_cnt + 1'b1;
    end
    else begin
        hist_cnt <= 64'b0;
    end
end

//ͳ�ƽ�����뵽ͳ�� ram1 د
//ǰһ֡���WҪд�룬֡��϶��ram1����ͳ��ֵ����د�Ķ�ram1��0
assign wr_en_1   = Y_vsync ? hist_cnt_not : addr_flag_r1;

//ǰһ֡���WҪд�룬֡��϶��ram1����ͳ��ֵ����د�Ķ�ram1��0
assign wr_addr_1 = Y_vsync ? Y_data_r : addr_cnt_r1;

//ǰһ֡���WҪд�룬֡��϶��ram1����ͳ��ֵ����د�Ķ�ram1��0
assign wr_data_1 = Y_vsync ? rd_data_1 + hist_cnt : 0;

 //ǰһ֡�����ص�ַ�����֡��϶��˳�����ͳ�ƽ�������ں���ļƹ�
assign rd_addr_1 = Y_vsync ? Y_data : addr_cnt;

//˫��ram���洢ͳ�ƽᖨ
//ram_64x256 u_ram_1
//(
//    .clock                  (clk                ),
//    .wren                   (wr_en_1            ),
//    .wraddress              (wr_addr_1          ),
//    .data                   (wr_data_1          ),
//    .rdaddress              (rd_addr_1          ),
//    .q                      (rd_data_1          )
//);

ram_64_256 u_ram_1 
(
    .clka       (clk            ),    // input wire clka
    .wea        (wr_en_1        ),      // input wire [0 : 0] wea
    .addra      (wr_addr_1      ),  // input wire [7 : 0] addra
    .dina       (wr_data_1      ),    // input wire [63 : 0] dina
    .clkb       (clk            ),    // input wire clkb
    .addrb      (rd_addr_1      ),  // input wire [7 : 0] addrb
    .doutb      (rd_data_1      )  // output wire [63 : 0] doutb
);


//  ֡��϶��ͳ������˳��������������ۼӺͣ��ķ�1clk
//  ����256�£����㽫ram1�н����˳�����
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        addr_cnt <= 8'b0;
    end
    else if(addr_flag) begin
        addr_cnt <= addr_cnt + 1'b1;
    end
    else begin
        addr_cnt <= 8'b0;
    end
end

//֡�������
assign Y_vsync_stop  = ~Y_vsync && Y_vsync_r;

//��������
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        addr_flag <= 1'b0;
    end
    else if(Y_vsync_stop) begin         //֡����������
        addr_flag <= 1'b1;
    end
    else if(addr_cnt == 8'd255) begin   //����256���ߵ�ƽ
        addr_flag <= 1'b0;
    end
end

//  ���ģ������õõ�
always @(posedge clk) begin
    addr_cnt_r1 <= addr_cnt;
    addr_cnt_r2 <= addr_cnt_r1;
    addr_cnt_r3 <= addr_cnt_r2;
    addr_cnt_r4 <= addr_cnt_r3;
    
    addr_flag_r1 <= addr_flag;
    addr_flag_r2 <= addr_flag_r1;
    addr_flag_r3 <= addr_flag_r2;
    addr_flag_r4 <= addr_flag_r3;
end

//  �ۼӺͣ��ӿ�ʼ�������ޙ2clk
//  ����addr_cnt����1�Ĳų�rd_data_1���൱����ޙ1clk����֮�������addr_flag_r1
//  �ۼӺ͵ļ�����ވ��1clk
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sum <= 64'b0;
    end
    else if(addr_flag_r1) begin
        sum <= sum + rd_data_1;
    end
    else begin
        sum <= 64'b0;
    end
end

//  ֡��϶����ͺ���о��⻯���㣺sum * 255 / (640*480)
//  ����sum*255
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        step_1 <=  64'd0;
    end
    else if(addr_flag_r2) begin
        step_1 <= sum * 255;
    end
end

//  ���Էֱ�x
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        step_2 <=  8'd0;
    end
    else if(addr_flag_r3) begin
        step_2 <= step_1 / (H_DISP*V_DISP);
    end
end

//  ֱ��ͼ���⻯���ͼ�����
assign wr_en_2   = addr_flag_r4;
assign wr_addr_2 = addr_cnt_r4;
assign wr_data_2 = step_2;

assign rd_addr_2 = Y_data;

//  �洢�����������ڵڶ�֡��ӳ������
//ram_64x256 u_ram_2
//(
//    .clock                  (clk                ),
//    .wren                   (wr_en_2            ),  //дʹ�v
//    .wraddress              (wr_addr_2          ),  //˳���ַ
//    .data                   (wr_data_2          ),  //���⻯�ᖨ
//    .rdaddress              (rd_addr_2          ),
//    .q                      (rd_data_2          )
//);
ram_64_256 u_ram_2 
(
    .clka       (clk            ),    // input wire clka
    .wea        (wr_en_2        ),      // input wire [0 : 0] wea
    .addra      (wr_addr_2      ),  // input wire [7 : 0] addra
    .dina       (wr_data_2      ),    // input wire [63 : 0] dina
    .clkb       (clk            ),    // input wire clkb
    .addrb      (rd_addr_2      ),  // input wire [7 : 0] addrb
    .doutb      (rd_data_2      )  // output wire [63 : 0] doutb
);

//  �õ����⻯�ᖨ
assign hist_data = rd_data_2;

//  ��ram����
always @(posedge clk) begin
    hist_vsync <= Y_vsync;
    hist_hsync <= Y_hsync;
    hist_de    <= Y_de;
end

endmodule