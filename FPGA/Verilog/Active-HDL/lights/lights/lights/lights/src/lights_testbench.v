					 `default_nettype none
`timescale 1 ns / 1 ns

  
module testbench();
	
reg R, C, AR, AY, AG, K, PR, PG;	   


lights ligInst ( .RST(R), .CLOCK(C), .KEY(K), .P_R(PR), .P_G(PG), .A_R(AR), .A_Y(AY), .A_G(AG));

		   

initial begin
		R=0;
	#20 R=1;
end


initial begin
		K=0;
	#30 K=1;
	#20 K=0;	
end


initial begin
	   C=0;
end


always #2 C = ~C;



endmodule	
