`timescale 1ns/1ps

//`include "FIR_MAC18x36_slow_top.v"
//`include "verilog-rtl/FIR_MAC18x36_top.v"

module FIR_MAC8 (
	input      		   clock        ,
	input      		   reset        ,
	input	   		   datain_ready ,  // data in ready, used to start calculation of the FIR
	input	   [287:0] coefs_in     ,  // the 4 coefficients ready from memory
	input	   [143:0] datain       ,  // data read from the circular buffer
	output reg  [10:0] addr_coefs   ,  // address for the coefficient memory
	output reg  [10:0] addr_data    ,  // address for the circular buffer
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
reg 	    [10:0] count_samples;   										   // counts cycles of the main FSM (# of samples / 4 )
wire signed [52:0] mac_out_0, mac_out_1, mac_out_2, mac_out_3, mac_out_4, mac_out_5, mac_out_6, mac_out_7;                 // the output of the MAC unit
reg signed  [52:0] mac_out_0p1, mac_out_2p3, mac_out_4p5, mac_out_6p7;
reg signed  [52:0] mac_out_0i1, mac_out_2i3;
wire signed [52:0] mac_out_final;
wire signed [17:0] data_0, data_1, data_2, data_3, data_4, data_5, data_6, data_7;
wire signed [35:0] coef_0, coef_1, coef_2, coef_3, coef_4, coef_5, coef_6, coef_7;
reg signed  [17:0] round_temp_out;
reg 		[ 5:0] dataout_ready_d;
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
		
		reset_mac <= 1'b1;
	end
	else begin
		case( state )
			IDLE: begin
				if ( datain_ready ) begin// new sample arrived, start calculation of output sample:
					addr_coefs    <= 11'd0;
					addr_data     <= 11'd0;
					count_samples <= 13'd0;
					state         <= WAIT_DATA  ;
				end
			end

			WAIT_DATA: begin
				reset_mac     <= 1'b0;
				state		  <= RUN;
				count_samples  <= count_samples + 1'b1;

				addr_coefs     <= addr_coefs    + 1'b1;  // update address of coefficient memory
				addr_data      <= addr_data     + 1'b1;
			end

			RUN: begin
				//Update and Check RAM addresses
				if ( count_samples == 2047 ) begin 
					//dataout        <= round_temp_out;
					rdataout_ready <= 1'b1          ;         // assert dataout ready
					state          <= TERMINATE     ;
				end 
				else begin

					count_samples  <= count_samples + 1;

					addr_coefs     <= addr_coefs    + 1;  // update address of coefficient memory
					addr_data      <= addr_data     + 1;
					state		   <= RUN;
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

// Read 4 past data samples from the circular buffer (current address)
assign data_0 = datain[143:126]; // newest data sample
assign data_1 = datain[125:108];
assign data_2 = datain[107:90];
assign data_3 = datain[89:72]; 
assign data_4 = datain[71:54]; 
assign data_5 = datain[53:36];
assign data_6 = datain[35:18];
assign data_7 = datain[17:0];  // oldest data sample

// Read 4 coefficients from the coefficients memory
assign coef_0 = coefs_in[287:252];
assign coef_1 = coefs_in[251:216];
assign coef_2 = coefs_in[215:180];
assign coef_3 = coefs_in[179:144];
assign coef_4 = coefs_in[143:108];
assign coef_5 = coefs_in[107:72];
assign coef_6 = coefs_in[71:36];
assign coef_7 = coefs_in[35:0];

FIR_MAC18x36 u0_mac (
	.clock	( clock     ),
	.reset	( reset_mac ),
	.A		( data_0    ),   
	.B		( coef_0 	),     
	.MAC_OUT( mac_out_0 )
);

FIR_MAC18x36 u1_mac (
	.clock	( clock     ),
	.reset	( reset_mac ),
	.A		( data_1    ),   
	.B		( coef_1 	),     
	.MAC_OUT( mac_out_1 )
);

FIR_MAC18x36 u2_mac (
	.clock	( clock     ),
	.reset	( reset_mac ),
	.A		( data_2    ),   
	.B		( coef_2 	),     
	.MAC_OUT( mac_out_2 )
);

FIR_MAC18x36 u3_mac (
	.clock	( clock     ),
	.reset	( reset_mac ),
	.A		( data_3    ),   
	.B		( coef_3 	),     
	.MAC_OUT( mac_out_3 )
);

FIR_MAC18x36 u4_mac (
	.clock	( clock     ),
	.reset	( reset_mac ),
	.A		( data_4    ),   
	.B		( coef_4 	),     
	.MAC_OUT( mac_out_4 )
);

FIR_MAC18x36 u5_mac (
	.clock	( clock     ),
	.reset	( reset_mac ),
	.A		( data_5    ),   
	.B		( coef_5 	),     
	.MAC_OUT( mac_out_5 )
);

FIR_MAC18x36 u6_mac (
	.clock	( clock     ),
	.reset	( reset_mac ),
	.A		( data_6    ),   
	.B		( coef_6 	),     
	.MAC_OUT( mac_out_6 )
);

FIR_MAC18x36 u7_mac (
	.clock	( clock     ),
	.reset	( reset_mac ),
	.A		( data_7    ),   
	.B		( coef_7 	),     
	.MAC_OUT( mac_out_7 )
);

// Stage 5: 2by2 adder
always @(posedge clock) begin
	if ( reset ) begin
		mac_out_0p1 <= 0;
		mac_out_2p3 <= 0;
		mac_out_4p5 <= 0;
		mac_out_6p7 <= 0;
	end
	else begin
		mac_out_0p1 <= mac_out_0 + mac_out_1;
		mac_out_2p3 <= mac_out_2 + mac_out_3;
		mac_out_4p5 <= mac_out_4 + mac_out_5;
		mac_out_6p7 <= mac_out_6 + mac_out_7;
	end
end

// Stage 6: 2by2 adder
always @(posedge clock) begin
	if ( reset ) begin
		mac_out_0i1 <= 0;
		mac_out_2i3 <= 0;
	end
	else begin
		mac_out_0i1 <= mac_out_0p1 + mac_out_2p3;
		mac_out_2i3 <= mac_out_4p5 + mac_out_6p7;
	end
end

// Stage 7: final adder
assign mac_out_final =  mac_out_0i1 + mac_out_2i3;
//assign mac_out_final =  mac_out_0p1 + mac_out_2p3 + mac_out_4p5 + mac_out_6p7;
//assign mac_out_final = mac_out_0 + mac_out_1 + mac_out_2 + mac_out_3 + mac_out_4 + mac_out_5 + mac_out_6 + mac_out_7;


// Delay: data output enable
always @(posedge clock) begin
	if ( reset ) begin
		dataout_ready_d <= 0;
		dataout_ready 	<= 0;
	end
	else begin
		dataout_ready_d[5:0] <= {dataout_ready_d[4:0], rdataout_ready};
		dataout_ready 		 <= dataout_ready_d[5];
	end
end


// Discard the 35 LSbits (the fractional part of the result and round output
// we assume the filter gain will not exceed 1,
// so the 14 MSbits can be ignored or tested for overflow
always @*
begin
  if ( ~mac_out_final[34] )
    round_temp_out = mac_out_final[35+17:35];
  else	
    if ( mac_out_final[34] & ( | mac_out_final[33:0] ) )    // round up:
      round_temp_out = mac_out_final[35+17:35] + 1;  
    else
	  round_temp_out = mac_out_final[35+17:35] + mac_out_final[35];  
end

endmodule
			  
