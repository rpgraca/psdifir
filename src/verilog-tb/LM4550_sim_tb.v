/*
  Generic testbench for designs using the LM4550 simulation model
  jca@fe.up.pt, Nov 2012 
*/
`timescale 1ns/1ps
module LM4550_sim_tb;

reg XTAL_IN;
wire RESET_N, SYNC;
wire SDATA_OUT;
wire BIT_CLK, SDATA_IN;
reg signed  [63:0] MICi, LINE_IN_Li, LINE_IN_Ri;// integers to connect to the "analog" inputs/outputs of the LM4550
wire signed [63:0] LINE_OUT_Li, LINE_OUT_Ri,
                   HP_OUT_Li, HP_OUT_Ri;
real MIC;// Analog I/Os	
real LINE_IN_L, LINE_IN_R;
real HP_OUT_L, HP_OUT_R, LINE_OUT_L, LINE_OUT_R;	 

// Signals from the sine generators:
wire signed [63:0] MIC_gen, LINEIN_L_gen, LINEIN_R_gen;  

//signals to feed as entradas digitais do controlador
reg [17:0] DAC_LEFT, DAC_RIGHT;

// set the XTALIN clock period in nanoseconds:
parameter CLOCK_PERIOD = 1 / 0.024576,
          MASTER_CLOCK=1/0.1;//trocado 0.1

//----------------------------------------------------------------------------------
reg [15:0]DIN;
reg [5:0] REGID;
wire [3:0] STATUS;
reg WE,RE;
wire RDY,DIN_RDY;
wire DOUT_RQST;
reg CLOCK;
reg RESET;
wire [17:0] RIGHT_IN,LEFT_IN;
reg [17:0] RIGHT_OUT,LEFT_OUT;

// Instantiate the LM4550 simulation model:
LM4550_sim  LM4550_sim_1(
            .XTAL_IN( XTAL_IN ),
				   .RESET_N( RESET_N ),
				   .BIT_CLK( BIT_CLK ),
				   .SYNC( SYNC ),
				   .SDATA_IN( SDATA_IN ),
				   .SDATA_OUT( SDATA_OUT ),
				   .MICi( MICi ),
				   .LINE_IN_Li( LINE_IN_Li ),
				   .LINE_IN_Ri( LINE_IN_Ri ),
				   .LINE_OUT_Li( LINE_OUT_Li ),
				   .LINE_OUT_Ri( LINE_OUT_Ri ),
				   .HP_OUT_Li( HP_OUT_Li ),
				   .HP_OUT_Ri( HP_OUT_Ri )
				   );

 controler_final Codec_final_1(
                .SDATA_IN(SDATA_IN),
                .SDATA_OUT(SDATA_OUT),
                .SYNC(SYNC),
                .BIT_CLK(BIT_CLK),
                .RESET_N(RESET_N),
                .DIN(DIN),
                .REGID(REGID),
                .STATUS(STATUS),
                .WE(WE),
                .RE(RE),
                .RDY(RDY),
                .DIN_RDY(DIN_RDY),
                .RIGHT_IN(RIGHT_IN),
                .LEFT_IN(LEFT_IN),
                .DOUT_RQST(DOUT_RQST),
                .RIGHT_OUT(DAC_RIGHT),
                .LEFT_OUT(DAC_LEFT),
                .RESET(RESET),
                .CLOCK(CLOCK));
                
//----------------------------------------------------------------------------------
// Integer to real and real to interger conversions:
// integers are 64 bits with 32 bits for the fractional part
always @*
begin
  MICi = MIC * 64'h0000_0001_0000_0000;
  LINE_IN_Li = LINE_IN_L * 64'h0000_0001_0000_0000;
  LINE_IN_Ri = LINE_IN_R * 64'h0000_0001_0000_0000;
  LINE_OUT_L = LINE_OUT_Li / (64'h0000_0001_0000_0000 * 1.0);
  LINE_OUT_R = LINE_OUT_Ri / (64'h0000_0001_0000_0000 * 1.0);
  HP_OUT_L = HP_OUT_Li / (64'h0000_0001_0000_0000 * 1.0);
  HP_OUT_R = HP_OUT_Ri / (64'h0000_0001_0000_0000 * 1.0);
end




//----------------------------------------------------------------------------------
// Initialize the digital inputs and start the master clock:
initial
begin
 XTAL_IN = 1'b0; 
	#2
  forever #( CLOCK_PERIOD / 2 ) XTAL_IN = ~XTAL_IN;
  
end
initial 
begin
 CLOCK=1'b0;
   #2
	forever #( MASTER_CLOCK/2) CLOCK =~CLOCK;//generate master clock =100MHZ
end
//----------------------------------------------------------------------------------
// Initialize the analog inputs:
initial
begin
  MIC = 0;
  LINE_IN_L = 0;
  LINE_IN_R = 0;
  DIN=0;
  REGID=0;
  WE=0;
  RE=0;
  RESET=0;
end

//----------------------------------------------------------------------------------
//Aplicar RESET;

initial
  begin
    @(negedge BIT_CLK)
      
      RESET=1;
      repeat(10)
        @(negedge BIT_CLK)
        
          RESET=0;
  end
  
  
initial 
    begin
      
  #200000
  // set master volume gain = 12dB, 12dB
  WRITE_REGISTER( 7'h02, 16'h0000); 
    #1000000
  // set headphones gain = -4.5dB, -10.5dB
  WRITE_REGISTER( 7'h04, 16'h0307 ); 
  #1000000
  // set mic 1 noboost, gain = 0dB
  WRITE_REGISTER( 7'h0E, 16'h0008 ); 
  #1000000
  // set mic 1 boost, gain = 20dB
  WRITE_REGISTER( 7'h0E, 16'h0048 ); 
  #1000000
  // mic 1 boost, gain = 20dB+12dB
  WRITE_REGISTER( 7'h0E, 16'h0040 ); 
  #1000000
  // set linein gain = 12dB, 12dB
  WRITE_REGISTER( 7'h10, 16'h0000 ); 
  #1000000
  // set linein gain = 12dB, 0dB
  WRITE_REGISTER( 7'h10, 16'h0008 ); 
  #1000000
  // set linein gain = 0dB, 12dB
  WRITE_REGISTER( 7'h10, 16'h0800 ); 
  #1000000
  // set linein gain = -6dB, -6dB
  WRITE_REGISTER( 7'h10, 16'h0C0C ); 
  #1000000
  // set ADC input gain = +6dB, +6dB
  WRITE_REGISTER( 7'h1C, 16'h0404 );  
  #1000000
  // select record from line in:
  WRITE_REGISTER( 7'h1A, 16'h0404 ); //
  #1000000
  // set ADC input gain = 0dB, 0dB
  WRITE_REGISTER( 7'h1C, 16'h0000 );  
  #1000000
  // select record from mono mix:
  WRITE_REGISTER( 7'h1A, 16'h0404 ); //
  #1000000
  // select record from MIC in:
  WRITE_REGISTER( 7'h1A, 16'h0000 ); //
  #1000000
  // set DAC output gain (input of MIX1) -12 dB, -12 dB
  WRITE_REGISTER( 7'h18, 16'h1010 ); //
  #2000000
  // mute line in and mic to MIX1
  WRITE_REGISTER( 7'h10, 16'h8000 ); //
  #2000000
  WRITE_REGISTER( 7'h0E, 16'h8000 ); //
  #2000000
  // select record from MONO mix:
  WRITE_REGISTER( 7'h1A, 16'h0606 ); //
  #2000000
  // select record from stereo mix:
  READ_REGISTER();
  #2000000
  WRITE_REGISTER( 7'h1A, 16'h0505 ); //
  #2000000
  $stop;
end
 
// Sine generators for the MIC and LINE IN inputs
// the reference signal is 1 Vpp (-0.5 to +0.5)
sinegen sinegen_mic( .clock( BIT_CLK ), 
                     .phasein( freq2phase( 8000 ) ), // 8000 Hz
				             .attenuation( 16'd10 ),         // 10x attenuation: -50mV..+50mV
				             .sineout( MIC_gen )),
				                            
	    sinegen_linein_L ( .clock( BIT_CLK ), 
                         .phasein( freq2phase( 3000 ) ), // 3000 Hz
				                 .attenuation( 16'd1 ),          // -0.5V..+0.5V
				                 .sineout( LINEIN_L_gen ) ),
				                
	    sinegen_linein_R(  .clock( BIT_CLK ), 
                         .phasein( freq2phase( 5000 ) ), // 5000Hz
				                 .attenuation( 16'd2 ),          // -0.25V..+0.25V
				                 .sineout( LINEIN_R_gen ));
				  
//----------------------------------------------------------------------------------
// Convert the sine generator outputs to floats:
always @*
begin
  MIC = MIC_gen / (64'h0000_0001_0000_0000 * 1.0);
  LINE_IN_L = LINEIN_L_gen / (64'h0000_0001_0000_0000 * 1.0);
  LINE_IN_R = LINEIN_R_gen / (64'h0000_0001_0000_0000 * 1.0);
end

//---------------------------------------------------------------------

// Generate a sawtooh signal for the two DAC channels:
initial
begin
  DAC_LEFT = 0;
  DAC_RIGHT = 0;
end

always @(posedge SYNC)
begin
  DAC_LEFT = DAC_LEFT + 5460;   // freq ~ 1 KHz
  DAC_RIGHT = DAC_RIGHT + 2700; // freq ~ 2 KHz
end





//Escrever em registos 
task WRITE_REGISTER(input [5:0]adress,input [15:0] data);
  begin
    WE<=1;
    DIN<=data;
    REGID<=adress;
  end
endtask
  
  task READ_REGISTER();
    begin
      RE<=1;
    end
endtask
    
// Convert frequency in Hz to the phase increment 
// required by sinegen (16 bits, 14 bits for the fractional part)
// phase = bits 23:14
// clock = BIT_CLK = 12.288 MHz
// Sine frequency = BIT_CLK / 1024 * phase_increment
// Phase = Freq / BIT_CLK * 1024


function [15:0] freq2phase(input [15:0] freq);
begin
  freq2phase = ( freq * 64'd1024 * 64'h40_00) / 12288000;
end
endfunction



endmodule
