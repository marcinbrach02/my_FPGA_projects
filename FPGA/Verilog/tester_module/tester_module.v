`timescale 1 ns / 1 ns
`default_nettype none


module tester_module(
	input wire CLOCK50,
	input wire nRESET,

	output wire MOSI,
	input  wire MISO,
	output wire SCLK,
	output wire CS,

	input  wire RxD,        
	output wire TxD,
	
	output wire SCLK_LED
                                   

);

wire RESET;

reg WR_STB;
reg [31:0] WR_ADDR;
wire WR_ACK;
	
reg WD_STB;
reg [7:0] WD_DATA;
wire WD_ACK;
	
reg RD_STB;
reg [31:0] RD_ADDR;
wire RD_ACK;
	   
wire RES_STB;
wire [7:0] RES_DATA;
wire RES_BUSY;	 



wire        RX_STB;        
wire  [7:0] RX_DAT;         
wire        RX_ACK = RX_STB;
                                 
reg         TX_STB;         
reg   [7:0] TX_DAT;        
wire        TX_ACK;        
wire        TX_RDY;        

wire        r_stb;        
wire  [7:0] r_dat;         
wire        r_ack;  

assign RESET = !nRESET;

assign SCLK_LED = SCLK;
/*
distributed_fifo_shift
#(
  .WIDTH(8), 
  .AWIDTH(6), // 2^6 = 64   2^1024
  .BUSY_NUM(26) // 24
)
fifo
(
  .fi_clk   (CLOCK50),
  .fi_rst   (RESET),
  
  .fi_stb   (RES_STB),
  .fi_dat   (RES_DATA),
  .fi_busy  (RES_BUSY),
  .fi_empty (),
  .fi_error (), 
  
  .fo_stb  (TX_STB),
  .fo_dat  (TX_DAT),
  .fo_ack  (TX_ACK)
);
*/

reg RD_EN;
wire RD_EMPTY;
wire [7:0] RD_Q;

fifo_dc fifo (
.Data(RES_DATA), 
.WrClock(CLOCK50), 
.WrEn(RES_STB), 
.AlmostFull(RES_BUSY),

.RdClock(CLOCK50), 
.RdEn(RD_EN ), 

.Reset(RESET), 
.RPReset(RESET), 

.Q(RD_Q), 

.Empty(RD_EMPTY), 
.Full( ), 
.AlmostEmpty( )

);

reg INT_SCLK;
reg [7:0] state;

always @(posedge CLOCK50 or posedge RESET) 
if (RESET) begin
	RD_EN <= 1;
	state <= 0;
end else case(state)
	0:  if (!RD_EMPTY && TX_RDY) begin RD_EN <= 1; state <= 1; end else begin RD_EN <= 0; state <= 0; end
	1:  begin RD_EN <= 0; state <= 2; end
	2:  begin TX_STB <= 1; TX_DAT <= RD_Q; state <= 3; end
	3:  begin TX_STB <= 0; state <= 0; end
endcase
	

reg [7:0] RxD_r;

always @(posedge CLOCK50 or posedge RESET) RxD_r <= (RESET) ? 8'b11111111 : {RxD_r, RxD};

dev_uart_asy 
#(.CLK_MHZ(50))
uart(
.CLK(CLOCK50),
.RST(RESET),

.RxD_PIN(RxD_r[7]),
.TxD_PIN(TxD),

.RX_STB(RX_STB),
.RX_DAT(RX_DAT),
.RX_ACK(RX_ACK),

.TX_STB(TX_STB),
.TX_DAT(TX_DAT),
.TX_ACK(TX_ACK),
.TX_RDY(TX_RDY)
);



// automat nadawania danych
always @(posedge CLOCK50 or posedge RESET) 
if (RESET) begin
  WD_STB <= 1;
  WD_DATA <= "A"; // d65 h41
end else if (WD_ACK) WD_DATA <= WD_DATA+1;



// automat odbioru komend z UART i zlecania karcie SD
always @(posedge CLOCK50 or posedge RESET) 
if (RESET) begin
  WR_STB <= 0;
  WR_ADDR <= 0;
  RD_STB <= 0;
  RD_ADDR <= 0;
end else if (RX_STB && (RX_DAT=="z")) begin
	WR_STB <= 1;
	WR_ADDR <= 0;
end else if (RX_STB && (RX_DAT=="o")) begin
	RD_STB <= 1;
	RD_ADDR <= 0;
end else begin
	RD_STB <= 0;
	WR_STB <= 0;	
end
	


card_driver 
#(
  .DIVIDER(255)
) 
driver
(
.CLK(CLOCK50), 
.RST(RESET),

.WR_STB(WR_STB),
.WR_ADDR(WR_ADDR),
.WR_ACK(WR_ACK),

.WD_STB(WD_STB),
.WD_DATA(WD_DATA),
.WD_ACK(WD_ACK),

.RD_STB(RD_STB),
.RD_ADDR(RD_ADDR),
.RD_ACK(RD_ACK),

.RES_STB(RES_STB),
.RES_DATA(RES_DATA),
.RES_BUSY(RES_BUSY),
/*
.DBG_STB(),
.DBG_DATA(),
.DBG_BUSY(1'b0),
*/

.MOSI(MOSI),
.MISO(MISO),
.SCLK(SCLK),
.CS(CS)
);	

endmodule
 