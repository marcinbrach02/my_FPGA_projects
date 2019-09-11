module microSD(
	input wire CLK50,
	input wire RST,
	
	input wire W_STB,
	input wire [7:0] W_DATA,
	
	output wire R_STB,
	output wire [7:0] R_DATA,
	
	output wire MOSI,
	input wire MISO,
	output wire SCLK,
	output wire CS
);

reg [1:0] period;
wire CLK;
reg [47:0] DATA;
reg [2:0] period1;

always @(posedge CLK50 or posedge RST)				//dzielnik czêstotliwoœci do 100 - 400 kHz
	if(RST) 
		period = 0;
	else
		period = period + 1;

assign CLK = period[1];
assign SCLK = period[1];


always @(posedge CLK or posedge RST)				//zliczanie do wpisania rejestrów
	if(RST == 1)
		period1 = 0;
	else if ()	
	else if (W_STB) 
		period1 = period1 + 1;



always @(posedge CLK or posedge W_STB)					//zapis do 48 bitowego rejestry z którego bêdzie wysy³ane na MOSI
	if(W_STB)
		DATA[7:0] <= W_DATA;
	else if ((period1[2:0] == 1) && (W_STB))
		DATA[15:8] <= W_DATA;		
	else if ((period1[2:0] == 2) && (W_STB))
		DATA[24:16] <= W_DATA;		
	else if ((period1[2:0] == 3) && (W_STB))
		DATA[31:25] <= W_DATA;		
	else if ((period1[2:0] == 4) && (W_STB))
		DATA[39:32] <= W_DATA;					
	else if ((period1[2:0] == 5) && (W_STB))
		DATA[47:40] <= W_DATA;	

always @(posedge CLK)
	;







endmodule