module counter(
	input wire CLK50,
	input wire RST,
	output wire LED0
);

reg [7:0] period;
wire nRST = !RST;


always @(posedge CLK50 or posedge nRST)
	if(nRST == 1) 
		period = 5;
	else
		period = period - 1;

assign LED0 = period[2];



/*
always @(posedge CLK50 or posedge nRST)
	if(nRST | period[26] == 1) 
		period = 50000000;
	else
		period = period - 1;

assign LED0 = period[25];
*/


/*
always @(posedge CLK50 or posedge nRST)
	if(nRST) 
		period = 0;
	else
		period = period + 1;

assign LED0 = period[25];
*/


endmodule