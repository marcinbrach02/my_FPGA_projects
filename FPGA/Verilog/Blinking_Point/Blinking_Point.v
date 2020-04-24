module Blinking_Point(
	input clock,
	input reset,
	input rate,
	
	output wire [17:0] wy,
	output wire clock_wy,
	output wire clock_wy2
);

reg [25:0] period;
reg [17:0] register;

reg [25:0] counter;

reg [4:0] count = 5'b0_0001;		

wire clock_deb;
wire clk_new;
wire rst = !reset;
wire tempo = !rate;

debouncer debouncer1 (.CLK(clock), .RST(rst), .I(tempo), .O(clock_deb));

always @(posedge clock or posedge rst)		   
	if(rst) 								  
		period <= 0;
	else
		period <= period + 1;


always @(posedge clock or posedge rst)
	if(rst)
		counter <= 0;
	else if (counter == 0)
		counter <= count;					
	else if(clock_deb == 1)
				counter <= count << 1;

				
				
	
assign clock_wy2 = clock_deb;	

assign clk_new = period[counter];
assign clock_wy = period[counter];


always @ (posedge clk_new or posedge rst)
	if(rst)
		register <= 0;
	else if (register == 0)
		register <= 17'b0_0000_0000_0000_0001;		
	else 
			register <= register << 1;
	
assign wy = register;			

endmodule
