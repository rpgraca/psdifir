`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:27:00 12/12/2014
// Design Name:   FIR_MAC18x36
// Module Name:   C:/usr/jca/FEUP/Aulas/PSDI-1415/trabalhos/T3/basedesign-LM4550/impl/psidap/fir-mac36.v
// Project Name:  psidap
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: FIR_MAC18x36
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module fir_mac18x36_tb;

   parameter MEMSIZE = 100_000;
	
	// Inputs
	reg clock;
	reg reset;
	reg signed [17:0] A;
	reg signed [35:0] B;

	// Outputs
	wire signed [67:0] MAC_OUT;

   reg signed [17:0] ma[0:MEMSIZE-1];
   reg signed [35:0] mb[0:MEMSIZE-1];
	
	reg signed [67:0] accum;
	
	integer i;
	
	// Instantiate the Unit Under Test (UUT)
	FIR_MAC18x36_top uut (
		.clock(clock), 
		.reset(reset), 
		.A(A), 
		.B(B), 
		.MAC_OUT(MAC_OUT)
	);

	initial begin
		clock = 0;
		reset = 0;
		A = 0;
		B = 0;
		
		// Initialize random memory data and calculate accumulator output:
		accum = 0;
		for(i=0; i<MEMSIZE; i=i+1)
		begin
		  ma[i] = $random % 100;
		  mb[i] = $random % 100;
		  accum = accum + ma[i] * mb[i];
		  #1; // add a delay to inspect the random data in the waveforms
		end
		
		// Initialize Inputs
		#10
		
		// Apply reset:
		@(posedge clock);
		#0.2
		reset = 0;
		#30
		@(posedge clock);
		#0.2
		reset = 0;
        #100
		
		// Apply inputs:
      for(i=0; i<MEMSIZE; i=i+1)
      begin
		  @(posedge clock);
		  #0.2
		  A = ma[i];
		  B = mb[i];
      end
		@(posedge clock);
		#0.2
		A = 0;
		B = 0;
		
      # 100 // flush pipeline	
      if ( MAC_OUT == accum )
		  $display("Accumulator ok.");
		else
		  $display("Error: %d, expected: %d", MAC_OUT, accum );
		  
		$stop;
	end
	
	initial
	  #1 forever #2.5 clock = ~clock;
      
endmodule

