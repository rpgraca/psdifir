`timescale 1ns/1ps

module FIR_MAC18x36_slow (
               clock,
               reset,
			   A,   
			   B,     
			   MAC_OUT
		       );
			   
input clock, reset;
input signed  [17:0] A;
input signed  [35:0] B;

output signed [67:0] MAC_OUT;
reg    signed [67:0] MAC_OUT;

reg    signed [17:0] rA;
reg    signed [35:0] rB;
reg    signed [53:0] mul_out;

initial
begin
  rA   = 18'd0;
  rB   = 36'd0;
  mul_out = 54'd0;
  MAC_OUT = 68'd0; 
end

always @(posedge clock)
begin
  if ( reset )
  begin
     rA   <= 18'd0;
     rB   <= 36'd0;
	 mul_out <= 54'd0;
     MAC_OUT <= 68'd0;
  end
  else
  begin
    rA <= A;
	rB <= B;   
    mul_out <= rA * rB;
	MAC_OUT  <= MAC_OUT + mul_out;
  end
end


endmodule
			  