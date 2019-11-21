`timescale 1 ns / 1 ns
`default_nettype none

module card_driver(
	input wire CLK,
	input wire RST,
			  
	input wire WR_STB,
	input wire [31:0] WR_ADDR,
	output reg WR_ACK,
	
	input wire WD_STB,
	input wire [7:0] WD_DATA,
	output wire WD_ACK,

	input wire RD_STB,
	input wire [31:0] RD_ADDR,
   	output reg RD_ACK,


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
  10: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                          if (R_STB)   state <=  11; end
  11: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                          if (R_STB)   state <=  12; end
  12: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                          if (R_STB)   state <=  13; end
  
  //wys³anie komendy resetu CMD0													                                           			  
  13: begin CS<=0; W_DATA <= 8'b01000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 14; end
  14: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 15; end
  15: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 16; end
  16: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 17; end
  17: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 18; end
  18: begin CS<=0; W_DATA <= 8'b10010101; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 19; end
  
  //czekanie na odpowiedz po inicjalizacji
  19: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 20; end
  20: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 21; end
  21: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 22; end

//------------
	  //wys³anie komendy CMD8	//sprawdzenie zasilania		arg: 0x1AA	checksum: 0x87									                                           			  
  22: begin CS<=0; W_DATA <= 8'b01001000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 23; end
  23: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 24; end
  24: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 25; end
  25: begin CS<=0; W_DATA <= 8'b00000001; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 26; end
  26: begin CS<=0; W_DATA <= 8'b10101010; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 27; end
  27: begin CS<=0; W_DATA <= 8'b10000111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 28; end
																																	  
     //czekanie na odpowiedz po CMD8                                                                                                  
  28: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 29; end
  29: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 30; end	
  30: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 31; end
  31: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 32; end	 
  32: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 33; end

  33: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 34; end	
  34: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 40; end

//----------------------------
//    https://www.microchip.com/forums/m452739.aspx
      //wys³anie komendy CMD55	pe³na inicjalizacja											                                           			  
  40: begin CS<=0; W_DATA <= 8'b01110111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 41; end
  41: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 42; end
  42: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 43; end
  43: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 44; end
  44: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 45; end
  45: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 46; end
  
      //czekanie na odpowiedz po CMD55
  46: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 47; end
  47: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 48; end	 
  48: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 49; end
  49: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 50; end
	  
      //wys³anie komendy ACMD41													                                           			  
  50: begin CS<=0; W_DATA <= 8'b01101001; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 51; end
  51: begin CS<=0; W_DATA <= 8'b01000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 52; end
  52: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 53; end
  53: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 54; end
  54: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 55; end
  55: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 56; end
																																	  
      //czekanie na odpowiedz po ACMD41                                                                                               
  56: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)  state <= 57;  end
  57: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)  state <= 58;  end
  58: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)  state <= 59;  end
  59: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)  state <= 60;  end
  60: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)  state <= 61;  end

  61: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB) state <= 62;  end
  62: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB) state <= 63;  end 
  63: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB) state <= 64;  end
  64: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB) state <= 65;  end
  65: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB) state <= 66;  end
  66: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB) state <= 70;  end
	
     //wys³anie komendy CMD55	pe³na inicjalizacja											                                           			  
 70: begin CS<=0; W_DATA <= 8'b01110111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=71; end
 71: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=72; end
 72: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=73; end
 73: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=74; end
 74: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=75; end
 75: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=76; end
																																	
     //czekanie na odpowiedz po CMD55                                                                                               
 76: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <=77; end
 77: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <=78; end	 
 78: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <=79; end
 79: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <=80; end
																																 
     //wys³anie komendy ACMD41													                                           			 
 80: begin CS<=0; W_DATA <= 8'b01101001; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=81; end
 81: begin CS<=0; W_DATA <= 8'b01000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=82; end
 82: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=83; end
 83: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=84; end
 84: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=85; end
 85: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=86; end
																															  
     //czekanie na odpowiedz po ACMD41                                                                                               
 86: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)  state <=87;  end
 87: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)  state <=88;  end
 88: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)  state <=129;  end


	  
	  
	  
/*
//----------------------------------------------------------
	http://elm-chan.org/docs/mmc/mmc_e.html#spiinit

	  //wys³anie komendy CMD24 zapis pojedynczego bloku		- komenda zapisu
  90: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (WR_STB)   state <= 91; else state <= 76;  end
  
  91: begin CS<=0; W_DATA <= 8'b01011000; 		W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 92; end
  92: begin CS<=0; W_DATA <= WR_ADDR[31:24]; 	W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 93; end
  93: begin CS<=0; W_DATA <= WR_ADDR[23:16]; 	W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 94; end
  94: begin CS<=0; W_DATA <= WR_ADDR[15:8]; 	W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 95; end
  95: begin CS<=0; W_DATA <= WR_ADDR[7:0]; 		W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 96; end
  96: begin CS<=0; W_DATA <= 8'b00000000; 		W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 97; end
  
	  
    //czekanie na odpowiedz po CMD24                                                                                                 
  97: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 98; end
  98: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 99; end	
  99: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 100; end
  100: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 101; end	 
  101: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 129; end


       //wys³anie komendy CMD17				- komenda odczytu									                                           			  
  110: begin CS<=0; W_DATA <= 8'b01011000; 	 	W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 82; end
  111: begin CS<=0; W_DATA <= RD_ADDR[31:24]; 	W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 83; end
  112: begin CS<=0; W_DATA <= RD_ADDR[23:16];   W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 84; end
  113: begin CS<=0; W_DATA <= RD_ADDR[15:8]; 	W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 85; end
  114: begin CS<=0; W_DATA <= RD_ADDR[7:0]; 	W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 86; end
  115: begin CS<=0; W_DATA <= 8'b00000000; 		W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 87; end
																																	  
       //czekanie na odpowiedz po CMD17                                                                                                 
  116: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 88; end
  117: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 89; end	 
  118: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 90; end
  119: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 91; end	 
  120: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 129; end
*/


	  
 129: begin CS<=1; 			             W_STB <= 0;                  RES_STB <= !RES_ACK;                     if (RES_ACK) state <= 130; end              
 130: begin                                                            RES_STB <= 1;        RES_DATA <= "W";                 state <= 131; end
 131: begin                                                            RES_STB <= !RES_ACK;                     if (RES_ACK) state <= 132; end               
 132: begin                                                            RES_STB <= 0;                                                      end
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