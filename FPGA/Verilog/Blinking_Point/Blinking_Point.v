module Blinking_Point(
	input clock,
	input reset,
	input rate,
	
	output wire clock_out,	
	output wire [17:0] out
);

reg [25:0] period;
reg [25:0] counter;
reg [17:0] register;

wire clock_in, clock_new, clock_deb;
wire rst = !reset;
wire tempo = !rate;

assign out = register;			
assign clock_in = period[25];
assign clock_new = period[counter];
assign clock_out = period[counter];

always @(posedge clock or posedge rst)           
    if(rst)                                   
        period <= 'b0;
    else
        period <= period + 'b1;
		
always @(posedge clock_deb or posedge rst)
	if(rst)
		counter <= 'd25;
	else if (counter == 'd15)
		counter <= 'd25;	
	else
			counter <= counter - 1;

always @ (posedge clock_new or posedge rst)
	if(rst)
		register <= 'd0;
	else if (register == 'd0)
		register <= 17'h00001;   //0_0000_0000_0000_0001;	
	else if (clock_deb)
		register <= 'd0;			
	else 
			register <= register << 1;
	
debouncer debouncer1(
.CLK(clock_in),
.RST(rst), 
.I(tempo),
.O(clock_deb)
);

endmodule
