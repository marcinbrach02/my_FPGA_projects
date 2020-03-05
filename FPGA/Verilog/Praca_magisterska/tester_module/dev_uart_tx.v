//**************************************************************************************
// \file
//    dev_uart_tx.v
// \brief
//    transceiver for asynchronous uart device
// \author
//    Main contributors
//      - Adam Luczak         <mailto:aluczak@multimedia.edu.pl>
//      - Olgierd Stankiewicz <mailto:ostank@multimedia.edu.pl>
//      - Marta Stepniewska   <mailto:mstep@multimedia.edu.pl>
//      - Pawel Garstecki     <mailto:pgarstec@multimedia.edu.pl>
//**************************************************************************************
`default_nettype none
//-------------------------------------------------------------------------------------------------
`timescale 1ns / 1ns
//-------------------------------------------------------------------------------------------------
// UART module
//--------------------------------------------------------------------------------------------------

module dev_uart_tx 
(                                  //    +------------------------
input  wire        CLK,            // -->| clock signal
input  wire        RST,            // -->| reset signal
input  wire        TIC,            // -->| tick/strobe signal for action. should be at the same spped as UART baud rate.  eg. 115200 Hz          
                                   //    +------------------------
output wire        TxD,            // <--| transmitt output to PAD
                                   //    +------------------------
input  wire        TX_STB,         // -->| strobe for transmission. this is read only when (TX_RDY && TIC)
input  wire [7:0]  TX_DATA,        // -->| this is read after reading TX_STB                       
output wire        TX_ACK,         // <--| this is assrted to 1 for the time when data is being transmitted. so actually the data is received when TX_ACK go back to 0
output wire        TX_RDY          // <--| ready for next transmistion, but only used wheb (TIC)
);                                 //    +------------------------ // TX_RDY is asseted before TX_ACK falls down
//--------------------------------------------------------------------------------------------------
// local variables
//--------------------------------------------------------------------------------------------------
reg [3:0] txstate;     
reg [9:0] txreg;
reg       txack;
reg       txrdy;
//--------------------------------------------------------------------------------------------------
always@(posedge CLK or posedge RST)
 if(RST) 
  begin
   txstate <= 0;
   txreg   <= 10'h3FF;
   txack   <= 0;
   txrdy   <= 1;
  end
 else // if(TIC)
  casex(txstate)
   /*0 :         begin txstate <= (TX_STB)? 1 : 0; txrdy <= ~TX_STB; txack <= #1 0;                            end // WTF???? opoznienia o #1 ?????
   1 : if(TIC) begin txstate <=               2; txrdy <= 0; txack <= #1 1; txreg <= #1 {1'b1,TX_DATA,1'b0}; end // BS
   2 : if(TIC) begin txstate <=               3; txrdy <= 0; txack <= #1 1; txreg <= #1 {1'b1,txreg[9:1]};   end // B7
   3 : if(TIC) begin txstate <=               4; txrdy <= 0; txack <= #1 1; txreg <= #1 {1'b1,txreg[9:1]};   end // B6
   4 : if(TIC) begin txstate <=               5; txrdy <= 0; txack <= #1 1; txreg <= #1 {1'b1,txreg[9:1]};   end // B5
   5 : if(TIC) begin txstate <=               6; txrdy <= 0; txack <= #1 1; txreg <= #1 {1'b1,txreg[9:1]};   end // B4
   6 : if(TIC) begin txstate <=               7; txrdy <= 0; txack <= #1 1; txreg <= #1 {1'b1,txreg[9:1]};   end // B3
   7 : if(TIC) begin txstate <=               8; txrdy <= 0; txack <= #1 1; txreg <= #1 {1'b1,txreg[9:1]};   end // B2
   8 : if(TIC) begin txstate <=               9; txrdy <= 0; txack <= #1 1; txreg <= #1 {1'b1,txreg[9:1]};   end // B1
   9 : if(TIC) begin txstate <=              10; txrdy <= 0; txack <= #1 1; txreg <= #1 {1'b1,txreg[9:1]};   end // B0
  10 : if(TIC) begin txstate <=               0; txrdy <= 1; txack <= #1 1; txreg <= #1 {1'b1,txreg[9:1]};   end // BS*/
  
//   0 :         begin txstate <= (TX_STB)? 1 : 0; txrdy <= ~TX_STB; txack <= #1 0;                               end // WTF???? opoznienia o #1 ?????
   0:  txstate <= 1;
   1 : if(TIC) begin txstate <= (TX_STB)? 2 : 1; txrdy <= ~TX_STB; txack <= #1 TX_STB; txreg <= #1 {1'b1,TX_DATA,~TX_STB}; end // BS
   2 : if(TIC) begin txstate <=               3; txrdy <= 0;       txack <= #1 1;      txreg <= #1 {1'b1,txreg[9:1]};      end // B7
   3 : if(TIC) begin txstate <=               4; txrdy <= 0;       txack <= #1 1;      txreg <= #1 {1'b1,txreg[9:1]};      end // B6
   4 : if(TIC) begin txstate <=               5; txrdy <= 0;       txack <= #1 1;      txreg <= #1 {1'b1,txreg[9:1]};      end // B5
   5 : if(TIC) begin txstate <=               6; txrdy <= 0;       txack <= #1 1;      txreg <= #1 {1'b1,txreg[9:1]};      end // B4
   6 : if(TIC) begin txstate <=               7; txrdy <= 0;       txack <= #1 1;      txreg <= #1 {1'b1,txreg[9:1]};      end // B3
   7 : if(TIC) begin txstate <=               8; txrdy <= 0;       txack <= #1 1;      txreg <= #1 {1'b1,txreg[9:1]};      end // B2
   8 : if(TIC) begin txstate <=               9; txrdy <= 0;       txack <= #1 1;      txreg <= #1 {1'b1,txreg[9:1]};      end // B1
   9 : if(TIC) begin txstate <=              10; txrdy <= 0;       txack <= #1 1;      txreg <= #1 {1'b1,txreg[9:1]};      end // B0
  10 : if(TIC) begin txstate <=               0; txrdy <= 1;       txack <= #1 0;      txreg <= #1 {1'b1,txreg[9:1]};      end // BS

endcase
//--------------------------------------------------------------------------------------------------
assign TX_ACK = txack;
assign TX_RDY = txrdy;
assign TxD    = txreg[0];
//--------------------------------------------------------------------------------------------------
endmodule
