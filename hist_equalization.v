module hist_equalization

#(
    parameter H_DISP            = 12'd1024          ,   //图像宽度
    parameter V_DISP            = 12'd768               //图像高度
)
(
    input   wire                clk                 ,
    input   wire                rst_n               ,
    input   wire                Y_hsync             ,   //Y分量行同歿
    input   wire                Y_vsync             ,   //Y分量场同歿
    input   wire    [ 7:0]      Y_data              ,   //Y分量数据
    input   wire                Y_de                ,   //Y分量数据使能

    output  reg                 hist_hsync          ,   //hist行同歿
    output  reg                 hist_vsync          ,   //hist场同歿
    output  wire    [ 7:0]      hist_data           ,   //hist数据
    output  reg                 hist_de                 //hist数据使能
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

//  前一帧：直方图灰度统访
//数据前后拍进行比辿
assign hist_cnt_yes = Y_de_r && Y_data_r == Y_data; //相等，可以相势
assign hist_cnt_not = Y_de_r && Y_data_r != Y_data; //不等，只是一丿

//  灰度计数
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

//统计结果输入到统访 ram1 丿
//前一帧按霿要写入，帧间隙的ram1读出统计值后，下丿拍对ram1渿0
assign wr_en_1   = Y_vsync ? hist_cnt_not : addr_flag_r1;

//前一帧按霿要写入，帧间隙的ram1读出统计值后，下丿拍对ram1渿0
assign wr_addr_1 = Y_vsync ? Y_data_r : addr_cnt_r1;

//前一帧按霿要写入，帧间隙的ram1读出统计值后，下丿拍对ram1渿0
assign wr_data_1 = Y_vsync ? rd_data_1 + hist_cnt : 0;

 //前一帧按像素地址输出，帧间隙按顺序输出统计结果，用于后面的计箿
assign rd_addr_1 = Y_vsync ? Y_data : addr_cnt;

//双口ram，存储统计结枿
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


//  帧间隙，统计数据顺序输出，并进行累加和，耗费1clk
//  计数256下，方便将ram1中结果按顺序读出
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

//帧结束标忿
assign Y_vsync_stop  = ~Y_vsync && Y_vsync_r;

//辅助计数
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        addr_flag <= 1'b0;
    end
    else if(Y_vsync_stop) begin         //帧结束后拉高
        addr_flag <= 1'b1;
    end
    else if(addr_cnt == 8'd255) begin   //拉高256个高电平
        addr_flag <= 1'b0;
    end
end

//  打拍，后面用得到
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

//  累加和，从开始到结果消迿2clk
//  给出addr_cnt，过1拍才出rd_data_1，相当于消迿1clk，与之对齐的是addr_flag_r1
//  累加和的计算又迗费1clk
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

//  帧间隙，求和后进行均衡化运算：sum * 255 / (640*480)
//  计算sum*255
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        step_1 <=  64'd0;
    end
    else if(addr_flag_r2) begin
        step_1 <= sum * 255;
    end
end

//  除以分辨玿
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        step_2 <=  8'd0;
    end
    else if(addr_flag_r3) begin
        step_2 <= step_1 / (H_DISP*V_DISP);
    end
end

//  直方图均衡化后的图像输出
assign wr_en_2   = addr_flag_r4;
assign wr_addr_2 = addr_cnt_r4;
assign wr_data_2 = step_2;

assign rd_addr_2 = Y_data;

//  存储均衡结果，并在第二帧做映射输凿
//ram_64x256 u_ram_2
//(
//    .clock                  (clk                ),
//    .wren                   (wr_en_2            ),  //写使胿
//    .wraddress              (wr_addr_2          ),  //顺序地址
//    .data                   (wr_data_2          ),  //均衡化结枿
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

//  得到均衡化结枿
assign hist_data = rd_data_2;

//  与ram对齐
always @(posedge clk) begin
    hist_vsync <= Y_vsync;
    hist_hsync <= Y_hsync;
    hist_de    <= Y_de;
end

endmodule