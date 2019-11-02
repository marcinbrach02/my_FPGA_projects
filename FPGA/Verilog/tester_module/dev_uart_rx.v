//**************************************************************************************
// \file
//    dev_uart_rx.v
// \brief
//    receiver for asynchronous uart device
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
//--------------------------------------------------------------------------------------------------
// UART module
//--------------------------------------------------------------------------------------------------
module dev_uart_rx 
(                            //    +------------------------
input  wire        CLK,      // -->| clock signal
input  wire        RST,      // -->| reset signal
input  wire        TIC,      // -->| tick/strobe signal for action.  should be 8x faster than UART baud rate.  eg. 115200*8  Hz
                             //    +------------------------
input  wire        RxD,      // -->| input from PAD.   it is safely latched through 3 registers inside.
                             //    +------------------------
output reg  [7:0]  RxQ,      // <--| received char
output reg         RxSTB     // <--| received char strobe:  blinks just for 1 clock cycle
);                           //    +------------------------

//--------------------------------------------------------------------------------------------------
reg [3:0] RxD_r;
always @(posedge CLK or posedge RST) RxD_r <= (RST) ? 0 : { RxD_r, RxD };
wire RxD_p = RxD_r[3];
//--------------------------------------------------------------------------------------------------
// Local variables
//--------------------------------------------------------------------------------------------------
reg [6:0] rxstate;     
reg [9:0] rxreg;
reg [2:0] rxcnt;
//--------------------------------------------------------------------------------------------------
always @(posedge CLK or posedge RST)
 if(RST) 
  begin 
   rxstate <= 12;
   rxreg   <= 0;
   rxcnt   <= 0;
   RxSTB   <= 0;
   RxQ     <= 0;
  end
 else if (TIC) begin //  TIC !!!!!!!!!!!!!!!!!!
 RxSTB <= 0; 
 casex(rxstate)
  0: begin rxstate <= (RxD_p)?  0 :  1; rxcnt <= 3;                    rxreg <= 0;                end
  1: begin rxstate <= (rxcnt)?  1 :  2; rxcnt <= rxcnt - 1; if(!rxcnt) rxreg <= {RxD_p,rxreg[9:1]}; end // bstart
  2: begin rxstate <= (rxcnt)?  2 :  3; rxcnt <= rxcnt - 1; if(!rxcnt) rxreg <= {RxD_p,rxreg[9:1]}; end // b0
  3: begin rxstate <= (rxcnt)?  3 :  4; rxcnt <= rxcnt - 1; if(!rxcnt) rxreg <= {RxD_p,rxreg[9:1]}; end // b1
  4: begin rxstate <= (rxcnt)?  4 :  5; rxcnt <= rxcnt - 1; if(!rxcnt) rxreg <= {RxD_p,rxreg[9:1]}; end // b2
  5: begin rxstate <= (rxcnt)?  5 :  6; rxcnt <= rxcnt - 1; if(!rxcnt) rxreg <= {RxD_p,rxreg[9:1]}; end // b3
  6: begin rxstate <= (rxcnt)?  6 :  7; rxcnt <= rxcnt - 1; if(!rxcnt) rxreg <= {RxD_p,rxreg[9:1]}; end // b4
  7: begin rxstate <= (rxcnt)?  7 :  8; rxcnt <= rxcnt - 1; if(!rxcnt) rxreg <= {RxD_p,rxreg[9:1]}; end // b5
  8: begin rxstate <= (rxcnt)?  8 :  9; rxcnt <= rxcnt - 1; if(!rxcnt) rxreg <= {RxD_p,rxreg[9:1]}; end // b6
  9: begin rxstate <= (rxcnt)?  9 : 10; rxcnt <= rxcnt - 1; if(!rxcnt) rxreg <= {RxD_p,rxreg[9:1]}; end // b7
  10:begin rxstate <= (rxcnt)? 10 : 11; rxcnt <= rxcnt - 1; if(!rxcnt) rxreg <= {RxD_p,rxreg[9:1]}; end // bstop
  11:begin rxstate <=                0; RxSTB <= 1; RxQ <= rxreg[8:1]; end 
  12:begin rxstate <= (RxD_p)?  0 :  12;rxcnt <= 3;                    rxreg <= 0;                end
 endcase
 end else RxSTB   <= 0;  //  ~TIC !!!!!!!!!!!!!!!!!!
//--------------------------------------------------------------------------------------------------
endmodule
// todo:
// powinnismy miec duzy, powolny licznik,   MHZ / 115200, dokladnie wyznaczajacy kiedy wysylac kolejne bity.
// TX - licznik powinien sie zerowac i liczyc dopiero jak zaczynamy wysylac.  tzn. wyslalismy bit stopu to mozemy od razu zaczac wysylac od nowa
// RX - bitowo powinnismy czekac az nastapi poczatek, potem odczekiwaæ polowe okresu i odbierac.,
