module counter(
	input wire CLK50,
	input wire RST,
	output wire LED0, 
	
	output wire [2:0] TEMP
);

reg [3:0] period;


always@(posedge CLK50 or posedge RST)		 	//proces umozliwiajacy zliczanie zdarzen zegarowych
	if ((RST) || (period[3] == 1)) 				//i generowanie sygnalu zegarowego o zmiennym czasie pomiedzy impulsami
		period = 2;								//zaleznym od ustawionej wartosci period
	else
		period = period - 1;

assign LED0 = period[3];

assign TEMP = period;
 

/*
always @(posedge CLK50 or posedge RST)		   //proces umozliwiajacy zliczanie taktow i lapanie
	if(RST) 								   //bitu na okreslonej pozycji - gwarantowane wypelnienie 1/2
		period = 0;
	else
		period = period + 1;

assign LED0 = period[4];
*/

endmodule