module Signal_generators(
	input wire clk,
	input wire reset,
	input wire enable,

	output wire out_clk1,
	output wire out_clk2,

	output [7:0] sine, cos
);

reg [3:0] period_clk1;
reg [3:0] period_clk2;

always@(posedge clk or posedge reset)		 					
	if (reset) 						
		period_clk1 <= 3;												
	else if (period_clk1[3])
			period_clk1 <= 3;	
	else
		period_clk1 <= period_clk1 - 1;

assign out_clk1 = period_clk1[3];

 
always @(posedge clk or posedge reset)		   		
	if(reset) 								   				
		period_clk2 = 0;
	else
		period_clk2 = period_clk2 + 1;

assign out_clk2 = period_clk2[3];


reg [7:0] sine_r, cos_r;
assign sine = sine_r + {cos_r[7], cos_r[7], cos_r[7], cos_r[7:3]};
assign cos = cos_r - {sine[7], sine[7], sine[7], sine[7:3]};

always@(posedge clk or negedge reset)
begin
	if (!reset)
		begin
			sine_r <= 0;
			cos_r <= 120;
		end
	else
			if (enable)
		begin
			sine_r <= sine;
			cos_r <= cos;
		end
end

endmodule