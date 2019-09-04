`default_nettype none

`timescale 1 ns / 1 ns

  
module testbench();
	
reg R, C, LED;	   
reg [2:0] T;

counter count1(.RST(R), .CLK50(C), .LED0(LED), .TEMP(T));

	   

initial begin
		R=0;
	#10 R=1;  
	#4 R=0;
end


initial begin
	   C=0;
end


always #2 C = ~C;



endmodule	
