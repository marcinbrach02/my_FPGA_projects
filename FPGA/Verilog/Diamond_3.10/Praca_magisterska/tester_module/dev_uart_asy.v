//**************************************************************************************
// \file
//    dev_uart_asy.v
// \brief
//    asynchronous to synchonous converter for asynchronous uart device
// \author
//    Main contributors
//      - Adam Luczak         <mailto:aluczak@multimedia.edu.pl>
//      - Olgierd Stankiewicz <mailto:ostank@multimedia.edu.pl>
//      - Marta Stepniewska   <mailto:mstep@multimedia.edu.pl>
//      - Pawe? Garstecki     <mailto:pgarstec@multimedia.edu.pl>
//**************************************************************************************
`default_nettype none
//-------------------------------------------------------------------------------------------------
`timescale 1ns / 1ns
//-------------------------------------------------------------------------------------------------
module dev_uart_asy
(                                  //    +------------------------+
input  wire        CLK,            // -->| clock signal
input  wire        RST,            // -->| reset signal
                                   //    +------------------------+
input  wire        RxD_PIN,        // -->| input pad from UART transmission
output wire        TxD_PIN,        // <--| output pad from UART transmission
                                   //    +------------------------+
output reg         RX_STB,         // <--| chyba full-hand shake receive
output reg   [7:0] RX_DAT,         // <--|
input  wire        RX_ACK,         // -->|
                                   //    +------------------------+
input  wire        TX_STB,         // -->| chyba full-hand shake send
input  wire  [7:0] TX_DAT,         // -->|
output reg         TX_ACK,         // <--|
output reg         TX_RDY          // <--|
);                                 //    +------------------------+
//-------------------------------------------------------------------------------------------------
parameter  CLK_MHZ = 50;
//-------------------------------------------------------------------------------------------------

reg   [1:0] rxstate;
wire        rxstb;
wire  [7:0] rxq;

reg   [1:0] txstate;
reg         txstb;
wire        txack;
wire        txrdy;
reg   [7:0] txq;
//-------------------------------------------------------------------------------------------------
localparam DIV_C   =  (CLK_MHZ*1_000_00)/(11520*8);                   // liczby w liczniku i mianowniku 10x mniejsze zeby bez przepelnienia.   Zegar 8x szybszy zeby trafix w zbocze
localparam BITS_TOTAL = $clog2(DIV_C);
//-------------------------------------------------------------------------------------------------
reg [BITS_TOTAL:0] counter_fast;
wire tick_fast = counter_fast[BITS_TOTAL];
always@(posedge CLK or posedge RST) counter_fast <= (RST) ? 0 : tick_fast ? (DIV_C-2) : counter_fast-1;    
//-------------------------------------------------------------------------------------------------
// np. dla DIC_C=10:
// 876543210-876543210-
//-------------------------------------------------------------------------------------------------
reg [3:0] counter_slow;
wire tick_slow = counter_slow[3];
always@(posedge CLK or posedge RST) counter_slow <= (RST) ? 0 : tick_slow ? 7 : counter_slow - tick_fast;    
//-------------------------------------------------------------------------------------------------
// ....X.........X.........X.........X.........X.........X.........X.........X.........X.........X.........X.........
// 0000-7777777776666666666555555555544444444443333333333222222222211111111110000000000-77777777766666666666
//-------------------------------------------------------------------------------------------------


/*
// OS: ten kod zrobil Adam L, ale zminilem go na kod powyzej.
reg   [7:0] cnt_lo;
reg   [7:0] cnt_hi;
reg   [3:0] cst;

always@(posedge CLK or posedge RST)
 if(RST) begin cst <=0; cnt_lo <= 0; end
 else 
 casex(cst)
 0: if(cnt_lo==DIV_C + (OFF_C>9)) begin cst <= 1; cnt_lo <= 0; end else cnt_lo <= cnt_lo + 1;
 1: if(cnt_lo==DIV_C + (OFF_C>8)) begin cst <= 2; cnt_lo <= 0; end else cnt_lo <= cnt_lo + 1;
 2: if(cnt_lo==DIV_C + (OFF_C>7)) begin cst <= 3; cnt_lo <= 0; end else cnt_lo <= cnt_lo + 1;
 3: if(cnt_lo==DIV_C + (OFF_C>6)) begin cst <= 0; cnt_lo <= 0; end else cnt_lo <= cnt_lo + 1;
 4: if(cnt_lo==DIV_C + (OFF_C>5)) begin cst <= 1; cnt_lo <= 0; end else cnt_lo <= cnt_lo + 1;
 5: if(cnt_lo==DIV_C + (OFF_C>4)) begin cst <= 2; cnt_lo <= 0; end else cnt_lo <= cnt_lo + 1;
 6: if(cnt_lo==DIV_C + (OFF_C>3)) begin cst <= 3; cnt_lo <= 0; end else cnt_lo <= cnt_lo + 1;
 7: if(cnt_lo==DIV_C + (OFF_C>2)) begin cst <= 3; cnt_lo <= 0; end else cnt_lo <= cnt_lo + 1;
 8: if(cnt_lo==DIV_C + (OFF_C>1)) begin cst <= 0; cnt_lo <= 0; end else cnt_lo <= cnt_lo + 1;
 9: if(cnt_lo==DIV_C + (OFF_C>0)) begin cst <= 0; cnt_lo <= 0; end else cnt_lo <= cnt_lo + 1;
 endcase
//-------------------------------------------------------------------------------------------------
wire   tic_lo = ~(|cnt_lo);
//-------------------------------------------------------------------------------------------------
always@(posedge CLK or posedge RST)
 if(RST)                     cnt_hi <= 0; 
 else if(tic_lo & cnt_hi==7) cnt_hi <= 0;
 else if(tic_lo            ) cnt_hi <= cnt_hi + 1;
//-------------------------------------------------------------------------------------------------
wire   tic_hi = tic_lo & (&cnt_hi[2:0]);
*/
//-------------------------------------------------------------------------------------------------
reg rxstb_and;
//-------------------------------------------------------------------------------------------------
// receiver
//-------------------------------------------------------------------------------------------------
always@(posedge CLK or posedge RST)
 if(RST) 
  begin
   rxstate <= 0; 
   RX_STB  <= 0;
   RX_DAT  <= 0;
   rxstb_and <= 1;
  end
 else
  casex(rxstate) // OS: nie mam pojecia po co ten automat jest.  zeby byl pelen handshake dopoki ktos nie odbierze?  ale ten ponizej zakomentowany wydaje sie byc sensowniejszy  o_O
    0: begin rxstate <= (rxstb) ? 1 : 0; RX_STB <= rxstb; RX_DAT <= rxq; rxstb_and <= 1; end
    1: begin rxstate <= (RX_ACK)? 2 : 1; RX_STB <= ~RX_ACK; rxstb_and <= rxstb_and & rxstb; end
    2: begin rxstate <= (RX_ACK)? 2 : 0; rxstb_and <= rxstb_and & rxstb; end
    default: begin rxstate <= (rxstb & rxstb_and) ? 3 : 0; end    
      /*
  0: begin rxstate <= (rxstb )? 1 : 0; RX_STB <=               0;                 end
  1: begin rxstate <=               2; RX_STB <=               1; RX_DAT <= rxq;  end
  2: begin rxstate <= (RX_ACK)? 3 : 2; RX_STB <=         ~RX_ACK;                 end
  3: begin rxstate <= (RX_ACK)? 3 : 4; RX_STB <=               0;                 end
  4: begin rxstate <= (rxstb )? 4 : 0; RX_STB <=               0;                 end
      */
  endcase
//-------------------------------------------------------------------------------------------------
dev_uart_rx rx
(                          
.CLK       (CLK),          
.RST       (RST),          
.TIC       (tick_fast),    
                           
.RxD       (RxD_PIN),      
                           
.RxSTB     (rxstb),        
.RxQ       (rxq)           
);                         
//-------------------------------------------------------------------------------------------------
// transceiver
//-------------------------------------------------------------------------------------------------
always@(negedge CLK or posedge RST) if (RST) TX_ACK <= #1 0; else TX_ACK <= #1 TX_STB & TX_RDY;
    
always@(posedge CLK or posedge RST)
 if(RST) 
  begin
   txstate <= 0; 
   TX_RDY  <= 1;
   txq     <= 0;
   txstb   <= 0; 
  end
 else
  casex(txstate) // OS: to chyba robi full handshake
  0: begin txstate <= (TX_STB)? 1 : 0; TX_RDY <= ~TX_STB; txstb <= 0; txq   <= TX_DAT; end
  1: begin txstate <=           2;     txstb <= 1; end
  2: begin txstate <= (txack) ? 3 : 2; txstb <= ~txack; end
  default: begin txstate <= (txack) ? 3 : 0; TX_RDY <= ~txack; end
  endcase
//-------------------------------------------------------------------------------------------------
dev_uart_tx tx
(                        
.CLK       (CLK),        
.RST       (RST),        
.TIC       (tick_slow),  
                         
.TxD       (TxD_PIN),    
                         
.TX_STB    (txstb),         
.TX_ACK    (txack),         
.TX_DATA   (txq),        
.TX_RDY    (txrdy)       
);                       
//------------------------------------------------------------------------------------------------
endmodule
