`timescale 1ns/1ps

module psdifir_top_tb;

// 100 MHz clock
parameter CLOCK_PERIOD = 10;

// Maximum simulation time (disabled, can't setup enough time)
parameter MAX_SIM_TIME = (CLOCK_PERIOD * 1_000_000_000);

// We need to simulate at least 16384 input samples to fill the circular buffer
// Simulate for more 2000 samples 
parameter MAX_SIM_SAMPLES = (16384 + 2000);

reg clock, reset, data_ready;
wire [17:0] data_out;
wire        dataout_ready;
reg  [17:0] data_in;

psdifir_top  psdifir_top_1( 
                  .clockext100MHz ( clock ),	      // master clock input (external oscillator 100MHz)
                  .reset( reset ),                 // master reset, synchronous, active high
				  .datain_ready( data_ready ),     // input data ready (input samples ready when high)
                  .left_in( data_in ),             // audio stream inputs
				  .right_in( 18'd0 ),              // UNUSED        
                  .left_out( data_out ),           // audio stream outputs
				  .right_out( ),
                  .dataout_ready( dataout_ready )				  
				);

			
// Memories for the input signal and golden output:
reg [17:0] ram_input_data[0:20000], ram_golden_out[0:20000];
// The addresses of both RAMs:
reg [15:0] ram_address;

initial
begin
    $readmemh("../sim_data/testsine.hex", ram_input_data );
	$readmemh("../sim_data/goldenout.hex", ram_golden_out );
end

// initialize inputs and start clock:
initial
begin
  reset = 1'b0;
  clock = 1'b0;
  data_ready = 1'b0;
  data_in = 18'd0;
  ram_address = 16'd0;
  # 3
  forever #( CLOCK_PERIOD / 2 ) clock = ~clock;
end

// Apply initial reset (4 clock cycles)
initial
begin
  # 20
  reset = 1;
  # ( 4 * CLOCK_PERIOD );
  reset = 0;
end

// Setup the maximum simulation time:
initial
begin
  // #( MAX_SIM_TIME ); // MAX_SIM_TIME cannot be larger than a 32 bit constant!
  // $stop;
end


// Apply input stream. As in this example we WILL NOT MEET the 48 kHz timing,
// we need to synchronize the input data to the output data ready:
always
begin
  #( 100 * CLOCK_PERIOD );
  for( ram_address = 0; ram_address < 20000; ram_address = ram_address + 1 )
  begin
    // Apply data in:
	  data_in = ram_input_data[ ram_address ];
	
	  // Assert data_read for 1 clock cycle:
	  data_ready = 1'b1;
	  #( CLOCK_PERIOD );
	  data_ready = 1'b0;
	
	  // Wait for dataout_ready:
	  @(posedge dataout_ready );
	  // add delay to avoid setting next data_read in the clock edge
	  #3
	  
	
	  // Verify output data:
	  if ( data_out != ram_golden_out[ ram_address ] )
	  $display("ERROR at sample %d: expected %d (%05Hh), received %d (%05Hh)", 
	               ram_address, ram_golden_out[ ram_address ], ram_golden_out[ ram_address ], data_out, data_out );
	  // wait some more time.
	
	  
	  #( 10*CLOCK_PERIOD );
	  if ( ram_address % 100 == 0 )
	    $write("Verified %d samples\n", ram_address );
  
    // 
    if ( ram_address == MAX_SIM_SAMPLES )
      $stop;
      
  end
end
				
endmodule
