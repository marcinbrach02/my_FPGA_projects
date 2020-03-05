`timescale 1 ns / 1 ns
`default_nettype none
  
module card_driver_tb();

reg RST, CLK;	
wire RES_STB, RES_ACK=1;
wire [7:0] WD_DATA, RES_DATA;
//wire SCK, MI, MO, CS;

reg WR_STB, WR_ACK, WD_STB, WD_ACK, RD_STB, RD_ACK, SCLK, MISO, MOSI, CS; 	   
//reg [7:0] WD_D, RES_D, W_DATA_I_TE;
reg [31:0] WR_ADDR, RD_ADDR;
	   

card_driver driver(
.CLK(CLK), 
.RST(RST), 

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

	   
initial begin
	   RST=0;
	#1 RST=1;  
	#2 RST=0;
end

initial begin
	   CLK=0;
end

always #1 CLK = ~CLK;
	
	
localparam DATA_WIDTH = 6*8;

reg [DATA_WIDTH-1:0] do_wysylki;

always @(negedge SCLK or posedge RST ) 						   
if (RST)	
	do_wysylki <= {8'b01000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b10010101};
else if (CS==0)	
	do_wysylki <= do_wysylki << 1;	

assign MISO = do_wysylki[DATA_WIDTH-1];



	
/*	
initial begin
			WR=0;
	#5  	WR=1; WR_DATA=171;
	#8		WR=0; WR_DATA=0;
	//#64	WR=1; WR_DATA=254;
	//#8		WR=0; WR_DATA=0;
end	
*/



   
endmodule	
