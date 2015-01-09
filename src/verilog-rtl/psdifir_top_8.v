/*
PSD 2014/2015 - 
jca@fe.up.pt
FEUP internal use only
*/

`timescale 1ns/1ps

module psdifir_top_8( 
                  clockext100MHz,	// master clock input (external oscillator 100MHz)
                  reset,            // master reset, synchronous, active high
				  datain_ready,     // input data ready (input samples ready when high)
                  left_in,          // audio stream inputs
				  right_in,         
                  left_out,         // audio stream outputs
				  right_out,
                  dataout_ready     // data out is ready				  
				);
 
// I/Os:
input				clockext100MHz,      // master clock, active in the posedge
                    reset,               // master reset, synchronous, active high
					datain_ready;        // input data ready (input samples ready when high)
input   [17:0]      left_in, right_in;   // audio stream inputs
output  [17:0]      left_out, right_out; // audio stream outputs
output              dataout_ready;


//-----------------------------------------------------------------------------
// Interface with the coefficients memory:
// Address buses:
wire [10:0] addr_coef_left, addr_coef_right;
// Data bus (read only):
wire [287:0] coef_4_left, coef_4_right;

//-----------------------------------------------------------------------------
// The coefficients memory (only the left read port is used in this example)
// Disable the write interface. In this example the memory 
// is used only with the preloaded data
RAM_coefs_8  RAM_coefs_1( 
              .clock( clockext100MHz ),
              .reset( reset ),
			  .addrLrw( 14'd0 ),           // UNUSED - Write interface
			  .addrRrw( 14'd0 ),
			  .datainLrw( 36'd0 ),
			  .datainRrw( 36'd0 ),
			  .dataoutLrw(  ),
			  .dataoutRrw(  ),
			  .weL( 1'b0 ),
			  .weR( 1'b0 ),
			
			  // Read interface
			  .addrL( addr_coef_left ),    // address bus for the left coefficients
			  .addrR( 11'd0 ),             // UNUSED - Address bus for the right coefficients
			  .coefL( coef_4_left ),       // 144 bit, 4 left coefficients ( 4 x 36 )
			  .coefR(  )                   // UNUSED - 144 bit, 4 right coefficients ( 4 x 36 )
               );
			   
//-----------------------------------------------------------------------------			   
// Interface with the circular buffer memory 
// Only one buffer is used in this example (left channel) 
wire [10:0] datacb_addr;    // read address
wire [143:0] datacb;         // data read, 4 samples = 4 x 18 = 72 bits
                            // the most recently written is at the higher position

// The 16k x 18b circular buffer. 			
RAM_CB_16k_8  RAM_CB_16k_1( 
               .clock( clockext100MHz ),
               .reset( reset ),
			   .din( left_in ),
			   .wen( datain_ready ),
			   .addrin( datacb_addr ),
			   .dout( datacb )
			    );
				
//-----------------------------------------------------------------------------			   
// The FIR calculator (only for the left channel)	
FIR_MAC8  FIR_1(
               .clock( clockext100MHz ),
               .reset( reset ),
			   .datain_ready( datain_ready ),   // data in ready, used to start calculation of the FIR
			   .addr_coefs( addr_coef_left ),   // address for the coefficient memory, 12 bits
			   .coefs_in( coef_4_left ),        // the 4 coefficients ready from memory
			   .addr_data( datacb_addr ),       // address for the circular buffer, 12 bits
			   .datain( datacb ),               // data read from the circular buffer (4 samples)
			   .dataout( left_out ),            // data out
			   .dataout_ready( dataout_ready )  // data out is ready
		       );
			   

// Connect the right channel output to zero:
assign right_out = 18'd0;
			   
endmodule

