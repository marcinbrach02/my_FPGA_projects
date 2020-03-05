`timescale 1 ns / 1 ns
`default_nettype none


//`define TEST_TERMINAL 1
//`define TEST_READ 1
//`define TEST_WRITE 1

`define TEST_RW 1

module tester_module(
	input wire CLOCK50,
	input wire nRESET,

	output wire MOSI,
	input  wire MISO,
	output wire SCLK,
	output wire CS,

	input  wire RxD,        
	output wire TxD,

    input wire [3:0] SWITCH,
	output wire [3:0] LED
                                   

);

wire RESET;

reg WR_STB;
reg [31:0] WR_ADDR;
reg [31:0] WR_LENGTH;
wire WR_ACK;
	
reg WD_STB;
reg [7:0] WD_DATA;
wire WD_ACK;
	
reg RD_STB;
reg [31:0] RD_ADDR;
reg [31:0] RD_LENGTH;
wire RD_ACK;
	   
wire RES_STB;
wire RES_DEBUG;
wire [7:0] RES_DATA;
wire RES_BUSY;	 



wire        RX_STB;        
wire  [7:0] RX_DAT;         
wire        RX_ACK = RX_STB;
                                 
reg         TX_STB;         
reg   [7:0] TX_DAT;        
wire        TX_ACK;        
wire        TX_RDY;        

assign RESET = !nRESET;

reg [31:0] counter;

always @(posedge CLOCK50 or posedge RESET) counter <= RESET ? 0 : counter +1;
assign LED = counter>>22;

reg RD_EN;
wire RD_EMPTY;
wire [7:0] RD_Q;

wire BUSY;

`ifdef TEST_WRITE
assign RES_BUSY=0;
`endif
`ifdef TEST_READ
assign RES_BUSY=0;
`endif

`ifdef TEST_RW
assign RES_BUSY=0;
`endif



fifo_dc fifo (
.WrClock(CLOCK50), 

`ifdef TEST_TERMINAL
.Data(RES_DATA), 
.WrEn(RES_STB && !RES_DEBUG), 
.AlmostFull(RES_BUSY),
`endif

`ifdef TEST_WRITE
.Data("w"), 
.WrEn(WR_ACK), 
.AlmostFull(BUSY),
`endif

`ifdef TEST_READ
.Data("r"), 
.WrEn(RD_ACK), 
.AlmostFull(BUSY),
`endif

`ifdef TEST_RW
.Data(RD_ACK ? "r" : "w"), 
.WrEn(RD_ACK || WR_ACK), 
.AlmostFull(BUSY),
`endif

.RdClock(CLOCK50), 
.RdEn(RD_EN), 

.Reset(RESET), 
.RPReset(RESET), 

.Q(RD_Q), 

.Empty(RD_EMPTY), 
.Full( ), 
.AlmostEmpty( )

);

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

/*
// automat nadawania danych
always @(posedge CLOCK50 or posedge RESET) 
if (RESET) begin
  WD_STB <= 1;
  WD_DATA <= 1; 
end else if (WD_ACK) WD_DATA <= {WD_DATA,WD_DATA[7]};
*/

localparam BURST_SIZE = 100;


`ifdef TEST_TERMINAL

// automat odbioru komend z UART i zlecania karcie SD
always @(posedge CLOCK50 or posedge RESET) 
if (RESET) begin
  WR_STB <= 0;
  WR_ADDR <= 0;
  WR_LENGTH <= 0;
  RD_STB <= 0;
  RD_ADDR <= 0;
  RD_LENGTH <= 0;
end else begin 
  RD_STB <= 0;
  WR_STB <= 0;	
  if (WR_ACK) WR_ADDR <= WR_ADDR + BURST_SIZE; 
  if (RD_ACK) RD_ADDR <= RD_ADDR+1;
	  
  if (RX_STB && (RX_DAT=="c")) begin
	WR_ADDR <= 0; 
	RD_ADDR <= 0;
  end else if (RX_STB && (RX_DAT=="z")) begin
	WR_STB <= 1;
	WR_LENGTH <= BURST_SIZE;  
  end else if (RX_STB && (RX_DAT=="o")) begin
	RD_STB <= 1;
	RD_LENGTH <= 1;  
  end 	  
end
`endif


`ifdef TEST_WRITE
// test zapisu
reg [7:0] wstate;
always @(posedge CLOCK50 or posedge RESET) 
if (RESET) begin
  WR_STB <= 0;
  WR_ADDR <= 0;
  WR_LENGTH <= BURST_SIZE;
  RD_STB <= 0;
  RD_ADDR <= 0;
  RD_LENGTH <= BURST_SIZE;
  wstate <=0;
end else case (wstate)
  0: begin
	WR_STB <= 1;
	WR_LENGTH <= BURST_SIZE;  
	if (WR_ACK) wstate <= 1;
  end
  1: begin
    WR_STB <= 0;
    if (!BUSY) wstate <= 2;
  end
  2: begin
    WR_ADDR <= WR_ADDR + BURST_SIZE; 
    wstate <= 0;
  end
endcase
`endif

`ifdef TEST_READ
// test odczytu
reg [7:0] rstate;
// automat odbioru komend z UART i zlecania karcie SD
always @(posedge CLOCK50 or posedge RESET) 
if (RESET) begin
  WR_STB <= 0;
  WR_ADDR <= 0;
  WR_LENGTH <= BURST_SIZE;
  RD_STB <= 0;
  RD_ADDR <= 0;
  RD_LENGTH <= BURST_SIZE;
  rstate <=0;
end else case (rstate)
  0: begin
	RD_STB <= 1;
	RD_LENGTH <= BURST_SIZE;  
	if (RD_ACK) rstate <= 1;
  end
  1: begin
    RD_STB <= 0;
    if (!BUSY) rstate <= 2;
  end
  2: begin
    RD_ADDR <= RD_ADDR + BURST_SIZE; 
    rstate <= 0;
  end
endcase
`endif


`ifdef TEST_RW

wire read_nwrite = SWITCH[3];

wire [31:0] burst_len = 
  SWITCH[2:0]==0 ? 1 : 
  SWITCH[2:0]==1 ? 2 : 
  SWITCH[2:0]==2 ? 5 : 
  SWITCH[2:0]==3 ? 10 : 
  SWITCH[2:0]==4 ? 100 : 
  SWITCH[2:0]==5 ? 1000 : 
  SWITCH[2:0]==6 ? 10000 : 100000;

reg [7:0] rwstate;
// automat odbioru komend z UART i zlecania karcie SD
always @(posedge CLOCK50 or posedge RESET) 
if (RESET) begin
  WR_STB <= 0;
  WR_ADDR <= 0;
  WR_LENGTH <= 0;
  RD_STB <= 0;
  RD_ADDR <= 0;
  RD_LENGTH <= 0;
  rwstate <=0;
end else case (rwstate)
  0: begin
	RD_STB <= read_nwrite;	
	WR_STB <= !read_nwrite;		
	RD_LENGTH <= burst_len;  
	WR_LENGTH <= burst_len;  
	if (RD_ACK) rwstate <= 1;
  end
  1: begin
    RD_STB <= 0;
	WR_STB <= 0;
    if (!BUSY) rwstate <= 2;
  end
  2: begin
    RD_ADDR <= RD_ADDR + burst_len; 
	WR_ADDR <= WR_ADDR + burst_len; 
    rwstate <= 0;
  end
endcase
`endif




card_driver 
#(
  .START_DIVIDER(255),
  //.TRANSMISSION_DIVIDER(1)
  .TRANSMISSION_DIVIDER(0)
) 
driver
(
.CLK(CLOCK50), 
.RST(RESET),

.WR_STB(WR_STB),
.WR_ADDR(WR_ADDR),
.WR_LENGTH(WR_LENGTH),
.WR_ACK(WR_ACK),

.WD_STB(WD_STB),
.WD_DATA(WD_DATA),
.WD_ACK(WD_ACK),

.RD_STB(RD_STB),
.RD_ADDR(RD_ADDR),
.RD_LENGTH(RD_LENGTH),
.RD_ACK(RD_ACK),

.RES_STB(RES_STB),
.RES_DEBUG(RES_DEBUG),
.RES_DATA(RES_DATA),
.RES_BUSY(RES_BUSY),

.MOSI(MOSI),
.MISO(MISO),
.SCLK(SCLK),
.CS(CS)
);	



endmodule
 