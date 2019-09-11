module microSD(
	input wire CLK50,
	input wire RST,
	
	input wire W_STB,
	input wire [7:0] W_DATA,
	
	output wire R_STB,
	output reg [7:0] R_DATA,
	
	output reg MOSI,
	input reg MISO,
	output wire SCLK,
	output reg CS
);

wire CLK;
wire CLK8;
wire CLK74;
reg [1:0] period; 
reg [3:0] period1;
reg [7:0] period2;
reg [7:0] DATA;


always @(posedge CLK50 or posedge RST)				//dzielnik czêstotliwoœci do 100 - 400 kHz
	if(RST) 
		period = 0;
	else
		period = period + 1;

assign CLK = period[1];
assign SCLK = period[1];

always@(posedge CLK or posedge RST)								//odmierzanie 8 taktow	 	
	if (MISO == 0) 				
		period1 = 7;								
	else
		period1 = period1 - 1;

assign CLK8 = period1[3];


always@(posedge CLK or posedge RST)								//odmierzanie >=74 takty	 	
	if (RST) 				
		period2 = 75;								
	else
		period2 = period2 - 1;

assign CLK74 = period2[7];
					


always @(posedge CLK or posedge W_STB or posedge CLK74 or posedge CS)
	if(W_STB)
		DATA <= W_DATA;	
	else if (CLK74 == 0)
		begin
			MOSI <= 1;
			CS <= 1;
		end	
	else if (CLK74 == 1)
		begin
			MOSI <= 1;
			CS <= 0;
		end	
	else if (CS == 0) 
		begin
		MOSI <= DATA[7];
		DATA <= DATA << 1; 
		end
		
		
always @(posedge CLK or posedge R_STB)
	if (R_STB)
		R_DATA <= DATA;
	else if ((MISO == 0) || (CLK8 == 1))
		begin
		DATA[0] <= MISO;
		DATA <= DATA << 1;
		end
		
		
endmodule