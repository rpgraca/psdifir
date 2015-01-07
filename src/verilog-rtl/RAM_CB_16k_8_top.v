`timescale 1ns/1ps

module RAM_cb_top_8( clock, reset,
                   xin, enxk, addrin, rdout );

input         clock;
input         reset;
input  [17:0] xin;
input         enxk;
input  [10:0] addrin;
output [143:0] rdout;


reg [17:0] rxin;
reg        renxk;
reg [10:0] raddrin;
reg [143:0] rdout;
wire [143:0] dout;

RAM_CB_16k_8 RAM_CB_1(  .clock( clock ) ,
               .reset( reset ),
			   .din( rxin ),
			   .wen( renxk ),
			   .addrin( raddrin ),
			   .dout( dout )
			  );
always @(posedge clock)
begin
  rxin <= xin;
  renxk <= enxk;
  raddrin <= addrin;
  rdout <= dout;
end			  

endmodule
