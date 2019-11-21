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

wire WR_STB;
wire [31:0] WR_ADDR;
wire WR_ACK;
	
wire WD_STB;
wire [7:0] WD_DATA;
wire WD_ACK;
	
wire RD_STB;
wire [31:0] RD_ADDR;
wire RD_ACK;
	   
wire RES_STB;
wire [7:0] RES_DATA;
wire RES_ACK;	 



reg         RX_STB;        
reg   [7:0] RX_DAT;         
wire        RX_ACK;         
                                 
wire        TX_STB;         
wire  [7:0] TX_DAT;        
reg         TX_ACK;        
reg         TX_RDY;        

wire        r_stb;        
wire  [7:0] r_dat;         
wire        r_ack;  

assign RESET = !nRESET;

assign SCLK_LED = SCLK;





dev_uart_asy 
#(.CLK_MHZ(50))
uart(
.CLK(CLOCK50),
.RST(RESET),

.RxD_PIN(RxD),
.TxD_PIN(TxD),

.RX_STB(),
.RX_DAT(),
.RX_ACK(1),

.TX_STB(RES_STB),
.TX_DAT(RES_DATA),
.TX_ACK(RES_ACK),
.TX_RDY()
);


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
.RES_ACK(RES_ACK),

.MOSI(MOSI),
.MISO(MISO),
.SCLK(SCLK),
.CS(CS)
);	

endmodule
 