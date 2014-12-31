
`timescale 1ns/1ps

module s6base_tb;

								
// clocks:
reg				clk100M, reset_n;

//reg [31:0]data32;
 
// push buttons:
wire				btnu, btnr, btnd, btnl, btnc;
reg       [4:0]     btns;

// slide switches:
wire				sw7, sw6, sw5, sw4, sw3, sw2, sw1, sw0;
reg       [7:0]     sws;

// LEDs:
wire 			    ld0, ld1, ld2, ld3, ld4, ld5, ld6, ld7;
wire      [7:0]     leds;

// RS232:
wire			rx, tx;
//---------------------------------------------------------LM$4550 SIM

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



// set the XTALIN clock period in nanoseconds:
parameter CLOCK_PERIOD = 1 / 0.024576;
         
			 
			 
reg [15:0]DIN;
reg [5:0] REGID;
reg WE,RE;
reg RESET;
reg [3:0] Status_Read;




// Initialize the digital inputs and start the master clock:
initial
begin
 XTAL_IN = 1'b0; 
	#2
  forever #( CLOCK_PERIOD / 2 ) XTAL_IN = ~XTAL_IN;
  
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


//------------------------------------------------------------------
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

s6base s6base_1( 
								//------------------------------------------------------------------
                        // main clock sources:
               .clockext100MHz(clk100M),	// master clock input (external oscillator 100MHz)
               .reset_n(reset_n),           // external reset, active low
				//------------------------------------------------------------------
               // push buttons: button down = logic 1 (no debouncing hw)
				.btnu( btnu ),			// button up
				.btnr( btnr ),
				.btnd( btnd ),
				.btnl( btnl ),			// button left
				.btnc( btnc ),          // button center

				//------------------------------------------------------------------
               // Slide switches:
				.sw0( sw0 ),
				.sw1( sw1 ),
				.sw2( sw2 ),
				.sw3( sw3 ),
				.sw4( sw4 ),
				.sw5( sw5 ),
				.sw6( sw6 ),
				.sw7( sw7 ),

				//------------------------------------------------------------------
				// LEDs: logic 1 lights the LED
				.ld7( ld7 ),			// LED 7 (leftmost)
				.ld6( ld6 ),
				.ld5( ld5 ),
				.ld4( ld4 ),
				.ld3( ld3 ),
				.ld2( ld2 ),
				.ld1( ld1 ),
				.ld0( ld0 ),			// LED 0 (rightmost)


				//------------------------------------------------------------------
				// Serial interface (RS232 port)
               .tx( tx ),			// tx data (output from the user circuit)
               .rx( rx ),
				//------------------------------------------------------------------	 
					 //codec interface AC97
					 .SDATA_IN(SDATA_IN),
					 .SDATA_OUT(SDATA_OUT),
					 .SYNC(SYNC),
					 .BIT_CLK(BIT_CLK),
					 .RESET_N(RESET_N)
);


// define bit vectors for the buttons, switches and leds:
assign {btnu, btnr, btnd, btnl, btnc} = btns;
assign { sw7, sw6, sw5, sw4, sw3, sw2, sw1, sw0} = sws;
assign leds = { ld7, ld6, ld5, ld4, ld3, ld2, ld1, ld0};

// Local signals for UART connection:
reg             uart_txen;
wire            uart_rxready, uart_txready;
reg  [7:0]      uart_din;
wire [7:0]      uart_dout;




// SUART (simple USART: 115200 baud, 8bit, 1 stop bit, no parity):
uart  uart_1  
                ( 
				  .clock(clk100M),	    // master clock (100MHz)
                  .reset(~reset_n),		// master reset, assynchronous, active high
                  .tx(rx),				// tx data, connected to rx input
                  .rx(tx),				// rx data, connected to tx output
                  .txen(uart_txen),			// load data into transmit buffer and initiate a transmission
                  .txready(uart_txready),	// ready to receive a new byte to tx
                  .rxready(uart_rxready),	// data is ready at dout port
                  .dout(uart_dout),			// data out (received data)
                  .din(uart_din)				// data in (data to transmit)
             );

				
// Initialize inputs, generate the 100 MHz clock signal:
initial
begin
  clk100M = 0;
  reset_n = 1;
  btns = 5'b0000_0;
  sws  = 8'b0000_0000;
  uart_txen = 1'b0;
  uart_din = 8'd0;
  #2
  // Generate the 100 MHz clock:
  forever #3 clk100M = ~clk100M;
end		

// generate the reset signal (note this is active low)
// Activate reset_n for 10 clock cycles (100 ns)
initial
begin
  # 500
  reset_n = 0;
  # 200
  reset_n = 1;
end		

//write Config registers


initial 
begin
	#10000
  // set master volume gain = 12dB, 12dB
  Controler_Codec_Read(Status_Read);
  #100000
  Controler_Codec_Write( 7'h02, 16'h0000); //master volume
  #100000
  //set headphones gain = -4.5dB, -10.5dB
  Controler_Codec_Write( 7'h04, 16'h0307 ); 
  #100000
  Controler_Codec_Write( 7'h10, 16'h0000 );
  #1000000
  /*Controler_Codec_Write( 7'h10, 16'h0800 ); 
   #100000
  Controler_Codec_Write( 7'h1A, 16'h0404 );//record select
   #100000
  Controler_Codec_Write( 7'h1C, 16'h0000 );//record gain
   #100000
  Controler_Codec_Write( 7'h18, 16'h0000 );//dac gain
  #100000
  Controler_Codec_Write( 7'h1A, 16'h0404 );//record select
  #100000
  // set mic 1 noboost, gain = 0dB
  Controler_Codec_Write( 7'h0E, 16'h0008 ); 
  #100000
  // set mic 1 boost, gain = 20dB
  Controler_Codec_Write( 7'h0E, 16'h0048 ); 
  #100000
  // mic 1 boost, gain = 20dB+12dB
  Controler_Codec_Write( 7'h0E, 16'h0040 ); 
  #100000
  // set linein gain = 12dB, 12dB
  Controler_Codec_Write( 7'h10, 16'h0000 ); 
  #100000
  // set linein gain = 12dB, 0dB
  Controler_Codec_Write( 7'h10, 16'h0008 ); 
  #100000
  // set linein gain = 0dB, 12dB
  Controler_Codec_Write( 7'h10, 16'h0800 ); 
  #100000
  // set linein gain = -6dB, -6dB
  Controler_Codec_Write( 7'h10, 16'h0C0C ); 
  #100000
  // set ADC input gain = +6dB, +6dB
  Controler_Codec_Write( 7'h1C, 16'h0404 );  
  #100000
  // select record from line in:
  Controler_Codec_Write( 7'h1A, 16'h0404 ); //
  #100000
  // set ADC input gain = 0dB, 0dB
  Controler_Codec_Write( 7'h1C, 16'h0000 );  
  #100000
  // select record from mono mix:
  Controler_Codec_Write( 7'h1A, 16'h0404 ); //
  #100000
  // select record from MIC in:
  Controler_Codec_Write( 7'h1A, 16'h0000 ); //
  #100000
  // set DAC output gain (input of MIX1) -12 dB, -12 dB
  Controler_Codec_Write( 7'h18, 16'h1010 ); //
  #100000
  // mute line in and mic to MIX1
  Controler_Codec_Write( 7'h10, 16'h8000 ); //
  #100000
  Controler_Codec_Write( 7'h0E, 16'h8000 ); //
  #100000
  // select record from MONO mix:
  Controler_Codec_Write( 7'h1A, 16'h0606 ); //
  #100000
  /*Controler_Codec_Read(Status_Read);
  #100000*/
	
$stop;
end

// Example of commands to use the ioports module:

// Write 32bit data to a port:
task WritePort;
input [31:0] data;
input [3:0]  port;
begin
  // send command WRITE:
  SendData( { 4'b0010, port } );
  // send data:
  SendData( data[31:24] );
  SendData( data[23:16] );
  SendData( data[15:8] );
  SendData( data[7:0] );
end
endtask


// read 32 bit data from a port:
task ReadPort;
output [31:0] data;
input  [3:0]  port;
reg [7:0] b3, b2, b1, b0;
begin
  // send command READ:
  SendData( { 4'b0011, port } );
  GetData( b3 );
  GetData( b2 );
  GetData( b1 );
  GetData( b0 );
  data = { b3, b2, b1, b0};
end
endtask

//task to write from controler
task Controler_Codec_Write;
input [6:0] Regid_Controler;
input [15:0] DIN_Controler;
begin
	#10000
	WritePort(DIN_Controler,2);
	#10000
	WritePort(Regid_Controler,3);
	#10000
	WritePort(32'h01,15);
end
endtask

task Controler_Codec_Read;
output [3:0] Status_Controler;
begin
	#100000
	WritePort(32'h02,15);
	#100000
	ReadPort(Status_Controler,1);
end
endtask


// Send one byte to the UART, wait for the end of transmission:
task SendData;
input [7:0] data;
begin
 #50
 uart_din = data; // set value at the UART input databus
 @(negedge clk100M);
 uart_txen = 1; // start transmission
 #20
 uart_txen = 0;
 @( posedge uart_txready ) // wait for the end of transmission
 #50; // wait more...
end
endtask

task GetData;
output [7:0] data;
begin
  # 50
  @(negedge clk100M);
  // wait for a new byte received:
  while( uart_rxready == 1'b0 )
    @(negedge clk100M);
  data = uart_dout;
  #50;
end
endtask

endmodule

