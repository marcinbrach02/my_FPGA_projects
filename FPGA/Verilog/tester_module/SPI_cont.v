module SPI_cont(
	input wire IN_SCLK,
	input wire RST,
	
	input wire W_STB,
	input wire [7:0] W_DATA,
	output reg W_ACK,
	
	output reg R_STB,
	output reg [7:0] R_DATA,
   	output reg R_ACK,
	
	output reg MOSI,
	input wire MISO,
	output wire SCLK
	
);


reg wr_ready = 0;	
reg rd_ready = 0;

//reg [1:0] period; 
reg [3:0] wr_period;
reg [3:0] rd_period;

reg [7:0] WR_DATA;
reg [7:0] RD_DATA;


assign SCLK = IN_SCLK;


always@(posedge SCLK)	   						//proces zapisu
begin
	if(RST)
		begin 
		MOSI <= 0;
		end	
	else if(W_STB)
		begin
		WR_DATA <= W_DATA;
		wr_ready <= 1;
		wr_period = 8;	
		end
	else if(wr_ready)
		begin
			MOSI <= WR_DATA[7];					   
		    WR_DATA <= WR_DATA << 1; 
			wr_period = wr_period - 1;			
			if(wr_period[3])
				begin
				wr_ready <= 0;
				W_ACK <= 1;
				MOSI <= 1;
				end
		end		
	else 
		begin
			MOSI <= 1;
			W_ACK <= 0;		
		end		
end		

		
		
always@(negedge SCLK)	   						//proces odczytu					
begin
	if(RST)
		begin 
		R_STB <= 0;
		R_DATA <= 0;
		end	
	else if((MISO == 0) && (rd_ready == 0))
		begin		
		rd_ready <= 1; 
		rd_period = 7;
		RD_DATA[0] <= 0;
		end	
	else if(rd_ready)
		begin
		RD_DATA <= RD_DATA << 1;			
		RD_DATA[0] <= MISO;
		rd_period = rd_period - 1;	
			if(rd_period[3])
				begin
				rd_ready <= 0;
				R_ACK <= 1;
				R_STB <= 1;
				R_DATA <= RD_DATA;	
				end
		end
	else 
		begin
			R_STB <= 0;
			R_ACK <= 0;
			R_DATA <= 0;
		end	
end	 
	
endmodule 
