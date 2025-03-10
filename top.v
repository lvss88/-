//////////////////////////////////////////////////////////////////////////////////
//  ov5640     display    sobel                                                //
//                                                                             //
//  Author: lhj                                                                //
//                                                                             //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2019/09/25     meisq          1.0         Original
//*******************************************************************************/
module top
(
input                            key2,                   // camera change
input                            sys_clk_p,              //system clock positive
input                            sys_clk_n,              //system clock negative 
input                            rst_n,                  //reset input，low active
//COMS1
inout                            cmos1_scl,              //cmos i2c clock
inout                            cmos1_sda,              //cmos i2c data
input                            cmos1_vsync,            //cmos vsync
input                            cmos1_href,             //cmos hsync refrence,data valid
input                            cmos1_pclk,             //cmos pxiel clock
input   [9:0]                    cmos1_db,               //cmos data
output                           cmos1_rst_n,            //cmos reset
//COMS2      
inout                            cmos2_scl,              //cmos i2c clock
inout                            cmos2_sda,              //cmos i2c data
input                            cmos2_vsync,            //cmos vsync
input                            cmos2_href,             //cmos hsync refrence,data valid
input                            cmos2_pclk,             //cmos pxiel clock
input   [9:0]                    cmos2_db,               //cmos data
output                           cmos2_rst_n,            //cmos reset
//ddr3
inout [31:0]                     ddr3_dq,                //ddr3 data
inout [3:0]                      ddr3_dqs_n,             //ddr3 dqs negative
inout [3:0]                      ddr3_dqs_p,             //ddr3 dqs positive
// Outputs
output [14:0]                    ddr3_addr,              //ddr3 address
output [2:0]                     ddr3_ba,                //ddr3 bank
output                           ddr3_ras_n,             //ddr3 ras_n
output                           ddr3_cas_n,             //ddr3 cas_n
output                           ddr3_we_n,              //ddr3 write enable
output                           ddr3_reset_n,           //ddr3 reset,
output [0:0]                     ddr3_ck_p,              //ddr3 clock negative
output [0:0]                     ddr3_ck_n,              //ddr3 clock positive
output [0:0]                     ddr3_cke,               //ddr3_cke,
output [0:0]                     ddr3_cs_n,              //ddr3 chip select,
output [3:0]                     ddr3_dm,                //ddr3_dm
output [0:0]                     ddr3_odt,               //ddr3_odt	
	//hdmi output
inout                            hdmi_scl,               //HDMI I2C clock
inout                            hdmi_sda,               //HDMI I2C data

output                           hdmi_nreset_v10,        //9134 reset HDMI reset compatibility for version 1.0 and 1.1
output                           hdmi_nreset,            //9134 reset HDMI reset compatibility for version 1.0 and 1.1
output                           hdmi_out_clk,           //clock for 9134
output                           hdmi_out_hs,            //horizontal synchronization for 9134
output                           hdmi_out_vs,            //vertical synchronization for 9134
output                           hdmi_out_de,            //data valid for 9134
output     [23:0]                hdmi_out_data,//data for 9134
output     [3:0]                 led

          
);
parameter MEM_DATA_BITS          = 64;                  //external memory user interface data width
parameter ADDR_BITS              = 25;                  //external memory user interface address width
parameter BUSRT_BITS             = 10;                  //external memory user interface burst width
wire                             wr_burst_data_req;      // write burst data request       
wire                             wr_burst_finish;        // write burst finish flag
wire                             rd_burst_finish;        //read burst finish flag
wire                             rd_burst_req;           //read burst request
wire                             wr_burst_req;           //write burst request
wire[BUSRT_BITS - 1:0]           rd_burst_len;           //read burst length
wire[BUSRT_BITS - 1:0]           wr_burst_len;           //write burst length
wire[ADDR_BITS - 1:0]            rd_burst_addr;          //read burst address
wire[ADDR_BITS - 1:0]            wr_burst_addr;          //write burst address
wire                             rd_burst_data_valid;    //read burst data valid
wire[MEM_DATA_BITS - 1 : 0]      rd_burst_data;          //read burst data
wire[MEM_DATA_BITS - 1 : 0]      wr_burst_data;          //write burst data
wire                             read_req;               //read request
wire                             read_req_ack;           //read request response  
wire                             read_en;                //read enable
wire[15:0]                       read_data;              //read data
wire                             write_en;               //write enable
wire[15:0]                       write_data;             //write data
wire                             write_req;              //write request
wire                             write_req_ack;          //write request response
wire                             video_clk;              //video pixel clock
wire                             hs;                     //horizontal synchronization
wire                             vs;                     //vertical synchronization
wire                             de;                     //video valid
wire[15:0]                       vout_data;              //video data

wire[15:0]                      cmos_16bit_data;         //camera  data
wire                            cmos_16bit_wr;           //camera  write enable
wire[1:0]                       write_addr_index;        //write address index
wire[1:0]                       read_addr_index;         //write address index

wire                            ui_clk;                  //MIG master clock
wire                            ui_clk_sync_rst;         //MIG master reset
wire                            init_calib_complete;     //MIG initialization omplete
// Master Write Address
wire [3:0]                      s00_axi_awid;
wire [63:0]                     s00_axi_awaddr;
wire [7:0]                      s00_axi_awlen;           // burst length: 0-255
wire [2:0]                      s00_axi_awsize;          // burst size: fixed 2'b011
wire [1:0]                      s00_axi_awburst;         // burst type: fixed 2'b01(incremental burst)
wire                            s00_axi_awlock;          // lock: fixed 2'b00
wire [3:0]                      s00_axi_awcache;         // cache: fiex 2'b0011
wire [2:0]                      s00_axi_awprot;          // protect: fixed 2'b000
wire [3:0]                      s00_axi_awqos;           // qos: fixed 2'b0000
wire [0:0]                      s00_axi_awuser;          // user: fixed 32'd0
wire                            s00_axi_awvalid;
wire                            s00_axi_awready;
// master write data
wire [63:0]                     s00_axi_wdata;
wire [7:0]                      s00_axi_wstrb;
wire                            s00_axi_wlast;
wire [0:0]                      s00_axi_wuser;
wire                            s00_axi_wvalid;
wire                            s00_axi_wready;
// master write response
wire [3:0]                      s00_axi_bid;
wire [1:0]                      s00_axi_bresp;
wire [0:0]                      s00_axi_buser;
wire                            s00_axi_bvalid;
wire                            s00_axi_bready;
// master read address
wire [3:0]                      s00_axi_arid;
wire [63:0]                     s00_axi_araddr;
wire [7:0]                      s00_axi_arlen;
wire [2:0]                      s00_axi_arsize;
wire [1:0]                      s00_axi_arburst;
wire [1:0]                      s00_axi_arlock;
wire [3:0]                      s00_axi_arcache;
wire [2:0]                      s00_axi_arprot;
wire [3:0]                      s00_axi_arqos;
wire [0:0]                      s00_axi_aruser;
wire                            s00_axi_arvalid;
wire                            s00_axi_arready;
// master read data
wire [3:0]                      s00_axi_rid;
wire [63:0]                     s00_axi_rdata;
wire [1:0]                      s00_axi_rresp;
wire                            s00_axi_rlast;
wire [0:0]                      s00_axi_ruser;
wire                            s00_axi_rvalid;
wire                            s00_axi_rready;
wire                            sys_clk;                //single end clock  

wire[9:0]                        hdmi_lut_index;              //look table index
wire[31:0]                       hdmi_lut_data;               //look table data
wire[9:0]                       cmos1_lut_index;         //camera coms1 look up table address
wire[31:0]                      cmos1_lut_data;          //camera coms1 Device address,register address, register data
wire[9:0]                       cmos2_lut_index;         //camera coms2 look up table address
wire[31:0]                      cmos2_lut_data;          //camera coms2 Device address,register address, register data

wire[7:0]                       sobel_out;               //sobel data
wire[7:0]                       ycbcr_y;                 //ycbcr y data
wire                            ycbcr_hs;                //ycbcr horizontal synchronization
wire                            ycbcr_vs;                //ycbcr vertical synchronization
wire                            ycbcr_de;                //ycbcr valid
wire                            sobel_hs;                //sobel horizontal synchronization
wire                            sobel_vs;                //sobel vertical synchronization
wire                            sobel_de;                //sobel valid
wire                            locked;

wire VGA_hsync;
wire VGA_vsync;
wire VGA_de;
wire [23:0] VGA_data;
/*
assign hdmi_out_hs               = VGA_hsync;
assign hdmi_out_vs               = VGA_vsync;
assign hdmi_out_de               = VGA_de;
assign hdmi_out_clk              = video_clk;
assign hdmi_out_data             = VGA_data;
*/
wire [23:0] face_data;
wire [23:0] erode_data;
wire [23:0] median_data_2;
wire [23:0] dilate_data;
assign hdmi_out_hs               = face_hsync;
assign hdmi_out_vs               = face_vsync;
assign hdmi_out_de               = face_de;
assign hdmi_out_clk              = video_clk;
assign hdmi_out_data             = face_data;

assign hdmi_nreset_v10           = locked;    //HDMI reset for version 1.0 
assign hdmi_nreset               = locked;    //HDMI reset for version 1.1 
assign cmos1_rst_n               = 1'b1;
assign cmos2_rst_n               = 1'b1;
assign write_en                  = cmos_16bit_wr;
assign write_data                = {cmos_16bit_data[4:0],cmos_16bit_data[10:5],cmos_16bit_data[15:11]};
/*************************************************************************
generate single end clock
**************************************************************************/
IBUFDS sys_clk_ibufgds
(
.O                              (sys_clk                 ),
.I                              (sys_clk_p               ),
.IB                             (sys_clk_n               )
);
/*************************************************************************
generate 50MHz clock and video pixel clock with xilinx IP
**************************************************************************/
video_pll video_pll_m0
(
.clk_in1                        (sys_clk                  ),
.clk_out1                       (video_clk                ),
.reset                          (1'b0                     ),
.locked                         (locked                   )
);
/*************************************************************************
Configure the register of camera coms1
****************************************************************************/
i2c_config i2c_config_m0
(
.rst                            (~rst_n                   ),
.clk                            (sys_clk                  ),
.clk_div_cnt                    (16'd500                  ),
.i2c_addr_2byte                 (1'b1                     ),
.lut_index                      (cmos1_lut_index          ),
.lut_dev_addr                   (cmos1_lut_data[31:24]    ),
.lut_reg_addr                   (cmos1_lut_data[23:8]     ),
.lut_reg_data                   (cmos1_lut_data[7:0]      ),
.error                          (                         ),
.done                           (                         ),
.i2c_scl                        (cmos1_scl                ),
.i2c_sda                        (cmos1_sda                )
);
/*************************************************************************
look-up table of camera coms1 
****************************************************************************/
lut_ov5640_rgb565_1024_768 lut_ov5640_rgb565_1024_768_m0
(
.lut_index                      (cmos1_lut_index          ),
.lut_data                       (cmos1_lut_data           )
); 

/*************************************************************************
Configure the register of camera coms2
****************************************************************************/
i2c_config i2c_config_m1
(
.rst                            (~rst_n                   ),
.clk                            (sys_clk                  ),
.clk_div_cnt                    (16'd500                  ),
.i2c_addr_2byte                 (1'b1                     ),
.lut_index                      (cmos2_lut_index          ),
.lut_dev_addr                   (cmos2_lut_data[31:24]    ),
.lut_reg_addr                   (cmos2_lut_data[23:8]     ),
.lut_reg_data                   (cmos2_lut_data[7:0]      ),
.error                          (                         ),
.done                           (                         ),
.i2c_scl                        (cmos2_scl                ),
.i2c_sda                        (cmos2_sda                )
);
/*************************************************************************
look-up table of camera coms2 
****************************************************************************/
lut_ov5640_rgb565_1024_768 lut_ov5640_rgb565_1024_768_m1
(
.lut_index                      (cmos2_lut_index          ),
.lut_data                       (cmos2_lut_data           )
);
wire                            cmos_pclk;
wire                            cmos_vsync;
wire                            cmos_href;
wire [9:0]                      cmos_db;
/*************************************************************************
Configure the register of 9011 and 9134
****************************************************************************/
i2c_config i2c_config_m2
(
.rst                            (~locked                  ),
.clk                            (sys_clk                  ),
.clk_div_cnt                    (16'd500                  ),
.i2c_addr_2byte                 (1'b0                     ),
.lut_index                      (hdmi_lut_index           ),
.lut_dev_addr                   (hdmi_lut_data[31:24]     ),
.lut_reg_addr                   (hdmi_lut_data[23:8]      ),
.lut_reg_data                   (hdmi_lut_data[7:0]       ),
.error                          (                         ),
.done                           (                         ),
.i2c_scl                        (hdmi_scl                 ),
.i2c_sda                        (hdmi_sda                 )
);
/*************************************************************************
configure look-up table
****************************************************************************/
lut_hdmi lut_hdmi_m0
(
.lut_index                      (hdmi_lut_index           ),
.lut_data                       (hdmi_lut_data            )
);
/*************************************************************************
Select cmos1 or cmos2 with key2
****************************************************************************/
cmos_select	cmos_select_inst
(
.clk                            (sys_clk                  ),
.reset_n                        (rst_n                    ),	
.key1                           (key2                     ),
.cmos_pclk                      (cmos_pclk                ),
.cmos_vsync                     (cmos_vsync               ),        
.cmos_href                      (cmos_href                ),
.cmos_d                         (cmos_db[9:2]             ),	

.cmos1_pclk                     (cmos1_pclk               ),
.cmos1_vsync                    (cmos1_vsync              ),        
.cmos1_href                     (cmos1_href               ),
.cmos1_d                        (cmos1_db[9:2]            ),
    
.cmos2_pclk                     (cmos2_pclk               ),
.cmos2_vsync                    (cmos2_vsync              ),		
.cmos2_href                     (cmos2_href               ),
.cmos2_d                        (cmos2_db[9:2]            )
);
/*************************************************************************
CMOS sensor 8bit data is converted to 16bit data
****************************************************************************/ 
cmos_8_16bit cmos_8_16bit_m0
(
.rst                            (~rst_n                   ),
.pclk                           (cmos_pclk                ),
.pdata_i                        (cmos_db[9:2]             ),
.de_i                           (cmos_href                ),
.pdata_o                        (cmos_16bit_data          ),
.hblank                         (                         ),
.de_o                           (cmos_16bit_wr            )
);
/*************************************************************************
CMOS sensor writes the request and generates the read and write address index
****************************************************************************/ 
cmos_write_req_gen cmos_write_req_gen_m0
(
.rst                            (~rst_n                   ),
.pclk                           (cmos_pclk                ),
.cmos_vsync                     (cmos_vsync               ),
.write_req                      (write_req                ),
.write_addr_index               (write_addr_index         ),
.read_addr_index                (read_addr_index          ),
.write_req_ack                  (write_req_ack            )
);
/*************************************************************************
The video output timing generator and generate a frame read data request
****************************************************************************/ 
video_timing_data video_timing_data_m0
(
.video_clk                      (video_clk                ),
.rst                            (~rst_n                   ),
.read_req                       (read_req                 ),
.read_req_ack                   (read_req_ack             ),
.read_en                        (read_en                  ),
.read_data                      (read_data                ),
.hs                             (hs                       ),
.vs                             (vs                       ),
.de                             (de                       ),
.vout_data                      (vout_data                )
);
/*************************************************************************
直方图均衡化
****************************************************************************/ 

wire    [7:0]   data_r;
wire    [7:0]   data_g;
wire    [7:0]   data_b;
assign          data_r = {vout_data[4:0],3'd0};
assign          data_g = {vout_data[10:5],2'd0};
assign          data_b = {vout_data[15:11],3'd0};

wire [3:0] led;
method  method_tb(
.video_clk(video_clk),
.rst_n(rst_n),
.hs(hs),
.vs(vs),
.RGB_data({data_b,data_g,data_r}),
.de(de),
.led(led),
.face_vsync(face_vsync),
.face_hsync(face_hsync),
.face_de(face_de),
.face_data(face_data)
);











/*************************************************************************
膨胀处理 
/****************************************************************************/
/*
wire                        dilate_de               ;
wire                        dilate_hsync            ;
wire                        dilate_vsync            ;
//wire    [23:0]              dilate_data             ;

Dilate u_Dilate
(
    .clk                    (video_clk                    ),
    .rst_n                  (rst_n                  ),
    //原图 ------------------------------------------
    .RGB_de                 (median_de_2              ),
    .RGB_hsync              (median_hsync_2            ),
    .RGB_vsync              (median_vsync_2            ),
    .RGB_data               (median_data_2             ),
    //膨胀处理 --------------------------------------
    .dilate_de              (dilate_de              ),
    .dilate_hsync           (dilate_hsync           ),
    .dilate_vsync           (dilate_vsync           ),
    .dilate_data            (dilate_data            )
);
*/
/*************************************************************************
腐蚀处理 
/****************************************************************************/
/*
wire    [23:0]              erode_data             ;

Erode u_Erode
(
    .clk                    (video_clk                     ),
    .rst_n                  (rst_n                  ),
    //原图 ------------------------------------------
    .RGB_de                 (dilate_de              ),
    .RGB_hsync              (dilate_hsync           ),
    .RGB_vsync              (dilate_vsync           ),
    .RGB_data               (dilate_data            ), 
    //腐蚀处理 --------------------------------------
    .erode_de               (erode_de               ),
    .erode_hsync            (erode_hsync            ),
    .erode_vsync            (erode_vsync            ),
    .erode_data             (erode_data             )
);

*/

/*************************************************************************
video frame data read-write control
/****************************************************************************/
frame_read_write frame_read_write_m0
(
.rst                            (~rst_n                    ),
.mem_clk                        (ui_clk                    ),
.rd_burst_req                   (rd_burst_req              ),
.rd_burst_len                   (rd_burst_len              ),
.rd_burst_addr                  (rd_burst_addr             ),
.rd_burst_data_valid            (rd_burst_data_valid       ),
.rd_burst_data                  (rd_burst_data             ),
.rd_burst_finish                (rd_burst_finish           ),
.read_clk                       (video_clk                 ),
.read_req                       (read_req                  ),
.read_req_ack                   (read_req_ack              ),
.read_finish                    (                          ),
.read_addr_0                    (24'd0                     ), //The first frame address is 0
.read_addr_1                    (24'd2073600               ), //The second frame address is 24'd2073600 ,large enough address space for one frame of video
.read_addr_2                    (24'd4147200               ),
.read_addr_3                    (24'd6220800               ),
.read_addr_index                (read_addr_index           ),
.read_len                       (24'd196608                ),//frame size 1024 * 768 * 16 / 64
.read_en                        (read_en                   ),
.read_data                      (read_data                 ),

.wr_burst_req                   (wr_burst_req              ),
.wr_burst_len                   (wr_burst_len              ),
.wr_burst_addr                  (wr_burst_addr             ),
.wr_burst_data_req              (wr_burst_data_req         ),
.wr_burst_data                  (wr_burst_data             ),
.wr_burst_finish                (wr_burst_finish           ),
.write_clk                      (cmos_pclk                 ),
.write_req                      (write_req                 ),
.write_req_ack                  (write_req_ack             ),
.write_finish                   (                          ),
.write_addr_0                   (24'd0                     ),
.write_addr_1                   (24'd2073600               ),
.write_addr_2                   (24'd4147200               ),
.write_addr_3                   (24'd6220800               ),
.write_addr_index               (write_addr_index          ),
.write_len                      (24'd196608                ),//frame size 1024 * 768 * 16 / 64
.write_en                       (write_en                  ),
.write_data                     (write_data                )
);
/*************************************************************************
XILINX MIG IP with AXI bus
****************************************************************************/
ddr3 u_ddr3 
(
// Memory interface ports
.ddr3_addr                      (ddr3_addr                 ), 
.ddr3_ba                        (ddr3_ba                   ), 
.ddr3_cas_n                     (ddr3_cas_n                ), 
.ddr3_ck_n                      (ddr3_ck_n                 ), 
.ddr3_ck_p                      (ddr3_ck_p                 ),
.ddr3_cke                       (ddr3_cke                  ),  
.ddr3_ras_n                     (ddr3_ras_n                ), 
.ddr3_reset_n                   (ddr3_reset_n              ), 
.ddr3_we_n                      (ddr3_we_n                 ),  
.ddr3_dq                        (ddr3_dq                   ),  
.ddr3_dqs_n                     (ddr3_dqs_n                ),  
.ddr3_dqs_p                     (ddr3_dqs_p                ),  
.init_calib_complete            (init_calib_complete       ),  
 
.ddr3_cs_n                      (ddr3_cs_n                 ),  
.ddr3_dm                        (ddr3_dm                   ),  
.ddr3_odt                       (ddr3_odt                  ),  
// Application interface ports
.ui_clk                         (ui_clk                    ), 
.ui_clk_sync_rst                (ui_clk_sync_rst           ),  // output	   ui_clk_sync_rst
.mmcm_locked                    (                          ),  // output	    mmcm_locked
.aresetn                        (1'b1                      ),  // input			aresetn
.app_sr_req                     (1'b0                      ),  // input			app_sr_req
.app_ref_req                    (1'b0                      ),  // input			app_ref_req
.app_zq_req                     (1'b0                      ),  // input			app_zq_req
.app_sr_active                  (                          ),  // output	    app_sr_active
.app_ref_ack                    (                          ),  // output		app_ref_ack
.app_zq_ack                     (                          ),  // output		app_zq_ack
// Slave Interface Write Address Ports
.s_axi_awid                     (s00_axi_awid              ),  // input [0:0]	s_axi_awid
.s_axi_awaddr                   (s00_axi_awaddr            ),  // input [29:0]	s_axi_awaddr
.s_axi_awlen                    (s00_axi_awlen             ),  // input [7:0]	s_axi_awlen
.s_axi_awsize                   (s00_axi_awsize            ),  // input [2:0]	s_axi_awsize
.s_axi_awburst                  (s00_axi_awburst           ),  // input [1:0]	s_axi_awburst
.s_axi_awlock                   (s00_axi_awlock            ),  // input [0:0]	s_axi_awlock
.s_axi_awcache                  (s00_axi_awcache           ),  // input [3:0]	s_axi_awcache
.s_axi_awprot                   (s00_axi_awprot            ),  // input [2:0]	s_axi_awprot
.s_axi_awqos                    (s00_axi_awqos             ),  // input [3:0]	s_axi_awqos
.s_axi_awvalid                  (s00_axi_awvalid           ),  // input			s_axi_awvalid
.s_axi_awready                  (s00_axi_awready           ),  // output	    s_axi_awready
// Slave Interface Write Data Ports
.s_axi_wdata                    (s00_axi_wdata             ),  // input [63:0]	s_axi_wdata
.s_axi_wstrb                    (s00_axi_wstrb             ),  // input [7:0]	s_axi_wstrb
.s_axi_wlast                    (s00_axi_wlast             ),  // input			s_axi_wlast
.s_axi_wvalid                   (s00_axi_wvalid            ),  // input			s_axi_wvalid
.s_axi_wready                   (s00_axi_wready            ),  // output		s_axi_wready
// Slave Interface Write Response Ports
.s_axi_bid                      (s00_axi_bid               ),  // output [0:0]	s_axi_bid
.s_axi_bresp                    (s00_axi_bresp             ),  // output [1:0]	s_axi_bresp
.s_axi_bvalid                   (s00_axi_bvalid            ),  // output		s_axi_bvalid
.s_axi_bready                   (s00_axi_bready            ),  // input			s_axi_bready
// Slave Interface Read Address Ports
.s_axi_arid                     (s00_axi_arid              ),  // input [0:0]	s_axi_arid
.s_axi_araddr                   (s00_axi_araddr            ),  // input [29:0]	s_axi_araddr
.s_axi_arlen                    (s00_axi_arlen             ),  // input [7:0]	s_axi_arlen
.s_axi_arsize                   (s00_axi_arsize            ),  // input [2:0]	s_axi_arsize
.s_axi_arburst                  (s00_axi_arburst           ),  // input [1:0]	s_axi_arburst
.s_axi_arlock                   (s00_axi_arlock            ),  // input [0:0]	s_axi_arlock
.s_axi_arcache                  (s00_axi_arcache           ),  // input [3:0]	s_axi_arcache
.s_axi_arprot                   (s00_axi_arprot            ),  // input [2:0]	s_axi_arprot
.s_axi_arqos                    (s00_axi_arqos             ),  // input [3:0]	s_axi_arqos
.s_axi_arvalid                  (s00_axi_arvalid           ),  // input			s_axi_arvalid
.s_axi_arready                  (s00_axi_arready           ),  // output		s_axi_arready
// Slave Interface Read Data Ports
.s_axi_rid                      (s00_axi_rid               ),  // output [0:0]	s_axi_rid
.s_axi_rdata                    (s00_axi_rdata             ),  // output [63:0]	s_axi_rdata
.s_axi_rresp                    (s00_axi_rresp             ),  // output [1:0]	s_axi_rresp
.s_axi_rlast                    (s00_axi_rlast             ),  // output	    s_axi_rlast
.s_axi_rvalid                   (s00_axi_rvalid            ),  // output		s_axi_rvalid
.s_axi_rready                   (s00_axi_rready            ),  // input			s_axi_rready
// System Clock Ports
.sys_clk_i                      (sys_clk                   ),  //               MIG clock
.sys_rst                        (rst_n                     )   //              input sys_rst
);
/*************************************************************************
AXI User Interface Conversion 
****************************************************************************/
aq_axi_master u_aq_axi_master
(
.ARESETN                        (~ui_clk_sync_rst         ),
.ACLK                           (ui_clk                   ),
.M_AXI_AWID                     (s00_axi_awid             ),
.M_AXI_AWADDR                   (s00_axi_awaddr           ),
.M_AXI_AWLEN                    (s00_axi_awlen            ),
.M_AXI_AWSIZE                   (s00_axi_awsize           ),
.M_AXI_AWBURST                  (s00_axi_awburst          ),
.M_AXI_AWLOCK                   (s00_axi_awlock           ),
.M_AXI_AWCACHE                  (s00_axi_awcache          ),
.M_AXI_AWPROT                   (s00_axi_awprot           ),
.M_AXI_AWQOS                    (s00_axi_awqos            ),
.M_AXI_AWUSER                   (s00_axi_awuser           ),
.M_AXI_AWVALID                  (s00_axi_awvalid          ),
.M_AXI_AWREADY                  (s00_axi_awready          ),
.M_AXI_WDATA                    (s00_axi_wdata            ),
.M_AXI_WSTRB                    (s00_axi_wstrb            ),
.M_AXI_WLAST                    (s00_axi_wlast            ),
.M_AXI_WUSER                    (s00_axi_wuser            ),
.M_AXI_WVALID                   (s00_axi_wvalid           ),
.M_AXI_WREADY                   (s00_axi_wready           ),
.M_AXI_BID                      (s00_axi_bid              ),
.M_AXI_BRESP                    (s00_axi_bresp            ),
.M_AXI_BUSER                    (s00_axi_buser            ),
.M_AXI_BVALID                   (s00_axi_bvalid           ),
.M_AXI_BREADY                   (s00_axi_bready           ),
.M_AXI_ARID                     (s00_axi_arid             ),
.M_AXI_ARADDR                   (s00_axi_araddr           ),
.M_AXI_ARLEN                    (s00_axi_arlen            ),
.M_AXI_ARSIZE                   (s00_axi_arsize           ),
.M_AXI_ARBURST                  (s00_axi_arburst          ),
.M_AXI_ARLOCK                   (s00_axi_arlock           ),
.M_AXI_ARCACHE                  (s00_axi_arcache          ),
.M_AXI_ARPROT                   (s00_axi_arprot           ),
.M_AXI_ARQOS                    (s00_axi_arqos            ),
.M_AXI_ARUSER                   (s00_axi_aruser           ),
.M_AXI_ARVALID                  (s00_axi_arvalid          ),
.M_AXI_ARREADY                  (s00_axi_arready          ),
.M_AXI_RID                      (s00_axi_rid              ),
.M_AXI_RDATA                    (s00_axi_rdata            ),
.M_AXI_RRESP                    (s00_axi_rresp            ),
.M_AXI_RLAST                    (s00_axi_rlast            ),
.M_AXI_RUSER                    (s00_axi_ruser            ),
.M_AXI_RVALID                   (s00_axi_rvalid           ),
.M_AXI_RREADY                   (s00_axi_rready           ),
.MASTER_RST                     (1'b0                     ),
.WR_START                       (wr_burst_req             ),
.WR_ADRS                        ({wr_burst_addr,3'd0}     ),
.WR_LEN                         ({wr_burst_len,3'd0}      ),
.WR_READY                       (                         ),
.WR_FIFO_RE                     (wr_burst_data_req        ),
.WR_FIFO_EMPTY                  (1'b0                     ),
.WR_FIFO_AEMPTY                 (1'b0                     ),
.WR_FIFO_DATA                   (wr_burst_data            ),
.WR_DONE                        (wr_burst_finish          ),
.RD_START                       (rd_burst_req             ),
.RD_ADRS                        ({rd_burst_addr,3'd0}     ),
.RD_LEN                         ({rd_burst_len,3'd0}      ),
.RD_READY                       (                         ),
.RD_FIFO_WE                     (rd_burst_data_valid      ),
.RD_FIFO_FULL                   (1'b0                     ),
.RD_FIFO_AFULL                  (1'b0                     ),
.RD_FIFO_DATA                   (rd_burst_data            ),
.RD_DONE                        (rd_burst_finish          ),
.DEBUG                          (                         )
);



endmodule