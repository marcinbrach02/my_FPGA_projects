`timescale 1 ns / 1 ns
`default_nettype none

module card_driver(
	input wire CLK,
	input wire RST,
			  
	input  wire        WR_STB,
	input  wire [31:0] WR_ADDR,
	output reg         WR_ACK,
	
	input  wire        WD_STB,
	input  wire  [7:0] WD_DATA,
	output reg         WD_ACK,

	input  wire        RD_STB,
	input  wire [31:0] RD_ADDR,
   	output reg         RD_ACK,


/*
	output reg DBG_STB,
	output reg [7:0] DBG_DATA,
   	input  wire DBG_BUSY,	  
	*/
	
	output reg RES_STB,
	output reg [7:0] RES_DATA,
   	input  wire RES_BUSY,	   
	   
	   
	output wire MOSI,
	input  wire MISO,
	output wire SCLK,
	output reg  CS
				  		   	   
);		

parameter DIVIDER = 5;
							   
localparam DIVIDER_WIDTH = 9; // log2(255)

reg [DIVIDER_WIDTH-1:0] tickcounter;	 
wire TICK = tickcounter[DIVIDER_WIDTH-1];

always @(posedge CLK or posedge RST) tickcounter <= (RST) ? DIVIDER-1 : (TICK) ? DIVIDER-1 : tickcounter-1;
	
	

reg [7:0] state;

reg W_STB;
reg [7:0] W_DATA; 
wire W_READY;

wire R_STB;
wire [7:0] R_DATA;

localparam SC_SIZE = 9;

reg [SC_SIZE:0] statecounter; // [8:0] to 511..00    [9:0] 511..0, -1

reg [31:0] ADDR;

always@(posedge CLK or posedge RST)	
if (RST) begin
	state <= 0;
	CS <= 1;
	W_STB <= 0;
	W_DATA <= 0; 
	RES_STB <= 0;
	RES_DATA <= 0;
	statecounter <= 0;
	ADDR <= 0;
	WD_ACK <= 0;
end else case(state)

  0:  begin                                                            RES_STB <= 0;                         if (RES_BUSY==0) state <=1; end
  1:  begin                                       statecounter <= 15;  RES_STB <= 1;        RES_DATA <= "S";                 state <= 3; end
	
  // inicjalizacja 74 takty CS=1, MOSI=1
  3:  begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= 0;                            if (R_STB)   state <=  4; end
  4:  begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  5; end
  5:  begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  6; end
  6:  begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  7; end
  7:  begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  8; end
  8:  begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  9; end
  9:  begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  10; end
  10: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  11; end
  11: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  12; end
  12: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  13; end
	  
//wys³anie komendy resetu CMD0													                                           			  
  13: begin CS<=0; W_DATA <= 8'b01000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 14; end
  14: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 15; end
  15: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 16; end
  16: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 17; end
  17: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 18; end
  18: begin CS<=0; W_DATA <= 8'b10010101; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 19; end
  
  //czekanie na odpowiedz po inicjalizacji
  19: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 20; end
  20: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'h01) state <= 21; else if (statecounter[SC_SIZE]) state <= 0 ; else state <= 19; end
  21: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 150; end
	  
  150:  begin                                                            RES_STB <= 0;                         if (RES_BUSY==0) state <=151; end
  151:  begin                                       statecounter <= 15;  RES_STB <= 1;         RES_DATA <= statecounter;                state <= 22; end


	
//------------
	  //wys³anie komendy CMD8	//sprawdzenie zasilania		arg: 0x1AA	checksum: 0x87									                                           			  
  22: begin CS<=0; W_DATA <= 8'b01001000; W_STB <= W_READY && !R_STB;  RES_STB <= 0;                            if (R_STB)   state <= 23; end
  23: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 24; end
  24: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 25; end
  25: begin CS<=0; W_DATA <= 8'b00000001; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 26; end
  26: begin CS<=0; W_DATA <= 8'b10101010; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 27; end
  27: begin CS<=0; W_DATA <= 8'b10000111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 28; end
																																	  
     //czekanie na odpowiedz po CMD8                                                                                                  
  28: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 29; end
  29: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'h01) state <= 30; else if (statecounter[SC_SIZE]) state <= 150 ; else state <= 28; end 
  30: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 31; end   31: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'h00) state <= 32; else if (statecounter[SC_SIZE]) state <= 150 ; else state <= 30; end 
  32: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 33; end  
  33: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'h00) state <= 34; else if (statecounter[SC_SIZE]) state <= 150 ; else state <= 32; end 
  34: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 35; end 
  35: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'h01) state <= 36; else if (statecounter[SC_SIZE]) state <= 150 ; else state <= 34; end 
  36: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 37; end  37: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'hAA) state <= 200; else if (statecounter[SC_SIZE]) state <= 150 ; else state <= 36; end 
  200: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 38; end

	 

  38:  begin                                                            RES_STB <= 0;                         if (RES_BUSY==0) state <=39; end
  39:  begin                                       statecounter <= 15;  RES_STB <= 1;         RES_DATA <= statecounter;                state <= 40; end


//----------------------------
//    https://www.microchip.com/forums/m452739.aspx   RES_DATA <= 1;
      //wys³anie komendy CMD55	pe³na inicjalizacja											                                           			  
  40: begin CS<=0; W_DATA <= 8'b01110111; W_STB <= W_READY && !R_STB;  RES_STB <= 0;                            if (R_STB)   state <= 41; end
  41: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 42; end
  42: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 43; end
  43: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 44; end
  44: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 45; end
  45: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 46; end
  
      //czekanie na odpowiedz po CMD55
  46: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 47; end
  47: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'h01) state <= 48; else if (statecounter[SC_SIZE]) state <= 38 ; else state <= 46; end
  48: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 50; end
 
      //wys³anie komendy ACMD41													                                           			  
  50: begin CS<=0; W_DATA <= 8'b01101001; W_STB <= W_READY && !R_STB;  RES_STB <= 0;                            if (R_STB)   state <= 51; end
  51: begin CS<=0; W_DATA <= 8'b01000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 52; end
  52: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 53; end
  53: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 54; end
  54: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 55; end
  55: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 61; end
																																	  
      //czekanie na odpowiedz po ACMD41                                                                                               
  61: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 62; end
  62: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'h00) state <= 63; else if (statecounter[SC_SIZE]) state <= 38 ; else state <= 61; end
  63: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 89; end

//------------------------
  
 89: begin CS<=1; statecounter <= 510; WR_ACK <= 0; RD_ACK <= 0; RES_STB <= 0; if (WR_STB) begin ADDR <= WR_ADDR; state <= 90; end else if (RD_STB) begin ADDR <= RD_ADDR; state <= 110; end end
	  
	  
//----------------------------------------------------------
//	http://elm-chan.org/docs/mmc/mmc_e.html#spiinit

  90: begin CS<=1; 			            W_STB <= 0;             RES_STB <= 1;        RES_DATA <= "z";        state <= 91; end 
	  //wys³anie komendy CMD24 zapis pojedynczego bloku		- komenda zapisu
  91: begin CS<=0; W_DATA <= 8'b01011000; 		W_STB <= W_READY && !R_STB; RES_STB <= 0;                             if (R_STB)   state <= 92; end
  92: begin CS<=0; W_DATA <= ADDR[31:24];		W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 93; ADDR <= ADDR<<8;end end
  93: begin CS<=0; W_DATA <= ADDR[31:24];		W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 94; ADDR <= ADDR<<8;end end
  94: begin CS<=0; W_DATA <= ADDR[31:24];		W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 95; ADDR <= ADDR<<8;end end
  95: begin CS<=0; W_DATA <= ADDR[31:24]; 		W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 96; end
  96: begin CS<=0; W_DATA <= 8'b00000000; 		W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 97; end
  
	  
    //czekanie na odpowiedz po CMD24                                                                                                 
  97:  begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 98; end
  98:  begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 99; end	
  99:  begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 100; end
  100: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 101; end	 
 
  101: begin CS<=0; W_DATA <= 8'b11111110; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 102; end

 
  // petla 512 bajtow
  102: begin CS<=0; ADDR[31:24] <= WD_DATA; W_STB <= 0;                 WD_ACK <= WD_STB;  RES_STB <= 0;         if (WD_STB)  state <= 103; end
  103: begin CS<=0; W_DATA <= ADDR[31:24];	W_STB <= W_READY && !R_STB; WD_ACK <= 0;                             if (R_STB)   state <= 104; end
  104: begin CS<=0;                         W_STB <= 0;      statecounter <=statecounter-1;                      if (statecounter[SC_SIZE]) state <= 105 ; else state <= 102; end
	  
  105: begin CS<=1;                         W_STB <= 0;                                              state <= 106; end // 89
  106: begin CS<=1; 			            W_STB <= 0;             RES_STB <= 1;        RES_DATA <= "Z";        state <= 107; end 
  107: begin CS<=1;                                                 WR_ACK <= 1; RES_STB <= 0;                   state <= 89;  end
	 



//-----------------------------------------------------------------------------------------------------------



       //wys³anie komendy CMD17				- komenda odczytu									                                           			  
  110: begin CS<=0; W_DATA <= 8'b01011000; 	 	W_STB <= W_READY && !R_STB; RES_STB <= 0;                             if (R_STB)   state <= 111; end
  111: begin CS<=0; W_DATA <= ADDR[31:24];		W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 112; ADDR <= ADDR<<8;end end
  112: begin CS<=0; W_DATA <= ADDR[31:24];		W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 113; ADDR <= ADDR<<8;end end
  113: begin CS<=0; W_DATA <= ADDR[31:24];		W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 114; ADDR <= ADDR<<8;end end
  114: begin CS<=0; W_DATA <= ADDR[31:24];		W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 115; end
  115: begin CS<=0; W_DATA <= 8'b00000000; 		W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 116; end
																																	  
       //czekanie na odpowiedz po CMD17                                                                                                 
  116: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 117; end
  117: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 118; end	 
  118: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 119; end
  119: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 120; end	 
  120: begin CS<=0; W_DATA <= 8'b11111110; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 122; end


  // petla 512 bajtow
  122: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA;    if (R_STB)   state <= 123; end // RES_DATA,  wzedzie indziej DBG_DATA
  123: begin CS<=0;                        W_STB <= 0;      RES_STB <= 0; statecounter <=statecounter-1;                          if (statecounter[SC_SIZE]) state <= 124 ; else state <= 122; end
	  
  124: begin CS<=1;                        W_STB <= 0;             RD_ACK <= 1;                                 state <= 89; end

	  
// 129: begin CS<=1; 			             W_STB <= 0;                   RES_STB <= 1;        RES_DATA <= "W";                 state <= 130; end 
// 130: begin                                                            RES_STB <= 0;                                                      end
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