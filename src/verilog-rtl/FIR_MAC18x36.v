`timescale 1ns/1ps

module FIR_MAC18x36 (
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

reg  signed [17:0] rA;
reg  signed [16:0] rBl;
reg  signed [17:0] rBh; 

// The 17th bit of operand B
reg  rBl17;

reg  signed [67:0] MAC_OUT;

reg  signed [35:0] mul_low;
reg  signed [35:0] mul_high;

reg     signed [49:0] MAC_OUT_low0, MAC_OUT_high0;

reg signed [31:0] mul_mid;

wire signed [17:0] Bh;
wire signed [16:0] Bl;

reg signed [31:0] mul_mid0, mul_mid1;

assign Bl = B[16:0];
assign Bl17 = B[17]; // The 17th bit
assign Bh = B[35:18];

initial
begin
  mul_high = 36'd0;
  MAC_OUT_high0 = 68'd0;
  mul_low = 36'd0;
  MAC_OUT_low0 = 68'd0;
  mul_mid = 32'd0;
  mul_mid0 = 32'd0;
  
  rA   = 18'd0;

  rBl  = 17'd0;
  rBh  = 18'd0;  
  
  rBl17 = 1'b0;
	 
end
// Multiply A with the low part of B
// Note that A is signed but the low part of B is unsigned
// Accumulate in MAC_OUT_low0
always @(posedge clock)
begin
  if ( reset )
  begin
    rA   <= 18'd0;

	 rBl  <= 17'd0;
	 rBl17 <= 1'b0;
	 
	 rBh  <= 18'd0;
	 
	 mul_low <= 36'd0;
    MAC_OUT_low0 <= 68'd0;
  end
  else
  begin
    rA   <= A;
	 
	 rBl  <= Bl;
	 
	 rBl17 <= Bl17;
	 
	 rBh  <= Bh;
	 
     mul_low  <= rA * $signed({1'b0,rBl}); // A small trick to mix signed and unsigned operands
    // mul_low  <= rA * rBl;
	 MAC_OUT_low0  <= MAC_OUT_low0  + mul_low;
  end
end

// Multiply A with the high part of B
// Accumulate in MAC_OUT_high0
always @(posedge clock)
begin
  if ( reset )
  begin
	mul_high <= 36'd0;
    MAC_OUT_high0 <= 68'd0;
  end
  else
  begin
	 mul_high <= rA * rBh;
	 MAC_OUT_high0 <= MAC_OUT_high0 + mul_high;
  end
end


// Accumulate the weight of the missing bit
// 
always @(posedge clock)
begin
  if ( reset )
  begin
	 mul_mid <= 32'd0;
	 mul_mid0 <= 32'd0;
  end
  else
  begin
    mul_mid <= mul_mid + ( rBl17 ? rA : 0 );
	mul_mid0 <= mul_mid;
  end
end

wire signed [67:0] p1, p2 ,p3;
assign p1 = (MAC_OUT_high0 << 18) ; // High part
assign p2 = MAC_OUT_low0;           // Low part
assign p3 = mul_mid0 << 17 ;        // the contribution of the 17th bit of B

always @(posedge clock)
begin
  if ( reset )
  begin
    MAC_OUT <= 68'd0;
  end
  else
  begin
     MAC_OUT <= p1 + p2 + p3;
  end
end


endmodule
			  