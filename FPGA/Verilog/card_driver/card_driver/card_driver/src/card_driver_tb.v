`timescale 1 ns / 1 ns

  
module card_driver_tb();
	
reg R, C, WR_S, WR_AC, WD_S, WD_AC, RD_S, RD_AC, RES_S, RES_AC, SCK, MI, MO, CS, C8_temp, C48_temp, T74_temp, W_STB_I_TE; 	   
reg [7:0] WD_D, RES_D, W_DATA_I_TE;
reg [31:0] WR_A, RD_A;
	   

card_driver driver(
.CLOCK50(C), 
.RESET(R), 
.WR_STB(WR_S),
.WR_ADDR(WR_A),
.WR_ACK(WR_AC),
.WD_STB(WD_S),
.WD_DATA(WD_D),
.WD_ACK(WD_AC),
.RD_STB(RD_S),
.RD_ADDR(RD_A),
.RD_ACK(RD_AC),
.RES_STB(RES_S),
.RES_DATA(RES_D),
.RES_ACK(RES_AC),

.MOSI(MO), 
.MISO(MI), 
.SCLK(SCK),
.CS(CS), 

.CLK8_temp(C8_temp),
.CLK48_temp(C48_temp),
.TICK74_temp(T74_temp),

.W_STB_I_TEMP(W_STB_I_TE),
.W_DATA_I_TEMP(W_DATA_I_TE)
);



initial begin
	   R=0;
	#1 R=1;  
	#2 R=0;
end

initial begin
	   C=0;
end

always #1 C = ~C;
 
	
/*	
initial begin
			WR=0;
	#5  	WR=1; WR_DATA=171;
	#8		WR=0; WR_DATA=0;
	//#64	WR=1; WR_DATA=254;
	//#8		WR=0; WR_DATA=0;
end	
*/



   
endmodule	
