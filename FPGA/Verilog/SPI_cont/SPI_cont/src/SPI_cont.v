`timescale 1 ns / 1 ns
`default_nettype none

module SPI_cont(
	input wire CLK,
	input wire RST,
	input wire TICK,
	
	input wire W_STB,
	input wire [7:0] W_DATA,
	output wire W_READY,
	
	output reg R_STB,
	output reg [7:0] R_DATA,
	
	output reg MOSI,
	input wire MISO,
	output wire SCLK
	//output reg CS					sygna³ przeniesiony do top level
	
);


reg receiving;
reg sending;
reg [3:0] period;

reg [7:0] WR_DATA;
reg [7:0] RD_DATA;

reg INT_SCLK;
always @(posedge CLK or posedge RST) INT_SCLK <= (RST) ? 0 : (W_STB) ? 1 : INT_SCLK ^ TICK;
	
assign SCLK = INT_SCLK & receiving;

assign W_READY = !sending;
	   
always@(posedge CLK or posedge RST)	   						
begin
	if(RST)
		begin 	  
		MOSI <= 1;  // 1'bx
		receiving <= 0;   
		sending <= 0;
		WR_DATA <= 0;
		RD_DATA <= 0;
		R_DATA <= 0;
		R_STB <= 0;	 
		period <= 0;
		end	
	else if (W_STB)
		begin
		WR_DATA <= W_DATA;
		R_DATA <= 0;
		sending <= 1;
		period <= (8-1);	
		end
	else if (sending && TICK && (INT_SCLK==1)) // neg edge
		begin	 			
		    WR_DATA <= WR_DATA << 1; 
			period <= period - 1;	
			if(period[3]) 
				begin  
					receiving <= 0;
					sending <= 0;
					MOSI <= 1;  // 1'bx
					R_DATA <= RD_DATA;
					R_STB  <= 1;
				end
			else
				begin	  
					receiving <= 1;
					MOSI <= WR_DATA[7];					   					
				end
		end		
	else if (receiving && TICK && (INT_SCLK==0)) // pos edge
		begin	 						
		   RD_DATA <= { RD_DATA, MISO};
		end		
	else 
		begin
			R_STB <= 0;		
		end		
end		
		 
	
endmodule 
