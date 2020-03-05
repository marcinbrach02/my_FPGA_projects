`timescale  1 ps / 1 ps
`default_nettype none
//===============================================================================
module distributed_fifo_shift
#(
  parameter WIDTH    = 16 , 
  parameter AWIDTH   = 5  ,
  parameter BUSY_NUM = 6
)
(
  input  wire              fi_clk    ,
  input  wire              fi_rst    ,
  
  input  wire              fi_stb   ,
  input  wire  [WIDTH-1:0] fi_dat   ,
  output wire              fi_busy  ,
  output wire              fi_empty ,
  output wire              fi_error , 
  
  output wire              fo_stb   ,
  input  wire              fo_ack   ,
  output wire  [WIDTH-1:0] fo_dat  
);
//===============================================================================
// generic 
//---------------------------------------
parameter CAPACITY = 1 << AWIDTH; 
//---------------------------------------
reg   [WIDTH-1:0] ff_dat [0:CAPACITY-1];
reg    [AWIDTH:0] ff_sel;
reg    [AWIDTH:0] ff_num;
reg    [AWIDTH:0] ff_bnm;
wire   [AWIDTH:0] fx_sel;
wire   [AWIDTH:0] fx_num;
wire   [AWIDTH:0] fx_bnm;
//---------------------------------------
assign fi_empty    = ff_sel[AWIDTH];
//assign fi_busy_half = ff_num[AWIDTH-1];
assign fi_error    = ff_num[AWIDTH];
assign fi_busy      = ff_bnm[AWIDTH];
//--------------------------------------
always@(posedge fi_clk or posedge fi_rst)
if(fi_rst) begin
  ff_sel   <= {(AWIDTH+1){1'b1}};  
  ff_num   <= {(AWIDTH+1){1'b0}};  
  ff_bnm   <= BUSY_NUM;  
end else begin  
  ff_sel   <= ff_sel;
  ff_num   <= ff_num; 
  ff_bnm   <= ff_bnm; // default
  if (fi_stb) begin
    if (!fo_ack||fi_empty) begin 
      ff_sel <= ff_sel+1;
      ff_num <= ff_num+1;
      ff_bnm <= ff_bnm+1;
    end
  end else begin
    if (fo_ack&&!fi_empty) begin
      ff_sel <= ff_sel-1;
      ff_num <= ff_num-1;
      ff_bnm <= ff_bnm-1;
    end    
  end
end  
//----------------------------------------------------------------------------------------
integer i; 
always@(posedge fi_clk)
begin
  if(fi_stb) begin 
    ff_dat[4'h0] <= fi_dat;
    for (i=1; i<CAPACITY; i=i+1)
    begin
      ff_dat[i] <= ff_dat[i-1];
    end
  end
end 
//----------------------------------------------------------------------------------------
assign fo_dat = ff_dat [ ff_sel[AWIDTH-1:0] ];
assign fo_stb = !fi_empty;
//----------------------------------------------------------------------------------------
endmodule
