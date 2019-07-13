module Blinking_LED
(
	output wire LED0,
	output wire LED1,
	input wire CLK50,
	input wire CLK24,
	input wire RST
);	
	reg[31:0] counter;
	reg[31:0] counter2;
		
	wire nRST = !RST;
		
	always@(posedge CLK50 or posedge nRST)
		if(nRST)
			counter = 0;
		else
			counter = counter + 1;
		
	always@(posedge CLK24 or posedge nRST)
		if(nRST)
			counter2 = 0;
		else
			counter2 = counter2 + 1;
		
	assign LED0 = counter[26];
	assign LED1 = counter2[25];
		
endmodule
