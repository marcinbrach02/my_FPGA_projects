`timescale 1 ns / 1 ns
`default_nettype none

module card_driver(
	input wire CLK,
	input wire RST,
			  /*
	input wire WR_STB,
	input wire [31:0] WR_ADDR,
	output reg WR_ACK,
	
	input wire WD_STB,
	input wire [7:0] WD_DATA,
	output wire WD_ACK,

	input wire RD_STB,
	input wire [31:0] RD_ADDR,
   	output reg RD_ACK,
*/

	output reg RES_STB,
	output reg [7:0] RES_DATA,
   	output wire RES_ACK,	   
	   
	   
	output wire MOSI,
	input  wire MISO,
	output wire SCLK,
	output reg  CS
				  		   	   
);		

parameter DIVIDER = 5;
							   
localparam DIVIDER_WIDTH = 2; // log2(255)

reg [DIVIDER_WIDTH-1:0] counter;	 
wire TICK = counter[DIVIDER_WIDTH-1];

always @(posedge CLK or posedge RST) counter <= (RST) ? DIVIDER-1 : (TICK) ? DIVIDER-1 : counter-1;
	
	

reg [7:0] state;

reg W_STB;
reg [7:0] W_DATA; 
wire W_READY;

wire R_STB;
wire [7:0] R_DATA;

always@(posedge CLK or posedge RST)	
if (RST) begin
	state <= 0;
	CS <= 1;
	W_STB <= 0;
	W_DATA <= 0; 
	RES_DATA <= 0;
end else case(state)

  // inicjalizacja 74 takty CS=1, MOSI=1
  0: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  1; end
  1: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  2; end
  2: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  3; end
  3: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  4; end
  4: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  6; end
  6: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  7; end
  7: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  8; end
  8: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  9; end
  9: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 10; end
  // komendy  														                                           			  
 10: begin CS<=0; W_DATA <= 8'b01000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 11; end
 11: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 12; end
 12: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 13; end
 13: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 14; end
 14: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 15; end
 15: begin CS<=0; W_DATA <= 8'b10010101; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 16; end
 16: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 17; end
 17: begin CS<=1; 			             W_STB <= 0;                  RES_STB <= !RES_ACK;                     if (RES_ACK) state <= 18; end              
 18: begin                                                            RES_STB <= 1;        RES_DATA <= 65;                  state <= 19; end
 19: begin                                                            RES_STB <= !RES_ACK;                     if (RES_ACK) state <= 20; end               
 20: begin end
endcase
			
SPI_cont SPI(
.CLK(CLK), 
.RST(RST),
.TICK(TICK),
.W_STB(W_STB),
.W_DATA(W_DATA),
.W_READY(W_READY),

.R_STB(R_STB),
.R_DATA(R_DATA),
.MOSI(MOSI),
.MISO(MISO),
.SCLK(SCLK) 
);	  


endmodule