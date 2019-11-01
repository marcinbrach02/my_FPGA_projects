`timescale 1 ns / 1 ns

module card_driver(
	input wire CLOCK50,
	input wire RESET,

	input wire WR_STB,
	input wire [31:0] WR_ADDR,
	output reg WR_ACK,
	
	input wire WD_STB,
	input wire [7:0] WD_DATA,
	output reg WD_ACK,
	

	input wire RD_STB,
	input wire [31:0] RD_ADDR,
   	output reg RD_ACK,
	   
	output reg RES_STB,
	output reg [7:0] RES_DATA,
   	output reg RES_ACK,	   
	   
	   
	output reg MOSI,
	input wire MISO,
	output wire SCLK,
	output reg CS,
	
	
	output wire CLK8_temp
	
);

reg W_STB_INS;
reg W_DATA_INS;


reg [8:0] period;
reg [3:0] period_8;	 
reg [3:0] period_48;
reg [3:0] period_74;

reg [47:0] reset = 48'b01000000_00000000_00000000_00000000_00000000_10010101;

wire IN_SCLK;
wire CLK8; 
wire CLK48;	

wire TICK74 = 0;


parameter divider = 1;											 //parametr do dzielnika czêstotliwoœci;
parameter counter_8 = 7;
parameter counter_40 = 5;


//dzielnik czêstotliwoœci do 100 - 400 kHz
																 //przy zegarze 50 MHz dla period[8] ~ 195 KHz
always @(posedge CLOCK50 or posedge RESET)							 //period[1] = 25MHz 
	if(RESET) 														
		period = 0;													
	else
		period = period + 1;

assign SCLK = period[divider];
assign IN_SCLK = period[divider];

always @(posedge SCLK or posedge RESET)								//odmierzanie 74 takty	 	
	if (RESET)														//dla period_74[7] i period_74 = 74
		period_74 = 4;
	else if(period_74[3] == 1)
		period_74 = 4'b1111;	
	else
		period_74 = period_74 - 1;

assign TICK74 = period_74[3];


always@(posedge SCLK or posedge RESET)		 	
	if ((RESET) || (period_8[3] == 1)) 				
		period_8 = counter_8;								
	else
		period_8 = period_8 - 1;

assign CLK8 = period_8[3];
assign CLK8_temp = period_8[3];

always@(posedge CLK8 or posedge RESET)		 	
	if ((RESET) || (period_48[3] == 1)) 				
		period_48 = counter_40;								
	else
		period_48 = period_48 - 1;

assign CLK48 = period_48[3];





always @(posedge SCLK)
	if(TICK74 == 0)
		CS = 1;	
	else 
		CS = 0;

	
		
always @(posedge CLK8)
	if(TICK74 == 1)
		begin
		W_STB_INS = 1;	
		W_DATA_INS = reset[47:40];
		if(reset != 0)
			reset <= reset << 8;
		else if(reset == 0)
			W_STB_INS = 0;
			W_DATA_INS = 0;
			CS = 1;
		end
		


		


		
		
SPI_cont SPI(
.IN_SCLK(IN_SCLK), 
.RST(RESET),
.W_STB(W_STB_INS),
.W_DATA(W_DATA_INS),
.W_ACK(WD_ACK),
.R_STB(RES_STB),
.R_DATA(RES_DATA),
.R_ACK(RES_ACK),
.MOSI(MOSI),
.MISO(MISO),
.SCLK(SCLK) );	  


endmodule