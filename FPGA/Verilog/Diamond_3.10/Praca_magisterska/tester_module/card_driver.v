`timescale 1 ns / 1 ns
`default_nettype none

module card_driver
#(
  parameter ADDR_WIDTH=32,
  parameter LEN_WIDTH=24
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


    output reg       RES_STB,
	output reg       RES_DEBUG,
    output reg [7:0] RES_DATA,
    input  wire      RES_BUSY,       
       
       
    output wire MOSI,
    input  wire MISO,
    output wire SCLK,
    output reg  CS
                                    
);        

/*
parameter DIVIDER = 5;
                               
localparam DIVIDER_WIDTH = 9; // log2(255)

reg [DIVIDER_WIDTH-1:0] tickcounter;     
wire TICK = tickcounter[DIVIDER_WIDTH-1];

always @(posedge CLK or posedge RST) tickcounter <= (RST) ? DIVIDER-1 : (TICK) ? DIVIDER-1 : tickcounter-1;
*/

parameter START_DIVIDER = 5;
parameter TRANSMISSION_DIVIDER = 4; //START_DIVIDER;
                               
localparam DIVIDER_WIDTH = 9; 

reg [DIVIDER_WIDTH-1:0] tickcounter;
wire TICK = tickcounter[DIVIDER_WIDTH-1];

reg [DIVIDER_WIDTH-1:0] divider_m1;

always @(posedge CLK or posedge RST) 
    tickcounter <= (RST) ? START_DIVIDER-1 : (TICK) ? divider_m1 : tickcounter-1;


reg [7:0] state;

reg W_STB;
reg [7:0] W_DATA; 
wire W_READY;

wire R_STB;
wire [7:0] R_DATA;

reg RES_DATA_IS_00;
reg RES_DATA_IS_01;
reg RES_DATA_IS_AA;
reg RES_DATA_IS_FF;
	
localparam SC_SIZE = 11;

reg [SC_SIZE:0] statecnt; // [8:0] to 511..00    [9:0] 511..0, -1

reg [SC_SIZE:0] statecnt_wr;
reg [SC_SIZE:0] statecnt_rd;


reg [ADDR_WIDTH-1:0] shreg;
reg [LEN_WIDTH-1:0] len_counter;


always@(posedge CLK or posedge RST)    
if (RST) begin
    state <= 0;
    CS <= 1;
    W_STB <= 0;
    W_DATA <= 0; 
    RES_STB <= 0;
	RES_DEBUG <= 1;	
    RES_DATA <= 0;
    statecnt <= 0;
    statecnt_wr <= 0;    
    statecnt_rd <= 0;
    shreg <= 0;
	WR_ACK <= 0; 
	WD_ACK <= 0; 
	RD_ACK <= 0; 
    len_counter <= 0;
    divider_m1 <= START_DIVIDER-1;
    RES_DATA_IS_00 <= 0;
    RES_DATA_IS_01 <= 0;
    RES_DATA_IS_AA <= 0;
    RES_DATA_IS_FF <= 0;	
end else begin // default	
	CS <= 0; 
    W_STB <= 0;
    W_DATA <= 0; 
    RES_STB <= 0;
    RES_DATA <= 0;
	WR_ACK <= 0; 
	WD_ACK <= 0; 
	RD_ACK <= 0; 
	W_DATA <= 8'b11111111;
	RES_DEBUG <= 1;
	RES_DATA <= R_DATA;
	RES_DATA_IS_00 <= R_DATA==8'h00;
    RES_DATA_IS_01 <= R_DATA==8'h01;
    RES_DATA_IS_AA <= R_DATA==8'hAA;
    RES_DATA_IS_FF <= R_DATA==8'hFF;	
	
case(state)
  0:  begin                                                                                 CS<=1;  if (RES_BUSY==0) state <= 1; end
  1:  begin                                statecnt <= 15;  RES_STB <= 1; RES_DATA <= "S";  CS<=1;                   state <= 2; end
    
      //inicjalizacja 74 takty CS=1, MOSI=1
  2:  begin                        W_STB <= W_READY && !R_STB;                                  CS<=1;   if (R_STB)   state <=  3; end
  3:  begin                        W_STB <= W_READY && !R_STB;                                  CS<=1;   if (R_STB)   state <=  4; end
  4:  begin                        W_STB <= W_READY && !R_STB;                                  CS<=1;   if (R_STB)   state <=  5; end
  5:  begin                        W_STB <= W_READY && !R_STB;                                  CS<=1;   if (R_STB)   state <=  6; end
  6:  begin                        W_STB <= W_READY && !R_STB;                                  CS<=1;   if (R_STB)   state <=  7; end
  7:  begin                        W_STB <= W_READY && !R_STB;                                  CS<=1;   if (R_STB)   state <=  8; end
  8:  begin                        W_STB <= W_READY && !R_STB;                                  CS<=1;   if (R_STB)   state <=  9; end
  9:  begin                        W_STB <= W_READY && !R_STB;                                  CS<=1;   if (R_STB)   state <=  10; end
  10: begin                        W_STB <= W_READY && !R_STB;                                  CS<=1;   if (R_STB)   state <=  11; end
  11: begin                        W_STB <= W_READY && !R_STB;                                  CS<=1;   if (R_STB)   state <=  12; end
      
      //wys³anie komendy resetu CMD0                                                                                                             
  12: begin W_DATA <= 8'b01000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 13; end // 0x40
  13: begin W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 14; end
  14: begin W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 15; end
  15: begin W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 16; end
  16: begin W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 17; end
  17: begin W_DATA <= 8'b10010101; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 19; end // 0x95  GoIdle
  
      //czekanie na odpowiedz po inicjalizacji
  18: begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 19; end
  19: begin statecnt <= statecnt-1;                                              if (RES_DATA_IS_01) state <= 20; else if (statecnt[SC_SIZE]) state <= 0 ; else state <= 18; end
  20: begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 21; end
      
  21:  begin statecnt <= 15;                                        if (RES_BUSY==0) state <= 23; end
//22:  begin statecnt <= 15;                                                         state <= 23; end

      //wys³anie komendy CMD8    //sprawdzenie versji i potwierdzenia zasilanie 2,7-3,6 V (arg: 0x1AA    checksum: 0x87)                                                                                             
  23: begin W_DATA <= 8'b01001000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 24; end // 0x48
  24: begin W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 25; end
  25: begin W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 26; end
  26: begin W_DATA <= 8'b00000001; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 27; end
  27: begin W_DATA <= 8'b10101010; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 28; end // 0xAA
  28: begin W_DATA <= 8'b10000111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 29; end // 0x87
                                                                                                                                      
      //oczekiwanie na odpowiedz po CMD8                                                                                                  
  29: begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 30; end
  30: begin statecnt <= statecnt-1;                                                if (RES_DATA_IS_01) state <= 31; else if (statecnt[SC_SIZE]) state <= 21 ; else state <= 29; end 
  31: begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 32; end 
  32: begin statecnt <= statecnt-1;                                                if (RES_DATA_IS_00) state <= 33; else if (statecnt[SC_SIZE]) state <= 21 ; else state <= 31; end 
  33: begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 34; end  
  34: begin statecnt <= statecnt-1;                                                if (RES_DATA_IS_00) state <= 35; else if (statecnt[SC_SIZE]) state <= 21 ; else state <= 33; end 
  35: begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 36; end 
  36: begin statecnt <= statecnt-1;                                                if (RES_DATA_IS_01) state <= 37; else if (statecnt[SC_SIZE]) state <= 21 ; else state <= 35; end 
  37: begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 38; end
  38: begin statecnt <= statecnt-1;                                                if (RES_DATA_IS_AA) state <= 39; else if (statecnt[SC_SIZE]) state <= 21 ; else state <= 37; end 
  39: begin CS<=1;                 W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; CS<=1; if (R_STB)   state <= 40; end
      // czemu CS=1

  40: begin statecnt <= 5;                                     if (RES_BUSY==0) state <= 42; end
//41: begin statecnt <= 15;                                                     state <= 42; end

  // pe³na inicjalizacja     
  42: begin W_DATA <= 8'b01110111; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 43; end // 0x77  CMD55 = APP SPECIFIC
  43: begin W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 44; end
  44: begin W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 45; end
  45: begin W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 46; end
  46: begin W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 47; end
  47: begin                        W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 48; end // 0xFF
  
      //czekanie na odpowiedz po CMD55
  48: begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 50; end
//49: begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 50; end
  50: begin statecnt <= statecnt-1;                                               if (RES_DATA_IS_01) state <= 51; else if (statecnt[SC_SIZE]) state <= 40 ; else if (RES_BUSY==0) state <= 48; end
  51: begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 52; end


      //wys³anie komendy ACMD41                                                                                                             
  52: begin W_DATA <= 8'b01101001; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 53; end // 0x69   SD_SEND_OP_COND 
  53: begin W_DATA <= 8'b01000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 54; end
  54: begin W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 55; end
  55: begin W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 56; end
  56: begin W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 57; end
  57: begin                        W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 58; end
                                                                                                                                      
      //czekanie na odpowiedz po ACMD41                                                                                               
  58: begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 59; end // rzeczywiscie oczekiwanie na 0x00
  59: begin statecnt <= statecnt-1 ;                                               if (RES_DATA_IS_00) state <= 60; else if (statecnt[SC_SIZE]) state <= 40; else if (RES_BUSY==0) state <= 58; end
  60: begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; CS<=1; if (R_STB)   state <= 61; end
      // czemu CS=1?


  61: begin statecnt <= 5;                                                            if (RES_BUSY==0) state <= 62; end

      //wys³anie komendy CMD59 - wy³¹czenie sum kontrolnych CRC
  62: begin W_DATA <= 8'b01111011;         W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 63; end  // 0x7B
  63: begin W_DATA <= 8'b00000000;         W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 64; shreg <= shreg<<8;end end
  64: begin W_DATA <= 8'b00000000;         W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 65; shreg <= shreg<<8;end end
  65: begin W_DATA <= 8'b00000000;         W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 66; shreg <= shreg<<8;end end
  66: begin W_DATA <= 8'b00000000;         W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 67; end
  67: begin W_DATA <= 8'b00000000;         W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 68; end


  68: begin                                W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 69; end
  69: begin statecnt <= statecnt-1;                                                if (RES_DATA_IS_00) state <= 70; else if (statecnt[SC_SIZE]) state <= 61 ; else state <= 68; end
  70: begin                                W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 71; end


//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------

  71: begin CS<=1; divider_m1 <= TRANSMISSION_DIVIDER-1;       if (TICK) state <= 72; end
      
  72: begin CS<=1; if (WR_STB) state <= 80; else if (RD_STB) state <= 158; end
	


//-----------------------------------------------------------------------------------------------------
//---------zapis multiblock

  80: begin                                                      RES_STB <= 1;        RES_DATA <= "z";     state <= 81; end  //RES_STB <= 1; - dla wys³ania znaku "z"    

  81: begin statecnt <= 15;  len_counter <= WR_LENGTH;                                                    if (RES_BUSY==0) state <= 82;  end

// wait for not busy	
  82: begin                                W_STB <= W_READY && !R_STB;                       RES_DATA <= R_DATA; if (R_STB)   state <= 83; end
  83: begin                                                                              if (RES_DATA_IS_FF) state <= 110; else state <= 82; end
//83: begin                                                                              if (RES_DATA_IS_FF) state <= 84; else state <= 82; end
	  /*
  //wys³anie komendy CMD55 
  84: begin W_DATA <= 8'b01110111;  W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 85; end     // 0x77  CMD55 = APP SPECIFIC                                                                                                      
  85: begin W_DATA <= 8'b00000000;  W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 86; end 
  86: begin W_DATA <= 8'b00000000;  W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 87; end
  87: begin W_DATA <= 8'b00000000;  W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 88; end
  88: begin W_DATA <= 8'b00000000;  W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 89; end
  89: begin                         W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 90; end
      
      //czekanie na odpowiedz po CMD55   //01
  90: begin                         W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 91; end
  91: begin statecnt <= statecnt-1;                                               if (RES_DATA_IS_00) state <= 92; else if (statecnt[SC_SIZE]) state <= 81 ; else state <= 90; end
  92: begin                         W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 94; end

  // wys³anie komendy ACMD23                                                                                         
  94: begin W_DATA <= 8'b01010111;  W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 95; shreg <= WR_LENGTH<<8; end // 0x57
  95: begin W_DATA <= 8'b00000000;  W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 96; end
  96: begin W_DATA <= 8'b00000000;  W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 97; end
  97: begin W_DATA <= shreg[31:24]; W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 98; shreg <= shreg<<8; end end
  98: begin W_DATA <= shreg[31:24]; W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 99; shreg <= shreg<<8; end end
  99: begin W_DATA <= shreg[31:24]; W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 100; shreg <= shreg<<8; end end
            
  // czekanie na odpowiedz po ACMD23                                                                                              
  100: begin                         W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 101; end
  101: begin statecnt <= statecnt-1;                                               if (RES_DATA_IS_00) state <= 102; else if (statecnt[SC_SIZE]) state <= 81; else state <= 100; end
  102: begin                         W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 110; end

*/
  110: begin statecnt <= 15; if (RES_BUSY==0) state <= 111; end

  // wys³anie komendy CMD25 zapis wielu bloków
  111: begin W_DATA <= 8'b01011001;  W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 112;  shreg <= WR_ADDR;  end // MMC_WRITE_MULTIPLE_BLOCK   0x59 
  112: begin W_DATA <= shreg[31:24]; W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 113; shreg <= shreg<<8;end end
  113: begin W_DATA <= shreg[31:24]; W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 114; shreg <= shreg<<8;end end
  114: begin W_DATA <= shreg[31:24]; W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 115; shreg <= shreg<<8;end end
  115: begin W_DATA <= shreg[31:24]; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 116; end
  116: begin                         W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 117; len_counter <= len_counter-1; end; end
  
  117: begin                         W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 118; end
  118: begin statecnt <= statecnt-1;                                               if (RES_DATA_IS_00) state <= 119; else if (statecnt[SC_SIZE]) state <= 81 ; else state <= 117; end
  119: begin                         W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 124; end

//122:  begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 123; end
//123:  begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 124; end

  124:  begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 125; end
	  
  125:  begin statecnt_wr <= 510;    W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 126; end       
  126:  begin                                                                      if (RES_DATA_IS_FF) state <= 131; else state <= 125; end // not busy

  // Token danych po CMD25
  131: begin   W_DATA <= 8'b11111100; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 132; end    //RES_DATA <= R_DATA;  // 0xFC

  // petla zapisu 512 bajtow
  132: begin shreg[31:24] <= WD_DATA;                             WD_ACK <= WD_STB;                      if (WD_STB)  state <= 133; end
  133: begin W_DATA <= shreg[31:24];  W_STB <= W_READY && !R_STB;                                        if (R_STB)   state <= 134; end
  134: begin statecnt_wr <=statecnt_wr-1;                      if (statecnt_wr[SC_SIZE]) state <= 135; else state <= 132; end 

  135: begin                         W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 136; end      
  136: begin                         W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 137; end          
  137: begin                         W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 138; end
  138: begin                         W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   begin state <= 139; len_counter <= len_counter -1; end; end    
                                    
  139: begin if (len_counter[LEN_WIDTH-1]) state <= 140; else state <= 125; end       
           /*                         
  140: begin                         W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 141; end      
  141: begin                         W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 142; end    
  142: begin                         W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 143; end      
  143: begin                         W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 144; end    
  144: begin                         W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 145; end    
*/

  140: begin                         W_STB <= W_READY && !R_STB;                       RES_DATA <= R_DATA; if (R_STB)   state <= 141; end
  141: begin                                                                       if (RES_DATA_IS_FF) state <= 145; else state <= 140; end

  //stop tran po zapisie danych CMD25
  145: begin W_DATA <= 8'b11111101; W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 146; end // 0xFD

  146: begin statecnt <= 15;        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB) state <= 147; end    
  
  147: begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 148; end
  148: begin statecnt <= statecnt-1;                                              if (RES_DATA_IS_00) state <= 149; else if (statecnt[SC_SIZE]) state <= 146 ; else state <= 147; end
  149: begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 150; end


  150: begin CS<=1;                                                                                               state <= 151; end 
  151: begin CS<=1;                         WR_ACK <= 1;                         RES_STB <= 1;        RES_DATA <= "Z";         state <= 152; end //RES_STB <= 1; - dla wys³ania "Z"  
  152: begin CS<=1;                                                                                   state <= 72;  end

//------------------------------------------------------------------------------------
//------------odczyt multiblock

  158: begin                                                              RES_STB <= 1;        RES_DATA <= "o";        state <= 159;   end  //RES_STB <= 1; - dla wys³ania znaku "o"
      
  159: begin len_counter <= RD_LENGTH;      statecnt <= 15; if (RES_BUSY==0) state <= 160; end
	  
  // wait for not busy	
  160: begin                                W_STB <= W_READY && !R_STB;                       RES_DATA <= R_DATA; if (R_STB)   state <= 161; end
  161: begin                                                                              if (RES_DATA_IS_FF) state <= 162; else state <= 160; end

  //wys³anie komendy CMD18                                                                                                 
  162: begin W_DATA <= 8'b01010010;         W_STB <= W_READY && !R_STB;      shreg <= RD_ADDR;                    if (R_STB)   begin state <= 163; len_counter <= len_counter-1; end   end   // MMC_READ_MULTIPLE_BLOCK    0x52     //CMD18
  163: begin W_DATA <= shreg[31:24];        W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 164; shreg <= shreg<<8;end end
  164: begin W_DATA <= shreg[31:24];        W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 165; shreg <= shreg<<8;end end
  165: begin W_DATA <= shreg[31:24];        W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 166; shreg <= shreg<<8;end end
  166: begin W_DATA <= shreg[31:24];        W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 167; end
  167: begin                                W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 168; end
                                                                                                                                      
    
  //czekanie na odpowiedz po CMD18  
  168: begin                                W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 169; end   
  169: begin statecnt <= statecnt-1;                                               if (RES_DATA[7]==0) state <= 171; else if (statecnt[SC_SIZE]) state <= 159; else state <= 168; end
//170: begin                                W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA; if (R_STB)   state <= 171; end  
        
        

  // czekanie na token FE
  171: begin statecnt <= 345;  statecnt_rd <= 510;                       RES_STB <= 1;        RES_DATA <= "#";  state <= 172;         end
  172: begin                                W_STB <= W_READY && !R_STB;                       RES_DATA <= R_DATA; if (R_STB)   state <= 173; end  
  173: begin                                                                              if (!RES_DATA_IS_FF) state <= 183; else state <= 172; end

  
  // petla 512 bajtow
  183: begin                                W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;    RES_DATA <= R_DATA;  RES_DEBUG <= 0; if (R_STB)   state <= 184; end 
  184: begin statecnt_rd <=statecnt_rd-1;  RES_DEBUG <= 0; if (statecnt_rd[SC_SIZE]) state <= 185 ; else state <= 183; end
    
    
  185: begin                                W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;          RES_DATA <= R_DATA; if (R_STB)   begin state <= 186; len_counter <= len_counter-1;end; end // CRC
  186: begin                                W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;          RES_DATA <= R_DATA; if (R_STB)   state <= 188; end // CRC
//187: begin                                W_STB <= W_READY && !R_STB;  RES_STB <= R_STB;          RES_DATA <= R_DATA; if (R_STB)   state <= 188; end // ?

  188: begin if (len_counter[LEN_WIDTH-1]) state <= 193; else state <= 171; end

  193: begin statecnt <= 15; if (RES_BUSY==0) state <= 194; end

       //wys³anie komendy CMD12                                                                                                 
  194: begin W_DATA <= 8'b01001100; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 195; end // MMC_STOP_TRANSMISSION      0x4c     //CMD12
  195: begin W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 196; shreg <= shreg<<8;end end
  196: begin W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 197; shreg <= shreg<<8;end end
  197: begin W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   begin state <= 198; shreg <= shreg<<8;end end
  198: begin W_DATA <= 8'b00000000; W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 199; end
  199: begin                        W_STB <= W_READY && !R_STB;                                           if (R_STB)   state <= 200; end
                                                                                                                                            
      //czekanie na odpowiedz po CMD12
  200: begin                        W_STB <= W_READY && !R_STB;  RES_STB <= R_STB; RES_DATA <= R_DATA; if (R_STB)   state <= 201; end  //RES_STB <= R_STB;
  201: begin statecnt <= statecnt-1;                                           if (RES_DATA[7]==0) state <= 202; else if (statecnt[SC_SIZE]) state <= 193; else state <= 200; end
  202: begin                        W_STB <= W_READY && !R_STB;                    RES_DATA <= R_DATA; if (R_STB)   state <= 203; end  //RES_STB <= R_STB;


  203: begin CS<=1;                                                                                                state <= 204; end 
  204: begin CS<=1;                               RD_ACK <= 1;                 RES_STB <= 1;      RES_DATA <= "O";             state <= 205; end //RES_STB <= 1; - dla wys³ania znaku "O"
  205: begin CS<=1;                                                                                                state <= 72; end 
  
  
endcase
end

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