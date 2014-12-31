/*
  Simplified simulation model for the LM4550 audio codec
  jca@fe.up.pt, Nov 2012 
*/

`timescale 1ns/1ps

module LM4550_sim(
                   input XTAL_IN,
				   input RESET_N,
				   
				   output reg BIT_CLK,
				   input SYNC,
				   output reg SDATA_IN,
				   input SDATA_OUT,
				   
				   input signed [63:0] MICi,
				   input signed [63:0] LINE_IN_Li,
				   input signed [63:0] LINE_IN_Ri,
				   output reg signed [63:0] LINE_OUT_Li,
				   output reg signed [63:0] LINE_OUT_Ri,
				   output reg signed [63:0] HP_OUT_Li,
				   output reg signed [63:0] HP_OUT_Ri
				   );


// Analog I/Os	   
real MIC;
real LINE_IN_L, LINE_IN_R;
real HP_OUT_L, HP_OUT_R, LINE_OUT_L, LINE_OUT_R;	   

// Integer to real / real to interger conversion:
// integers are 64 bits with 32 bits for the fractional part
always @*
begin
  MIC = MICi / (64'h0000_0001_0000_0000*1.0);
  LINE_IN_L = LINE_IN_Li / (64'h0000_0001_0000_0000 * 1.0);
  LINE_IN_R = LINE_IN_Ri / (64'h0000_0001_0000_0000 * 1.0);
  LINE_OUT_Li = LINE_OUT_L * 64'h0000_0001_0000_0000;
  LINE_OUT_Ri = LINE_OUT_R * 64'h0000_0001_0000_0000;
  HP_OUT_Li = HP_OUT_L * 64'h0000_0001_0000_0000;
  HP_OUT_Ri = HP_OUT_R * 64'h0000_0001_0000_0000;
end

// Reference voltage: all voltages in then analog section are
// constrained to [-Vref, +Vref]
parameter Vref = 2.5;

// Analog internal signals:
real DAC_LEFT, DAC_RIGHT,
     DAC_LEFT_MIX1, DAC_RIGHT_MIX1,
	 MIC_MUX, MIC_MIX1,
	 LINE_LEFT_MUX, LINE_RIGHT_MUX,
	 LINE_LEFT_MIX1, LINE_RIGHT_MIX1,
	 MIX1_LEFT, MIX1_RIGHT,
	 MIX1_MONO,
	 REC_MUX_L, REC_MUX_R,
	 ADC_IN_L, ADC_IN_R;


// configuration registers (only 20 registers are actually used):
reg [15:0]  REGS[0:127];

// Digital signals:
// DAC inputs, ADC outputs
reg signed [17:0] DAC_LEFT_I, DAC_RIGHT_I, ADC_LEFT, ADC_RIGHT;

// frame and tag registers:
reg [219:0] framein;
reg [239:0] frameout;
reg [15:0]  tagin, tagout, tagout_r;

// control signals:
reg ac_link_ready,
    rqst_left, rqst_right,
	ready_left, ready_right;

// data slots for the output frame:
reg [19:0]  slotout1, slotout2, slotout3, slotout4,
            slotout5, slotout6, slotout7, slotout8,
            slotout9, slotout10, slotout11, slotout12;
			
// data slots from the input frame:
reg [19:0]  slotin1, slotin2, slotin3, slotin4,
            slotin5, slotin6, slotin7, slotin8,
            slotin9, slotin10, slotin11, slotin12;
			
// Aux variables:
integer i, j, k;


initial
begin
  BIT_CLK = 0;
  for (i=0; j<128; j=j+1)
    REGS[j] = 16'd0;
  slotout1 = 20'd0;
  slotout2 = 20'd0;
  slotout3 = 20'd0;
  slotout4 = 20'd0;
  slotout5 = 20'd0;
  slotout6 = 20'd0;
  slotout7 = 20'd0;
  slotout8 = 20'd0;
  slotout9 = 20'd0;
  slotout10 = 20'd0;
  slotout11 = 20'd0;
  slotout12 = 20'd0;
  
  tagout_r = 16'd0;  

  slotin1 = 20'd0;
  slotin2 = 20'd0;
  slotin3 = 20'd0;
  slotin4 = 20'd0;
  slotin5 = 20'd0;
  slotin6 = 20'd0;
  slotin7 = 20'd0;
  slotin8 = 20'd0;
  slotin9 = 20'd0;
  slotin10 = 20'd0;
  slotin11 = 20'd0;
  slotin12 = 20'd0;


end


//---------------------------------------------------------------------
// cold reset:
always @(posedge XTAL_IN)
begin
  if ( ~RESET_N )
  begin
    // Soft reset:
    REGS[7'h00] = 16'h0D50;
    
	// Output volume:
	REGS[7'h02] = 16'h8000;
    REGS[7'h04] = 16'h8000;
    REGS[7'h06] = 16'h8000;

	// Input volume:
    REGS[7'h0A] = 16'h0000;
    REGS[7'h0C] = 16'h8008;
    REGS[7'h0E] = 16'h8008;
    REGS[7'h10] = 16'h8808;
    REGS[7'h12] = 16'h8808;
    REGS[7'h14] = 16'h8808;
    REGS[7'h16] = 16'h8808;
    REGS[7'h18] = 16'h8808;
	
    // ADC sources:
    REGS[7'h1A] = 16'h0000;
    REGS[7'h1C] = 16'h8000;
	
	// General purpose:
    REGS[7'h20] = 16'h0000;
	
	// 3D control (read only)
    REGS[7'h22] = 16'h0101;
	
	// Powerdown ctrl/stat
    REGS[7'h26] = 16'h000X;

    // Extended Audio ID
    REGS[7'h28] = 16'hX201;
    REGS[7'h2A] = 16'h0000;
	
	// ADC / DAC data rate:
    REGS[7'h2C] = 16'hBB80;
    REGS[7'h32] = 16'hBB80;
  end
end


//---------------------------------------------------------------------
// the output frame made up of 12 20-bit slots:			
assign frameout_r = { slotout1, slotout2, slotout3, slotout4, slotout5, slotout6, 
                      slotout7, slotout8, slotout9, slotout10, slotout11, slotout12 };		 
		 
//---------------------------------------------------------------------
// Generate the BIT_CLK from XTAL_IN (divide by 2)
always @(posedge XTAL_IN)
  #1 BIT_CLK = ~BIT_CLK;

  
//---------------------------------------------------------------------
// Read input frame: frame starts with the rising edge of SYNC:
always @(posedge SYNC)
begin
  #1
  @(posedge BIT_CLK);    // wait for next rising edge of BIT_CLK
  if ( SYNC == 1'b0 )    // false SYNC, too short
  begin
    $display("SYNC error: too short positive pulse");
  end
  else
  begin
    #1
	// read the first 16 bits as the tag phase
    for(i=0; i<16; i=i+1)
    begin
	  // Capture incoming bits in the negative clock edge
      @(negedge BIT_CLK); 
      #1	  
	  tagin = {tagin[14:0], SDATA_OUT};
    end	
	// read the rest of the frame (220 bits, last slot is always discarded) 
    for(i=0; i<220; i=i+1)
    begin
	  // Capture incoming bits in the negative clock edge
      @(negedge BIT_CLK);
	  #1
	  framein = {framein[218:0], SDATA_OUT};
    end	
	// $display($time, "  Frame: %x, tag: %x", framein, tagin );
  end
 
 if ( tagin[15] ) // input frame is valid
 begin
   // split the received frame into the 11 data slots:
   { slotin1, slotin2, slotin3, slotin4, slotin5,
         slotin6, slotin7, slotin8, slotin9, slotin10, slotin11 } = framein[219:0]; 
   // Read / write configuration registers:
   if (tagin[14:13] == 2'b11 ) // valid write register slots:
   begin
     if ( slotin1[19] == 1'b1 ) // read data
	 begin
	   slotout2 = { REGS[ slotin1[18:12] ], 4'd0};
	   tagout_r[14] = 1'b1; // slot 1 has valid data (reg address and status)
	   tagout_r[13] = 1'b1; // slot 2 has valid data (register data)
	 end
	 else                   // write data
	 begin
	   if ( slotin1[18:12] == 7'h2C || slotin1[18:12] == 7'h32 ) // ADC / DAC data rate
	   begin
	     $display( $time, "Invalid write: changing sampling rate is not supported");
	   end
	   else
	   begin
	     if ( tagin[14:13] == 2'b11 ) // if valid data in slots 1 and 2:
		 begin
	       REGS[ slotin1[18:12] ] = slotin2[19:4];
	       $display($time, "  Writing register %x with %x", slotin1[18:12], slotin2[19:4]);
		   slotout2 = 20'd0;
		 end
	   end
	 end
   end
  
// form the data slots to be sent in the next frame:
   slotout1[19]    = 1'b0;           // always zero
   slotout1[18:12] = slotin1[18:12]; // requested register address
   slotout1[11]    = rqst_left;      // slot 3 request data (left channel)
   slotout1[10]    = rqst_right;     // slot 4 request data (right channel)
   slotout1[9:0]   = 10'd0;
   
   tagout_r[15] = ac_link_ready;       // AC link is ready
   tagout_r[12] = ready_left;          // slot 3 valid data (left ADC data)
   tagout_r[11] = ready_right;         // slot 4 valid data (right ADC data)
   
   tagout_r[10:0] = 11'd0;             // unused bits
   
   if (ready_left)
     slotout3 = {ADC_LEFT, 2'd0};
   else
     slotout3 = 20'd0;

   if (ready_right)
     slotout4 = {ADC_RIGHT, 2'd0};
   else
     slotout4 = 20'd0;

   // Unused slots padded with zeros:
   {slotout5, slotout6, slotout7, slotout8,
    slotout9, slotout10, slotout11, slotout12} = 160'd0;
	 					  
  // Output path (from DAC):
  // if valid data, extract the data samples for the DAC input:
    if ( tagin[12:11] == 2'b11 ) // valid data for left and right DAC
    begin
      DAC_LEFT_I  = slotin3[19:2];  // Extract left data from slot 3 (integer, 18 bits left justified)
      DAC_RIGHT_I = slotin4[19:2];  // Extact right data from slot 4 (integer, 18 bits left justified)
	  DAC_LEFT  = ( DAC_LEFT_I  * Vref ) / 18'h2_00_00; // convert to [-Vref, +Vref]
	  DAC_RIGHT = ( DAC_RIGHT_I * Vref ) / 18'h2_00_00;
    end
  end
  else
  begin
    $display($time," Invalid frame received: bit 15 of tag is 0");
  end
 
  // DAC outputs:
  DAC_LEFT_MIX1  = GainLeft(  DAC_LEFT,  REGS[7'h18] );
  DAC_RIGHT_MIX1 = GainRight( DAC_RIGHT, REGS[7'h18] );
  
  // The ADCs: map [-Vref, +Vref] to [10_0000_0000_0000_0000, 01_1111_1111_1111_1111]
  ADC_LEFT  = ADC_quantizer( ADC_IN_L );
  ADC_RIGHT = ADC_quantizer( ADC_IN_R );
end



always @(negedge SYNC)
begin
   #1
// form the data slots to be sent in the next frame:
   slotout1[19]    = 1'b0;           // always zero
   slotout1[18:12] = slotin1[18:12]; // requested register address
   slotout1[11]    = rqst_left;      // slot 3 request data (left channel)
   slotout1[10]    = rqst_right;     // slot 4 request data (right channel)
   slotout1[9:0]   = 10'd0;
   
   tagout_r[15] = ac_link_ready;       // AC link is ready
   tagout_r[12] = ready_left;          // slot 3 valid data (left ADC data)
   tagout_r[11] = ready_right;         // slot 4 valid data (right ADC data)
   
   tagout_r[10:0] = 11'd0;             // unused bits
   
   if (ready_left)
     slotout3 = {ADC_LEFT, 2'd0};
   else
     slotout3 = 20'd0;

   if (ready_right)
     slotout4 = {ADC_RIGHT, 2'd0};
   else
     slotout4 = 20'd0;

   // Unused slots padded with zeros:
   {slotout5, slotout6, slotout7, slotout8,
    slotout9, slotout10, slotout11, slotout12} = 160'd0; 			
end				





//---------------------------------------------------------------------
// Send output frame: frame starts with the rising edge of SYNC:
always @(posedge SYNC)
begin
  #1
  frameout = { slotout1, slotout2, slotout3, slotout4, slotout5, slotout6, 
                      slotout7, slotout8, slotout9, slotout10, slotout11, slotout12 }; // latch the frame data to output
  tagout = tagout_r;
  @(negedge BIT_CLK);    // wait for next falling edge of BIT_CLK
  #1
  // send the first 16 bits as the tag phase
  for(j=0; j<16; j=j+1)
  begin
	// send outgoing bits in the positive clock edge
    @(posedge BIT_CLK);
	#1
    SDATA_IN = tagout[15];	
	tagout = {tagout[14:0], 1'b0};
    if ( SYNC == 1'b0 )
	  $display($time, "SYNC error: SYNC is low during the tag phase");
  end	
  // send the rest of the frame (240 bits) 
  for(j=0; j<220; j=j+1)
  begin
	// send outgoing bits in the positive clock edge
    @(posedge BIT_CLK);
	#1
    SDATA_IN = frameout[239];
	frameout = {frameout[238:0], 1'b0};
    if ( SYNC == 1'b1 )
	  $display($time, " SYNC error: SYNC is high during the data phase (%d)", j);
  end
  // discard last slot, always send 0:
  SDATA_IN = 0;
  
end


//---------------------------------------------------------------------
// Update the analog path:
always @*
begin
 // MIC path: MIC input is assumed to be in the range [-Vref, +Vref]
  MIC_MUX  = GainMic( MIC, REGS[ 7'h0E ] & 16'h0040 ); // after the 20 db gain (bit 6 of reg 0E)
  MIC_MIX1 = GainMic( MIC_MUX, REGS[ 7'h0E ] & ~16'h0040 ); // after mic gain at MIX1
  
  // LINE IN path: 
  LINE_LEFT_MUX  = LINE_IN_L;
  LINE_RIGHT_MUX = LINE_IN_R;
  LINE_LEFT_MIX1  = GainLeft(  LINE_LEFT_MUX,  REGS[7'h10] );
  LINE_RIGHT_MIX1 = GainRight( LINE_RIGHT_MUX, REGS[7'h10] );
  
  // MIX 1 output: add DAC_MIX1, MIC_MUX1 and LINE_IN_MIX1, then saturate again:
  MIX1_LEFT  = Saturate2Vref( MIC_MIX1 + LINE_LEFT_MIX1  + DAC_LEFT_MIX1);
  MIX1_RIGHT = Saturate2Vref( MIC_MIX1 + LINE_RIGHT_MIX1 + DAC_RIGHT_MIX1);
  MIX1_MONO  = ( MIX1_LEFT + MIX1_RIGHT ) / 2.0;
  
  // NOTE: register 20h is not implemented, so the MIX2 output is always
  //       equal to the MIX1 output
  
  // LINE_OUT output: pass through the master volume attenuation:
  LINE_OUT_L = MasterGainLeft(  MIX1_LEFT,  REGS[7'h02] );
  LINE_OUT_R = MasterGainRight( MIX1_RIGHT, REGS[7'h02] );
  
  // Headphones output: pass through the master headphone attenuation:
  HP_OUT_L = MasterGainLeft(  MIX1_LEFT,  REGS[7'h04] );
  HP_OUT_R = MasterGainRight( MIX1_RIGHT, REGS[7'h04] );
  
  // Input path (to ADCs):
  // After the record selector mux:
  REC_MUX_L = RecordSelectorLeft(  MIC_MUX, LINE_LEFT_MUX,  
                                   MIX1_LEFT,  MIX1_MONO, 
								   REGS[7'h1A] );
  REC_MUX_R = RecordSelectorRight( MIC_MUX, LINE_RIGHT_MUX, 
                                   MIX1_RIGHT, MIX1_MONO,
								   REGS[7'h1A] );
  
  // Before the ADC:
  ADC_IN_L = ADC_GainLeft(  REC_MUX_L, REGS[7'h1C] );
  ADC_IN_R = ADC_GainRight( REC_MUX_R, REGS[7'h1C] );
end




//---------------------------------------------------------------------
// set the sampling rate and internal codec status:
// for now, keep the samping rate equal to the SYNC rate and ignore the
// data written to register
initial
begin
  // always send valid samples and request new samples in every frame:
  rqst_left = 1;
  rqst_right = 1;
  ready_left = 1;
  ready_right = 1;
  // wait some time and make ready the analog blocks:
  #2453  // 2.453 us 
  REGS[ 7'h26 ] = 16'h000F;
  // wait some more time and set the AC link interface ready:
  #371
  ac_link_ready = 1;
end

//---------------------------------------------------------------------
//  Tasks for adjusting the gains of the analog paths
//---------------------------------------------------------------------
// maximum gain = 12 dB (3.99 X)
// maximum attenuation = 34.5dB (1/53.09 X)
function real GainLeft( input real data, input [15:0] gain );
real gaindb, gainlin, dataout;
begin
  if ( gain[15] )  // mute
    gainlin = 0;
  else
  begin 
    gaindb = gain[12:8] * (-1.5) + 12;
	gainlin = 10 ** (gaindb / 20);
  end
  dataout = data * gainlin;
  GainLeft = Saturate2Vref( dataout );
end
endfunction


function real GainRight( input real data, input [15:0] gain );
real gaindb, gainlin, dataout;
begin
  if ( gain[15] )  // mute
    gainlin = 0;
  else
  begin 
    gaindb = gain[4:0] * (-1.5) + 12;
	gainlin = 10 ** (gaindb / 20);
  end
  dataout = data * gainlin;
  GainRight = Saturate2Vref( dataout );
end
endfunction


function real GainMic( input real data, input [15:0] gain );
real gaindb, gainlin, dataout;
begin
  if ( gain[15] )  // mute
    gainlin = 0;
  else
  begin 
    gaindb = gain[4:0] * (-1.5) + 12 + 20 * gain[6];
	gainlin = 10 ** (gaindb / 20);
  end
  dataout = data * gainlin;
  GainMic = Saturate2Vref( dataout );
end
endfunction


function real MasterGainLeft( input real data, input [15:0] gain );
real gaindb, gainlin, dataout;
begin
  if ( gain[15] )  // mute
    gainlin = 0;
  else
  begin 
    gaindb = gain[12:8] * (-1.5);
	gainlin = 10 ** (gaindb / 20);
  end
  dataout = data * gainlin;
  MasterGainLeft = Saturate2Vref( dataout );
end
endfunction


function real MasterGainRight( input real data, input [15:0] gain );
real gaindb, gainlin, dataout;
begin
  if ( gain[15] )  // mute
    gainlin = 0;
  else
  begin 
    gaindb = gain[4:0] * (-1.5);
	gainlin = 10 ** (gaindb / 20);
  end
  dataout = data * gainlin;
  MasterGainRight = Saturate2Vref( dataout );
end
endfunction



function real Saturate2Vref( input real data );
begin
  if ( data > Vref )
    Saturate2Vref = +Vref;
  else
    if ( data < -Vref )
      Saturate2Vref = -Vref;
	else 
	  Saturate2Vref = data;
end
endfunction



function real RecordSelectorLeft(  input real MIC, 
                                   input real LINE,  
								   input real MIX1,  
								   input real MIX1_MONO,  
								   input [15:0] sel );
begin
  case( sel[10:8] )
    3'b000: RecordSelectorLeft = MIC;
    3'b100: RecordSelectorLeft = LINE;
    3'b101: RecordSelectorLeft = MIX1;
    3'b110: RecordSelectorLeft = MIX1_MONO;
    default: RecordSelectorLeft = 0.0;
  endcase
end
endfunction


function real RecordSelectorRight( input real MIC, 
                                   input real LINE,  
								   input real MIX1,  
								   input real MIX1_MONO,  
								   input [15:0] sel );
begin
  case( sel[2:0] )
    3'b000: RecordSelectorRight = MIC;
    3'b100: RecordSelectorRight = LINE;
    3'b101: RecordSelectorRight = MIX1;
    3'b110: RecordSelectorRight = MIX1_MONO;
    default: RecordSelectorRight = 0.0;
  endcase
end
endfunction

		
								   
function real ADC_GainLeft( input real data, input [15:0] gain );
real gaindb, gainlin, dataout;
begin
  if ( gain[15] )  // mute
    gainlin = 0;
  else
  begin 
    gaindb = gain[11:8] * 1.5;
	gainlin = 10 ** (gaindb / 20);
  end
  dataout = data * gainlin;
  ADC_GainLeft = Saturate2Vref( dataout );
end
endfunction								   

								   
function real ADC_GainRight( input real data, input [15:0] gain );
real gaindb, gainlin, dataout;
begin
  if ( gain[15] )  // mute
    gainlin = 0;
  else
  begin 
    gaindb = gain[3:0] * 1.5;
	gainlin = 10 ** (gaindb / 20);
  end
  dataout = data * gainlin;
  ADC_GainRight = Saturate2Vref( dataout );
end
endfunction								   


function [17:0] ADC_quantizer( input real ADC_IN );
reg [17:0] ADC_output;
begin
  ADC_output = ( ( ADC_IN + Vref ) / (2*Vref) ) * ( 18'h3_FFFF ); // range: 000..000 to 111..111
  ADC_quantizer = { ~ADC_output[17], ADC_output[16:0] }; // range: 100..000 to 011..111
end
endfunction

endmodule

