`timescale 1ns/1ps

//`include "FIR_MAC18x36_slow_top.v"
//`include "verilog-rtl/FIR_MAC18x36_top.v"

module FIR_MAC4_2cycle (
	input      		   clock        ,
	input      		   reset        ,
	input	   		   datain_ready ,  // data in ready, used to start calculation of the FIR
	input	   [143:0] coefs_in     ,  // the 4 coefficients ready from memory
	input	    [71:0] datain       ,  // data read from the circular buffer
	output reg  [11:0] addr_coefs   ,  // address for the coefficient memory
	output reg  [11:0] addr_data    ,  // address for the circular buffer
	output reg  [17:0] dataout      ,  // output data
	output reg 		   dataout_ready   // pulse high when dataout is ready
);
			   
// FSM states
parameter   IDLE        = 3'd0,
			WAIT_MEMORY = 3'd1,
			RUN         = 3'd2,
            TERMINATE   = 3'd3,
			READ_MEMORY = 3'd4,
			WAIT_DATA   = 3'd5;
			   
			   
// Aditional registers:
reg         [ 3:0] state;           										   // FSM state
reg 	    [12:0] count_samples;   										   // counts cycles of the main FSM (# of samples / 4 )
wire signed [67:0] mac_out_0, mac_out_1, mac_out_2, mac_out_3;                 // the output of the MAC unit
reg signed  [67:0] mac_out_0p1, mac_out_2p3;
wire signed [67:0] mac_out_final;
reg signed  [17:0] data_0, data_1, data_2, data_3;
reg signed  [35:0] coef_0, coef_1, coef_2, coef_3;
reg signed  [35:0] round_temp_out;
reg 		[ 9:0] dataout_ready_d;
reg				   rdataout_ready;
reg				   reset_mac     ;

//assign {data_0, data_1, data_2, data_3} = datain;    // data from the circular buffer
//assign {coef_0, coef_1, coef_2, coef_3} = coefs_in;  // coefficients from the coefficients memory

// 4 concurrent MAC operations
always @(posedge clock)
begin
	if ( reset ) begin
		state <= IDLE;
		addr_coefs     <= 12'd0;
		addr_data      <= 12'd0;
		dataout        <= 17'd0;
		rdataout_ready <= 1'b0 ;
		count_samples  <= 13'd0;
		mac_out_0p1    <= 1'b0 ;
		mac_out_2p3    <= 1'b0 ;
		
		data_0 <= 18'd0;
		data_1 <= 18'd0;
		data_2 <= 18'd0;
		data_3 <= 18'd0;
		coef_0 <= 36'd0;
		coef_1 <= 36'd0;
		coef_2 <= 36'd0;
		coef_3 <= 36'd0;
		reset_mac <= 1'b1;
	end
	else begin
		case( state )
			IDLE: begin
				if ( datain_ready ) begin// new sample arrived, start calculation of output sample:
					reset_mac     <= 1'b0;
					addr_coefs    <= 12'd0;
					addr_data     <= 12'd0;
					dataout       <= 17'd0;
					count_samples <= 13'd0;
					mac_out_0p1   <= 1'b0 ;
					mac_out_2p3   <= 1'b0 ;
					state         <= WAIT_DATA  ;
				end
			end

			WAIT_DATA:
				state <= READ_MEMORY;
			
			READ_MEMORY:
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
			  
			  count_samples  <= count_samples + 1;
			  
			  addr_coefs     <= addr_coefs    + 1;  // update address of coefficient memory
			  addr_data      <= addr_data     + 1;
			  state <= RUN;
			end
		
			
			RUN: begin
				//Update and Check RAM addresses
				if ( count_samples == 4096 ) begin 
					//dataout        <= round_temp_out;
					rdataout_ready <= 1'b1          ;         // assert dataout ready
					state          <= TERMINATE     ;
				end 
				else begin
					//count_samples  <= count_samples + 1;
					//addr_coefs     <= addr_coefs    + 1;  // update address of coefficient memory
					//addr_data      <= addr_data     + 1;  // update address of circular buffer	
					data_0 <= 18'd0;
					data_1 <= 18'd0;
					data_2 <= 18'd0;
					data_3 <= 18'd0;
					coef_0 <= 36'd0;
					coef_1 <= 36'd0;
					coef_2 <= 36'd0;
					coef_3 <= 36'd0;
					state		   <= READ_MEMORY;
				end
			end
			
			TERMINATE: begin
				rdataout_ready <= 1'b0;          // deassert dataout ready, goto state IDLE waiting for new sample
				if( dataout_ready_d[5] ) begin
					dataout  <= round_temp_out;
					reset_mac <= 1'b1;
					state    <= IDLE;
				end 
				else
					state    <= TERMINATE;
			end
		endcase
	end
end


FIR_MAC18x36_top u0_mac (
	.clock	( clock     ),
	.reset	( reset_mac ),
	.A		( data_0    ),   
	.B		( coef_0 	),     
	.MAC_OUT( mac_out_0 )
);

FIR_MAC18x36_top u1_mac (
	.clock	( clock     ),
	.reset	( reset_mac ),
	.A		( data_1    ),   
	.B		( coef_1 	),     
	.MAC_OUT( mac_out_1 )
);

FIR_MAC18x36_top u2_mac (
	.clock	( clock     ),
	.reset	( reset_mac ),
	.A		( data_2    ),   
	.B		( coef_2 	),     
	.MAC_OUT( mac_out_2 )
);

FIR_MAC18x36_top u3_mac (
	.clock	( clock     ),
	.reset	( reset_mac ),
	.A		( data_3    ),   
	.B		( coef_3 	),     
	.MAC_OUT( mac_out_3 )
);

// Stage 5: 2by2 adder
always @(posedge clock) begin
	if ( reset ) begin
		mac_out_0p1 <= 0;
		mac_out_2p3 <= 0;
	end
	else begin
		mac_out_0p1 <= mac_out_0 + mac_out_1;
		mac_out_2p3 <= mac_out_2 + mac_out_3;
	end
end

// Stage 6: final adder
assign mac_out_final =  mac_out_0p1 + mac_out_2p3;
//assign mac_out_final = mac_out_0 + mac_out_1 + mac_out_2 + mac_out_3;


// Delay: data output enable
always @(posedge clock) begin
	if ( reset ) begin
		dataout_ready_d <= 0;
		dataout_ready 	<= 0;
	end
	else begin
		dataout_ready_d[9:0] <= {dataout_ready_d[8:0], rdataout_ready};
		dataout_ready 		 <= dataout_ready_d[5];
	end
end


// Discard the 35 LSbits (the fractional part of the result and round output
// we assume the filter gain will not exceed 1,
// so the 14 MSbits can be ignored or tested for overflow
always @*
begin
  if ( ~mac_out_final[34] )
    round_temp_out = mac_out_final[35+18:35];
  else	
    if ( mac_out_final[34] & ( | mac_out_final[33:0] ) )    // round up:
      round_temp_out = mac_out_final[35+18:35] + 1;  
    else
	  round_temp_out = mac_out_final[35+18:35] + mac_out_final[35];  
end

endmodule
			  