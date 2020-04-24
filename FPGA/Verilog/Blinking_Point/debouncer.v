module debouncer( input wire RST, input wire CLK, input wire I, output reg O );

parameter MIN_LEN = 8;
localparam WAIT_I= 0, SET_O = 1, DECR_DCNT = 2;

reg[2:0] state, next_state;
reg[7:0] DCNT;

always @ (posedge CLK or posedge RST)
	if (RST) state <= WAIT_I;
	else state <= next_state;

always @(*) 
begin
	case (state)
		WAIT_I : if (I) next_state <= SET_O;
					else next_state <= WAIT_I;
		SET_O: next_state <= DECR_DCNT;
		DECR_DCNT: if (DCNT==0) next_state <= WAIT_I;
					  else next_state <= DECR_DCNT;
	default : next_state <= WAIT_I;
	endcase
end

always@(posedge CLK or posedge RST)
	if(RST) DCNT <= 'd0;
	else if(next_state == SET_O ) DCNT <= MIN_LEN ;
	else if(next_state == DECR_DCNT) DCNT <= DCNT - 'd1;
	else DCNT <= DCNT;

always @(posedge CLK or posedge RST)
	if(RST) O <= 1'b0;
	else if(next_state== SET_O) O <= 1'b1;
	else O <= 1'b0;

endmodule
