`timescale 1 ns / 1 ns

  
module microSD_tb();
	
reg R, C, WR, RD, SCK, SS, MI, MO; 	   
reg [7:0] WR_DATA, RD_DATA;


microSD micro(.CLK50(C), .RST(R), .W_STB(WR), .W_DATA(WR_DATA), .R_STB(RD), .R_DATA(RD_DATA), .MOSI(MO), .MISO(MI), .CS(SS), .SCLK(SCK) );
	   

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
	#5  WR=1;
	#2	WR=0; 
	#86	WR=1;
	#2	WR=0;
end	
	
initial begin
		WR_DATA=0;
	#5  WR_DATA=171;
	#2	WR_DATA=0;
	#86 WR_DATA=179;
	#2  WR_DATA=0;
end		


initial begin
		  RD=0;
	#165  RD=1;
	#8    RD=0; 

end	
	

endmodule	
