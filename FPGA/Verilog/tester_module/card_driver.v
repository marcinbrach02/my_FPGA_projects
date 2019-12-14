`timescale 1 ns / 1 ns
`default_nettype none

module card_driver
#(
  parameter ADDR_WIDTH=32,
  parameter LEN_WIDTH=32
  )
(
	input wire CLK,
	input wire RST,
			  
	input  wire        WR_STB,
	input  wire [ADDR_WIDTH-1:0] WR_ADDR,
	input  wire [LEN_WIDTH-1:0] WR_LENGTH,
	output reg         WR_ACK,
	
	input  wire        WD_STB,
	input  wire  [7:0] WD_DATA,
	output reg         WD_ACK,

	input  wire        RD_STB,
	input  wire [ADDR_WIDTH-1:0] RD_ADDR,
	input  wire [LEN_WIDTH-1:0] RD_LENGTH,
   	output reg         RD_ACK,


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

localparam SC_SIZE = 11;

reg [SC_SIZE:0] statecounter; // [8:0] to 511..00    [9:0] 511..0, -1

reg [SC_SIZE:0] statecounter_wr;
reg [SC_SIZE:0] statecounter_rd;

reg [SC_SIZE:0] statecount;

reg [ADDR_WIDTH-1:0] ADDR;
reg [LEN_WIDTH-1:0] len_counter;


always@(posedge CLK or posedge RST)	
if (RST) begin
	state <= 0;
	CS <= 1;
	W_STB <= 0;
	W_DATA <= 0; 
	RES_STB <= 0;
	RES_DATA <= 0;
	statecounter <= 0;
	statecounter_wr <= 0;	
	statecounter_rd <= 0;
	ADDR <= 0;
	WD_ACK <= 0;
	len_counter <= 0;
end else case(state)


  0:  begin                                                            RES_STB <= 0;                         if (RES_BUSY==0) state <=1; end
  1:  begin                                       statecounter <= 5;  RES_STB <= 1;        RES_DATA <= "S";                 state <= 2; end
	
      //inicjalizacja 74 takty CS=1, MOSI=1
  2:  begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= 0;                            if (R_STB)   state <=  3; end
  3:  begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  4; end
  4:  begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  5; end
  5:  begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  6; end
  6:  begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  7; end
  7:  begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  8; end
  8:  begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  9; end
  9:  begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  10; end
  10: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  11; end
  11: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <=  12; end
	  
      //wys³anie komendy resetu CMD0													                                           			  
  12: begin CS<=0; W_DATA <= 8'b01000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 13; end
  13: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 14; end
  14: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 15; end
  15: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 16; end
  16: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 17; end
  17: begin CS<=0; W_DATA <= 8'b10010101; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 19; end
  
      //czekanie na odpowiedz po inicjalizacji
  18: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 19; end
  19: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'h01) state <= 20; else if (statecounter[SC_SIZE]) state <= 0 ; else state <= 18; end
  20: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 21; end
	  
  21:  begin                   statecounter <= 5;                                         RES_STB <= 0;                         if (RES_BUSY==0) state <= 23; end
 // 22:  begin                                       statecounter <= 15;  									                   state <= 23; end

	  //wys³anie komendy CMD8	//sprawdzenie versji i potwierdzenia zasilanie 2,7-3,6 V (arg: 0x1AA	checksum: 0x87)									                                           			  
  23: begin CS<=0; W_DATA <= 8'b01001000; W_STB <= W_READY && !R_STB;  RES_STB <= 0;                            if (R_STB)   state <= 24; end
  24: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 25; end
  25: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 26; end
  26: begin CS<=0; W_DATA <= 8'b00000001; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 27; end
  27: begin CS<=0; W_DATA <= 8'b10101010; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 28; end
  28: begin CS<=0; W_DATA <= 8'b10000111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 29; end
																																	  
      //oczekiwanie na odpowiedz po CMD8                                                                                                  
  29: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 30; end
  30: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'h01) state <= 31; else if (statecounter[SC_SIZE]) state <= 21 ; else state <= 29; end 
  31: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 32; end   32: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'h00) state <= 33; else if (statecounter[SC_SIZE]) state <= 21 ; else state <= 31; end 
  33: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 34; end  
  34: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'h00) state <= 35; else if (statecounter[SC_SIZE]) state <= 21 ; else state <= 33; end 
  35: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 36; end 
  36: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'h01) state <= 37; else if (statecounter[SC_SIZE]) state <= 21 ; else state <= 35; end 
  37: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 38; end  38: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'hAA) state <= 39; else if (statecounter[SC_SIZE]) state <= 21 ; else state <= 37; end 
  39: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 40; end
	  

  40: begin                     statecounter <= 5;                                       RES_STB <= 0;                         if (RES_BUSY==0) state <= 42; end
 // 41: begin                                       statecounter <= 15;                   state <= 42; end

      //wys³anie komendy CMD55	pe³na inicjalizacja											                                           			  
  42: begin CS<=0; W_DATA <= 8'b01110111; W_STB <= W_READY && !R_STB;  RES_STB <= 0;                            if (R_STB)   state <= 43; end
  43: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 44; end
  44: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 45; end
  45: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 46; end
  46: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 47; end
  47: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 48; end
  
      //czekanie na odpowiedz po CMD55
  48: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 49; end
  49: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	 if (RES_DATA==8'h01) state <= 50; else if (statecounter[SC_SIZE]) state <= 40 ; else state <= 48; end
  50: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 51; end

      //wys³anie komendy ACMD41													                                           			  
  51: begin CS<=0; W_DATA <= 8'b01101001; W_STB <= W_READY && !R_STB;  RES_STB <= 0;                            if (R_STB)   state <= 52; end
  52: begin CS<=0; W_DATA <= 8'b01000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 53; end
  53: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 54; end
  54: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 55; end
  55: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 56; end
  56: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 57; end
																																	  
      //czekanie na odpowiedz po ACMD41                                                                                               
  57: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 58; end
  58: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'h00) state <= 59; else if (statecounter[SC_SIZE]) state <= 40; else state <= 57; end
  59: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 159; end

//------------------------
  159: begin                           statecounter <= 5;                                 RES_STB <= 0;                         if (RES_BUSY==0) state <= 162; end
 // 160: begin                                       statecounter <= 15;  RES_STB <= 0;                 state <= 162; end


	  //wys³anie komendy CMD59
  162: begin CS<=0; W_DATA <= 8'b01111011; 		W_STB <= W_READY && !R_STB; RES_STB <= 0;                             if (R_STB)   state <= 163; end
  163: begin CS<=0; W_DATA <= 8'b00000000;		W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 164; ADDR <= ADDR<<8;end end
  164: begin CS<=0; W_DATA <= 8'b00000000;		W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 165; ADDR <= ADDR<<8;end end
  165: begin CS<=0; W_DATA <= 8'b00000000;		W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 166; ADDR <= ADDR<<8;end end
  166: begin CS<=0; W_DATA <= 8'b00000000; 		W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 167; end
  167: begin CS<=0; W_DATA <= 8'b00000000; 		W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 168; end


  168: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 169; end
  169: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'h00) state <= 170; else if (statecounter[SC_SIZE]) state <= 159 ; else state <= 168; end
  170: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 60; end




  60: begin CS<=1; statecounter_wr <= 510; statecounter_rd <= 514; statecount <= 15; WR_ACK <= 0; RD_ACK <= 0; RES_STB <= 0; if (WR_STB) begin ADDR <= WR_ADDR; len_counter <= WR_LENGTH-2; state <= 61; end else if (RD_STB) begin ADDR <= RD_ADDR;  len_counter <= RD_LENGTH-2; state <= 109; end end


//-----------------------------------------------------------------------------------------------------
//---------zapis multiblock

  61: begin CS<=1; 			            W_STB <= 0;             RES_STB <= 0;        RES_DATA <= "z";        state <= 240; end  //RES_STB <= 1; - dla wys³ania znaku "z"    


  240: begin                     statecounter <= 5;                 RES_STB <= 0;                         if (RES_BUSY==0) state <= 62; end

      //wys³anie komendy CMD25 zapis wielu bloków
  62: begin CS<=0; W_DATA <= 8'b01011001; 		W_STB <= W_READY && !R_STB; RES_STB <= 0;                             if (R_STB)   state <= 63; end
  63: begin CS<=0; W_DATA <= ADDR[31:24];		W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 64; ADDR <= ADDR<<8;end end
  64: begin CS<=0; W_DATA <= ADDR[31:24];		W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 65; ADDR <= ADDR<<8;end end
  65: begin CS<=0; W_DATA <= ADDR[31:24];		W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 66; ADDR <= ADDR<<8;end end
  66: begin CS<=0; W_DATA <= ADDR[31:24]; 		W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 67; end
  67: begin CS<=0; W_DATA <= 8'b11111111; 		W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 68; end
  
  68: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 69; end
  69: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'h00) state <= 70; else if (statecounter[SC_SIZE]) state <= 240 ; else state <= 68; end
  70: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 82; end
 
  // Token do CMD25
  82:  begin CS<=0; W_DATA <= 8'b11111100; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 83; end	

  // petla 512 bajtow
  83: begin CS<=0; ADDR[31:24] <= WD_DATA; W_STB <= 0;                 WD_ACK <= WD_STB;  		RES_STB <= 0;		         if (WD_STB)  state <= 84; end
  84: begin CS<=0; W_DATA <= ADDR[31:24];	W_STB <= W_READY && !R_STB; WD_ACK <= 0;                             if (R_STB)   state <= 85; end
  85: begin CS<=0;                          W_STB <= 0;      statecounter_wr <=statecounter_wr-1;                      if (statecounter_wr[SC_SIZE]) state <= 86; else state <= 83; end

  86:  begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 87; end	
  87:  begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 88; end	  
  88:  begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 89; end		  
  89:  begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 190; end	  190:  begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 90; end	

  90: begin CS<=0;  statecounter_wr <= 510;    W_STB <= 0;      len_counter <=len_counter-1;                      if (len_counter[LEN_WIDTH-1]) state <= 94; else state <= 82; end	  
  94:  begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 95; end	  
  95:  begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 96; end	
  96:  begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 97; end	
  97:  begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 98; end	
  98:  begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 100; end	


		//stop train CMD25
  100:  begin CS<=0; W_DATA <= 8'b11111101; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 101; end

  101:  begin statecounter <= 5; CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 102; end	
  
  102: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 103; end
  103: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'h00) state <= 104; else if (statecounter[SC_SIZE]) state <= 101 ; else state <= 102; end
  104: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 106; end
 

  106: begin CS<=1;                         W_STB <= 0;                                              			  state <= 107; end 
  107: begin CS<=1; 			            W_STB <= 0;             RES_STB <= 0;        RES_DATA <= "Z";         state <= 108; end //RES_STB <= 1; - dla wys³ania "Z"
  108: begin CS<=1;                                                 WR_ACK <= 1; 		 RES_STB <= 0;            state <= 60;  end
	

//------------------------------------------------------------------------------------
//------------odczyt multiblock

  109: begin CS<=1; 			            W_STB <= 0;             RES_STB <= 0;        RES_DATA <= "o";        state <= 110; end  //RES_STB <= 1; - dla wys³ania znaku "o"

  22: begin                     statecounter <= 5;                 RES_STB <= 0;                         if (RES_BUSY==0) state <= 110; end

       //wys³anie komendy CMD18										                                           			  
  110: begin CS<=0; W_DATA <= 8'b01010010; 	 	W_STB <= W_READY && !R_STB; RES_STB <= 0;                             if (R_STB)   state <= 111; end
  111: begin CS<=0; W_DATA <= ADDR[31:24];		W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 112; ADDR <= ADDR<<8;end end
  112: begin CS<=0; W_DATA <= ADDR[31:24];		W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 113; ADDR <= ADDR<<8;end end
  113: begin CS<=0; W_DATA <= ADDR[31:24];		W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 114; ADDR <= ADDR<<8;end end
  114: begin CS<=0; W_DATA <= ADDR[31:24];		W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 115; end
  115: begin CS<=0; W_DATA <= 8'b11111111; 		W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 116; end
																																	  
	
	  //czekanie na odpowiedz po CMD18  
  116: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= 0;    RES_DATA <= R_DATA; if (R_STB)   state <= 117; end   //RES_STB <= R_STB;
  117: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	if (RES_DATA==8'h00) state <= 118; else if (statecounter[SC_SIZE]) state <= 22; else state <= 116; end
  118: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= 0;    RES_DATA <= R_DATA; if (R_STB)   state <= 120; end  //RES_STB <= R_STB;
	  
	  
		//token do CMD18
  120: begin CS<=0; W_DATA <= 8'b11111110; W_STB <= W_READY && !R_STB;  RES_STB <= 0;    RES_DATA <= R_DATA; if (R_STB)   state <= 122; end  //RES_STB <= R_STB;	
	  
  // petla 512 bajtow
  122: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= 0;    RES_STB <= R_STB;          RES_DATA <= R_DATA;  if (R_STB)   state <= 123; end // RES_DATA,  wzedzie indziej DBG_DATA
  123: begin CS<=0;                        W_STB <= 0;      RES_STB <= 0; statecounter_rd <=statecounter_rd-1;      if (statecounter_rd[SC_SIZE]) state <= 124 ; else state <= 122; end
	
  124: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  if (len_counter[LEN_WIDTH-1]) begin RES_STB <= 0; end else begin RES_STB <= R_STB; end     RES_DATA <= R_DATA; if (R_STB)   state <= 125; end  //odebranie koñca bloku
  125: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= 0;    	  RES_DATA <= R_DATA; if (R_STB)   state <= 126; end  //RES_STB <= R_STB;	
  126: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= 0;    	  RES_DATA <= R_DATA; if (R_STB)   state <= 127; end  //RES_STB <= R_STB;	 

  127: begin CS<=0;  statecounter_rd <= 514;    W_STB <= 0;      len_counter <=len_counter-1;                      if (len_counter[LEN_WIDTH-1]) state <= 128; else state <= 120; end


  128: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= 0;    RES_DATA <= R_DATA; if (R_STB)   state <= 129; end // RES_STB <= R_STB;
  129: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= 0;    RES_DATA <= R_DATA; if (R_STB)   state <= 130; end	 
  130: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= 0;    RES_DATA <= R_DATA; if (R_STB)   state <= 131; end
  131: begin CS<=1; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= 0;    RES_DATA <= R_DATA; if (R_STB)   state <= 132; end	 


  132: begin                     statecounter <= 5;                     RES_STB <= 0;                         if (RES_BUSY==0) state <= 134; end

       //wys³anie komendy CMD12										                                           			  
  134: begin CS<=0; W_DATA <= 8'b01001100; W_STB <= W_READY && !R_STB; RES_STB <= 0;                             if (R_STB)   state <= 135; end
  135: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 136; ADDR <= ADDR<<8;end end
  136: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 137; ADDR <= ADDR<<8;end end
  137: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 138; ADDR <= ADDR<<8;end end
  138: begin CS<=0; W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 139; end
  139: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 140; end
																																	  	  
      //czekanie na odpowiedz po CMD12
  140: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= 0;    RES_DATA <= R_DATA; if (R_STB)   state <= 141; end  //RES_STB <= R_STB;
  141: begin statecounter <= statecounter-1; W_STB <= 0;                RES_STB <= 0;	 if (RES_DATA==8'h00) state <= 142; else if (statecounter[SC_SIZE]) state <= 132 ; else state <= 140; end
  142: begin CS<=0; W_DATA <= 8'b11111111; W_STB <= W_READY && !R_STB;  RES_STB <= 0;    RES_DATA <= R_DATA; if (R_STB)   state <= 144; end  //RES_STB <= R_STB;
	  
  144: begin CS<=1;                        W_STB <= 0;             RES_STB <= 0;      RES_DATA <= "O";                        state <= 60; end //RES_STB <= 1; - dla wys³ania znaku "O"
  
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