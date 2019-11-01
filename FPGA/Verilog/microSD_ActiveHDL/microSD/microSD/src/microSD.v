module microSD(
	input wire CLK50,
	input wire RST,
	
	input wire W_STB,
	input wire [7:0] W_DATA,
	
	input wire R_STB,
	output reg [7:0] R_DATA,
	
	output reg MOSI,
	input wire MISO,
	output wire SCLK,
	output reg CS	
	
);

wire CLK8;
wire CLK74;
reg temp = 1'b0;
reg [1:0] period; 
reg [3:0] period1;
reg [7:0] period2;
reg [7:0] DATA;


always @(posedge CLK50 or posedge RST)								//dzielnik czêstotliwoœci do 100 - 400 kHz
	if(RST) 														//przy zegarze 50 MHz dla period[8] ~ 195 KHz
		period = 0;													//period[1] = 25MHz 
	else
		period = period + 1;

assign SCLK = period[1];

always@(posedge SCLK)												//odmierzanie 8 taktow dla odbioru wiadomoœci gdy period1 = 8	 	
	if ((MISO == 0) && (temp == 0)) 								//pierwsza odebrana wartosæ musi byæ zerem
		begin
		period1 = 7;
		temp = 1;
		end	
	else
		period1 = period1 - 1;

assign CLK8 = period1[3];


always@(posedge SCLK or posedge RST)								//odmierzanie 74 takty	 	
	if (RST == 1)													//dla period2[7] i period2 = 74
		period2 = 4;
	else if(period2[3] == 1)
		period2 = 4'b1111;	
	else
		period2 = period2 - 1;

assign CLK74 = period2[3];
					


always @(posedge SCLK)	   											//wys³anie komendy do karty
begin
	if(RST)
		begin
		R_DATA <= 0;
		MOSI <= 0;
		CS <= 0;
		end	
	else if(W_STB)
		DATA <= W_DATA;	
	else if (CLK74 == 0)
		begin
			MOSI <= 1;
			CS <= 1;
		end	
	else if (CLK74 == 1)
		begin
			CS <= 0; 
			MOSI <= DATA[7];					   
		    DATA <= DATA << 1;
			if ((DATA == 8'b0000_0000) && (W_STB == 1))	 
				begin
				DATA <= W_DATA;
				end		
			else if ((DATA == 8'b0000_0000) && (W_STB == 0))	 
				begin
				MOSI <= 1;
				end	
		end	
		
   					
	if (R_STB)														//odbiór danych
		R_DATA <= DATA;
	else if ((MISO == 0) || (CLK8 == 0))
		begin
		DATA[0] <= MISO;
		DATA <= DATA << 1;
		end
end		
		
endmodule