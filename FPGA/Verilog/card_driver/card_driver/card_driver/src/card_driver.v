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
	output reg [31:0] RES_DATA,
   	//output reg R_ACK,	   
	   
	   
	output reg MOSI,
	input wire MISO,
	output wire SCLK,
	output reg CS	
	
);
 
//SPI_cont SPI(.CLK(SCLK), .RST(RESET), );
reg [1:0] period;
reg [3:0] period_74;
reg [47:0] reset_command = 48'b01000000_00000000_00000000_00000000_00000000_10010101;


parameter divider = 1;											 //parametr do dzielnika czêstotliwoœci;
																 //dzielnik czêstotliwoœci do 100 - 400 kHz
																 //przy zegarze 50 MHz dla period[8] ~ 195 KHz
always@(posedge CLOCK50 or posedge RESET)							 //period[1] = 25MHz 
	if(RESET) 														
		period = 0;													
	else
		period = period + 1;

assign SCLK = period[divider];



always @(posedge SCLK or posedge RESET)								//odmierzanie 74 takty	 	
	if (RESET == 1)													//dla period2[7] i period2 = 74
		period_74 = 4;
	else if(period_74[3] == 1)
		period_74 = 4'b1111;	
	else
		period_74 = period_74 - 1;

assign CLK74 = period_74[3];

always@(posedge SCLK)												//odmierzanie 8 taktow dla odbioru wiadomoœci gdy period1 = 8	 	
	if ((MISO == 0) && (temp == 0)) 								//pierwsza odebrana wartosæ musi byæ zerem
		begin
		period1 = 7;
		temp = 1;
		end	
	else
		period1 = period1 - 1;

assign CLK8 = period1[3];




//always @(posedge SCLK or posedge RESET)
	//if(WD_STB)
		//  WD_DATA













endmodule