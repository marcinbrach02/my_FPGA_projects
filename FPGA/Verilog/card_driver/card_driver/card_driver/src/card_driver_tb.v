			  `timescale 1 ns / 1 ns
`default_nettype none
  
module card_driver_tb();

reg RST, CLK;	
wire RES_S, RES_AC=1;
wire [7:0] WD_D, RES_D;
wire SCK, MI, MO, CS;

//reg RST, CLK, WR_S, WR_AC, WD_S, WD_AC, RD_S, RD_AC, RES_S, RES_AC, SCK, MI, MO, CS, C8_temp, C48_temp, T74_temp, W_STB_I_TE; 	   
//reg [7:0] WD_D, RES_D, W_DATA_I_TE;
//reg [31:0] WR_A, RD_A;
	   

card_driver driver(
.CLK(CLK), 
.RST(RST), 
/*
.WR_STB(WR_S),
.WR_ADDR(WR_A),
.WR_ACK(WR_AC),
.WD_STB(WD_S),
.WD_DATA(WD_D),
.WD_ACK(WD_AC),
.RD_STB(RD_S),
.RD_ADDR(RD_A),
.RD_ACK(RD_AC),
*/
.RES_STB(RES_S),
.RES_DATA(RES_D),
.RES_ACK(RES_AC),

.MOSI(MO), 
.MISO(MI), 
.SCLK(SCK),
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
	
	
localparam DATA_WIDTH = 7*8;

reg [DATA_WIDTH-1:0] do_wysylki;

always @(negedge SCK or posedge RST ) 						   
if (RST)	
	do_wysylki <= {8'b00000001,8'b00000010,8'b00000011,8'b00000100,8'b00000101,8'b00000110,8'b00000111};
else if (CS==0)	
	do_wysylki <= do_wysylki << 1;	

assign MI = do_wysylki[DATA_WIDTH-1];



	
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
