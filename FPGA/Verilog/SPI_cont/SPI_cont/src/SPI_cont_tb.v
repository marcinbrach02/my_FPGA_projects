`timescale 1 ns / 1 ns

  
module SPI_cont_tb();
	
reg R, C, WAC, WR, RAC, RD, SCK, MI, MO; 	   
reg [7:0] WR_DATA, RD_DATA;


SPI_cont SPI(.IN_SCLK(C), .RST(R), .W_STB(WR), .W_DATA(WR_DATA), .W_ACK(WAC), .R_STB(RD), .R_DATA(RD_DATA), .R_ACK(RAC), .MOSI(MO), .MISO(MI), .SCLK(SCK) );





initial begin
	   R=0;
	#1 R=1;  
	#2 R=0;
end

initial begin
	   C=0;
end

always #1 C = ~C;

initial begin
			WR=0;
	#5  	WR=1; WR_DATA=171;
	#8		WR=0; WR_DATA=0;
	//#64	WR=1; WR_DATA=254;
	//#8		WR=0; WR_DATA=0;
end	


 
reg [7:0] do_wysylki;
reg ready;
reg [3:0] peri;


always @(negedge SCK ) 
begin	
	if(WAC)
		begin
		do_wysylki = 8'b0010_1001;
		ready <= 1;
		peri = 8;	
		end
	else if(ready)	
		begin
		MI <= do_wysylki[7];
		do_wysylki <= do_wysylki << 1;	 
		peri = peri - 1;			
			if(peri[3])
				begin
				ready <= 0;
				MI <= 1;
				end
		end	 
	else
		MI <= 1;
end
   
endmodule	
