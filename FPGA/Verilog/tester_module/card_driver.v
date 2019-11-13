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
   	input  wire RES_ACK,	   
	   
	   
	output wire MOSI,
	input  wire MISO,
	output wire SCLK,
	output reg  CS
				  		   	   
);		

parameter DIVIDER = 5;
							   
localparam DIVIDER_WIDTH = 9; // log2(255)

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
	RES_STB <= 0;
	RES_DATA <= 0;
end else case(state)

  0: begin                                                            RES_STB <= 1;        RES_DATA <= "S";                 state <= 1; end
  1: begin                                                            RES_STB <= !RES_ACK;                     if (RES_ACK) state <= 2; end               
  2: begin                                                            RES_STB <= 0;                                         state <= 3;  end
	 
  // inicjalizacja 74 takty CS=1, MOSI=1
  3: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  4; end
  4: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  5; end
  5: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  6; end
  6: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  7; end
  7: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  8; end
  8: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  9; end
  9: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  10; end
  10: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  11; end
  11: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  12; end
  12: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  13; end
  
  
														                                           			  
 13: begin CS<=0; W_DATA <= 8'b01000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 14; end
 14: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 15; end
 15: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 16; end
 16: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 17; end
 17: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 18; end
 18: begin CS<=0; W_DATA <= 8'b10010101; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 19; end


 19: begin CS<=0; W_DATA <= 8'b01001000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 20; end
 20: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 21; end
 21: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 22; end
 22: begin CS<=0; W_DATA <= 8'b00000001; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 23; end
 23: begin CS<=0; W_DATA <= 8'b10101010; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 24; end
 24: begin CS<=0; W_DATA <= 8'b00001111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 25; end

25: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 26; end


 26: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 27; end
 27: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 28; end
 28: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 29; end
	  
	  
 29: begin CS<=1; 			             W_STB <= 0;                  RES_STB <= !RES_ACK;                     if (RES_ACK) state <= 30; end              
 30: begin                                                            RES_STB <= 1;        RES_DATA <= "W";                 state <= 31; end
 31: begin                                                            RES_STB <= !RES_ACK;                     if (RES_ACK) state <= 32; end               
 32: begin                                                            RES_STB <= 0;                                                      end
endcase
			
SPI_cont SPI(
.CLK(CLK), 
.RST(RST),
.TICK(TICK),
.W_STB(W_STB),
.W_DATA(W_DATA),
.W_READY(W_READY),

//.MOSI_INACTIVE(1),

.R_STB(R_STB),
.R_DATA(R_DATA),
.MOSI(MOSI),
.MISO(MISO),
.SCLK(SCLK) 
);	  


endmodule