`default_nettype none

`timescale 1 ns / 1 ns

  
module testbench();
	
reg R, C, LED;	   

counter count1(.RST(R), .CLK50(C), .LED0(LED));

	   

initial begin
		R=0;
	#20 R=1;  
	#10 R=0;
end


initial begin
	   C=0;
end


always #2 C = ~C;



endmodule	
