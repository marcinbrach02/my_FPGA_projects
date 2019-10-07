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





//SPI_cont SPI(.CLK50(CLOCK50), .RST(RESET), );




endmodule