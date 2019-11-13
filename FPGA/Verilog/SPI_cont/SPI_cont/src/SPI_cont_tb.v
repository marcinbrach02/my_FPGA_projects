`timescale 1 ns / 1 ns
`default_nettype none
  
module SPI_cont_tb();
	
reg RST, CLK, W_STB, R_STB, SCK, MO; 	   
wire MI;
reg [7:0] W_DATA, R_DATA;



localparam DIVIDER_WIDTH = 10;
localparam DIVIDER = 5;
reg [DIVIDER_WIDTH-1:0] counter;	 
wire TICK = counter[DIVIDER_WIDTH-1];

always @(posedge CLK or posedge RST) counter <= (RST) ? DIVIDER-1 : (TICK) ? DIVIDER-1 : counter-1;
	
SPI_cont SPI(.CLK(CLK), .RST(RST), .TICK(TICK), .W_STB(W_STB), .W_DATA(W_DATA), .W_READY(), .R_STB(R_STB), .R_DATA(R_DATA), .MOSI(MO), .MISO(MI), .SCLK(SCK) );



initial begin
	    RST=0;
	#10 RST=1;  
	#20 RST=0;
end

initial begin
	   CLK=0;
end

always #1 CLK = ~CLK;

initial begin
	W_STB=0; 	 
	@(posedge CLK);
	@(negedge RST);
	#103;
	@(posedge CLK);
	W_STB=1; W_DATA=171;  // 0xAB  1010 1011
	@(posedge CLK);
	W_STB=0; W_DATA=0;
	@(posedge R_STB);	
	@(posedge CLK);
	W_STB=1; W_DATA=171;  // 0xAB  1010 1011
	@(posedge CLK);
	W_STB=0; W_DATA=0;
	@(posedge CLK);
	//#64	W_STB=1; W_DATA=254;
	//#8		W_STB=0; W_DATA=0;
end	


 
localparam DATA_WIDTH = 16;

reg [DATA_WIDTH-1:0] do_wysylki;

always @(negedge SCK or posedge RST ) 						   
if (RST)	
	do_wysylki <= {8'b0010_1001, 8'b0110_0011};
else 	
	do_wysylki <= do_wysylki << 1;	

assign MI = do_wysylki[DATA_WIDTH-1];
   
endmodule	
