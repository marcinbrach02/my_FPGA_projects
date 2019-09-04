module counter(
	input wire CLK50,
	input wire RST,
	output wire LED0, 
	
	output wire [2:0] TEMP
);

reg [3:0] period;


always@(posedge CLK50 or posedge RST)		 	//proces umo�liwiaj�cy zliczanie zdarze� zegarowych
	if ((RST) || (period[3] == 1)) 				//i generowanie sygna�u zegarowego o zmiennym wype�nieniu 
		period = 2;								//zaleznym od ustawionej warto�ci period
	else
		period = period - 1;

assign LED0 = period[3];

assign TEMP = period;
 

/*
always @(posedge CLK50 or posedge RST)		   //proces umo�liwiaj�cy zliczanie takt�w i �apanie
	if(RST) 								   //bitu na okre�lonej pozycji - gwarantowane wype�nienie 1/2
		period = 0;
	else
		period = period + 1;

assign LED0 = period[4];
*/

endmodule