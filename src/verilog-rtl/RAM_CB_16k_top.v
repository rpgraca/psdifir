`timescale 1ns/1ps

module RAM_cb_top( clock, reset,
                   xin, enxk, addrin, rdout );

input         clock;
input         reset;
input  [17:0] xin;
input         enxk;
input  [11:0] addrin;
output [71:0] rdout;


reg [17:0] rxin;
reg        renxk;
reg [11:0] raddrin;
reg [71:0] rdout;
wire [71:0] dout;

RAM_CB_16k RAM_CB_1(  .clock( clock ) ,
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
