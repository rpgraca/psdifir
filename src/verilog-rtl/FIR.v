`timescale 1ns/1ps

module FIR (
               clock,
               reset,
			   datain_ready,   // data in ready, used to start calculation of the FIR
			   addr_coefs,     // address for the coefficient memory
			   coefs_in,       // the 4 coefficients ready from memory
			   addr_data,      // address for the circular buffer
			   datain,         // data read from the circular buffer
			   dataout,        // output data
			   dataout_ready   // pulse high when dataout is ready
		       );
			   
input clock, reset;
input datain_ready;
output [11:0] addr_coefs;
input [143:0] coefs_in;
output [11:0] addr_data;
input  [71:0] datain;
output [17:0] dataout;
output        dataout_ready;

reg    [11:0] addr_coefs;
reg    [11:0] addr_data;
reg    [17:0] dataout;
reg           dataout_ready;

// Aditional registers:
reg  [3:0] state;           // FSM state
reg [12:0] count_samples;   // counts cycles of the main FSM (# of samples / 4 )
reg  [1:0] mac_sel;         // selector fo the MAC operands
reg signed [67:0] mac_out;         // the output of the MAC unit
reg signed [67:0] temp_output;     // temporay accumulator register
reg signed [17:0] data_0, data_1, data_2, data_3;
reg signed [35:0] coef_0, coef_1, coef_2, coef_3;
reg signed [35:0] round_temp_out;

// FSM states
parameter   IDLE = 3'd0,
            READ_MEMORY_DATA = 3'd1,
			MAC_0 = 3'd2,
			MAC_1 = 3'd3,
			MAC_2 = 3'd4,
			MAC_3 = 3'd5,
			UPDATE_ADDRESS = 3'd6,
			TERMINATE = 3'd7,
			WAIT_READ_MEMORY_DATA = 4'd8;

// This implementation uses only one multiply-accumulate (MAC) block and performs
// a single MAC operation per clock cycle, thus NOT MEETING the 48kHz input/output rate spec.
always @(posedge clock)
begin
  if ( reset )
  begin
    state <= IDLE;
	addr_coefs <= 14'd0;
	addr_data <= 12'd0;
	dataout <= 17'd0;
	dataout_ready <= 1'b0;
	count_samples <= 13'd0;
	mac_sel <= 2'b00;
	temp_output <= 68'd0;
	data_0 <= 18'd0;
	data_1 <= 18'd0;
	data_2 <= 18'd0;
	data_3 <= 18'd0;
	coef_0 <= 36'd0;
	coef_1 <= 36'd0;
	coef_2 <= 36'd0;
	coef_3 <= 36'd0;
  end
  else
  begin
    case( state )
	  IDLE: 
	        begin
	          if ( datain_ready ) // new sample arrived, start calculation of output sample:
			  begin
			    addr_coefs <= 12'd0;
	            addr_data <= 12'd0;
			    count_samples <= 13'd0;
				temp_output <= 68'd0;
			    state <= WAIT_READ_MEMORY_DATA;
			  end
	        end
			
	  WAIT_READ_MEMORY_DATA:
	        state <= READ_MEMORY_DATA;
			
	  READ_MEMORY_DATA:
	        begin
			  // Read 4 past data samples from the circular buffer (current address)
			  data_0 <= datain[71:54]; // newest data sample
			  data_1 <= datain[53:36];
			  data_2 <= datain[35:18];
			  data_3 <= datain[17:0];  // oldest data sample
			  
			  // Read 4 coefficients from the coefficients memory
			  coef_0 <= coefs_in[143:108];
			  coef_1 <= coefs_in[107:72];
			  coef_2 <= coefs_in[71:36];
			  coef_3 <= coefs_in[35:0];
			  
			  mac_sel <= 2'b00;
			  state <= MAC_0;
			end
		
      // Calculate the multiply-accumulate operations; see below the combinational
      // process that produces mac_out	  
	  MAC_0:
	        begin
			  temp_output <= mac_out;
			  mac_sel <= 2'b01;
			  state <= MAC_1;
			end
	  
	  MAC_1:
	        begin
			  temp_output <= mac_out;
			  mac_sel <= 2'b10;
			  state <= MAC_2;
			end
	  
	  MAC_2:
	        begin
			  temp_output <= mac_out;
			  mac_sel <= 2'b11;
			  state <= MAC_3;
			end
	  
	  MAC_3:
	        begin
			  temp_output <= mac_out;
			  count_samples <= count_samples + 1; // 
			  state <= UPDATE_ADDRESS;
			end

      UPDATE_ADDRESS:
            begin
			  if ( count_samples == 4096 ) // did last set, output result and terminate
			  begin
			    dataout <= round_temp_out;
				dataout_ready <= 1'b1;         // assert dataout ready
			    state <= TERMINATE;
			  end
			  else
			  begin
			    addr_coefs <= addr_coefs + 1;  // update address of coefficient memory
	            addr_data <= addr_data + 1;	   // update address of circular buffer
                state <= WAIT_READ_MEMORY_DATA;				
			  end
            end			

      TERMINATE:
            begin
			  dataout_ready <= 1'b0;          // deassert dataout ready, goto state IDLE waiting for new sample
			  state <= IDLE;
            end

	endcase
  end
end


// The multiply-accumulate unit:
reg signed [17:0] A_mac;
reg signed [35:0] B_mac;

always @*
begin
  // input MAC multiplexer:
  case ( mac_sel )
    2'b00: begin
	         A_mac = data_0;
	         B_mac = coef_0;
		   end
    2'b01: begin
	         A_mac = data_1;
	         B_mac = coef_1;
		   end
    2'b10: begin
	         A_mac = data_2;
	         B_mac = coef_2;
		   end
    2'b11: begin
	         A_mac = data_3;
	         B_mac = coef_3;
		   end
  endcase
  // The MAC unit:
  mac_out = temp_output + A_mac * B_mac;
end

// Discard the 35 LSbits (the fractional part of the result and round output
// we assume the filter gain will not exceed 1,
// so the 14 MSbits can be ignored or tested for overflow
always @*
begin
  if ( ~temp_output[34] )
    round_temp_out = temp_output[35+18:35];
  else	
    if ( temp_output[34] & ( | temp_output[33:0] ) )    // round up:
      round_temp_out = temp_output[35+18:35] + 1;  
    else
	  round_temp_out = temp_output[35+18:35] + temp_output[35];  
end

endmodule
			  