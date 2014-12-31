/*
PSD 2014/2015 - Project 3 reference design
jca@fe.up.pt
FEUP internal use only
*/

`timescale 1ns/1ps

module s6base_top( 
						//------------------------------------------------------------------
                  // main clock sources:
                  clockext100MHz,	// master clock input (external oscillator 100MHz)
                  reset_n,        // external reset, active low
						//------------------------------------------------------------------
                        // push buttons: button down = logic 1 (no debouncing hw)
						btnu,			// button up
						btnr,
						btnd,
						btnl,			// button left
						btnc,           // button center

						//------------------------------------------------------------------
                        // Slide switches:
						sw0,
						sw1,
						sw2,
						sw3,
						sw4,
						sw5,
						sw6,
						sw7,

						//------------------------------------------------------------------
						// LEDs: logic 1 lights the LED
						ld7,			// LED 7 (leftmost)
						ld6,
						ld5,
						ld4,
						ld3,
						ld2,
						ld1,
						ld0,			// LED 6 (rightmost)


						//------------------------------------------------------------------
						// Serial interface (RS232 port)
                        tx,			// tx data (output from the user circuit)
                        rx,		// rx data (input to the user circuit)
								
								
						//------------------------------------------------------------------
						// Audio codec (LM4550)
					   SDATA_IN,
					   SDATA_OUT,
					   SYNC,
					   BIT_CLK,
					   RESET_N
					);
								
// clocks:
input				clockext100MHz, reset_n;

///////////////////registos do multi
// push buttons:
input				btnu, btnr, btnd, btnl, btnc;

// slide switches:
input				sw7, sw6, sw5, sw4, sw3, sw2, sw1, sw0;

// LEDs:
output 			ld0, ld1, ld2, ld3, ld4, ld5, ld6, ld7;

// RS232:
input			rx;
output			tx;


// global synchronous reset, active high
reg			reset_d, reset;

// External interface to the LM4550 audio codec
input SDATA_IN,BIT_CLK;
output SDATA_OUT,SYNC,RESET_N;
					


// UART local signals:
wire        txen, rxready, txready;

// data bus between UART and the command interpreter:
wire [ 7:0] din, dout;

// General 32-bit I/O ports:
// output ports (32 bits)
wire [31:0] P0out, P1out, P2out, P3out,
            P4out, P5out, P6out, P7out,
			   P8out, P9out, PAout, PBout,
			   PCout, PDout, PEout, PFout; 
// input ports (32 bits)			
wire [31:0] P0in,  P1in,  P2in,  P3in,
            P4in,  P5in,  P6in,  P7in;  
				


// Synchronize the external reset:
always @(posedge clockext100MHz)
begin
  reset_d <= ~reset_n;
  reset   <= reset_d;
end



// SUART (simple USART: 921600 baud, 8 bit, 1 stop bit, no parity):
uart  uart_1 ( 
				  .clock(clockext100MHz),	// master clock (100MHz)
                  .reset(reset),			// master reset, assynchronous, active high
                  .tx(tx),					// tx data, connected to rx input
                  .rx(rx),					// rx data, connected to tx output
                  .txen(txen),			// load data into transmit buffer and initiate a transmission
                  .txready(txready),	// ready to receive a new byte to tx
                  .rxready(rxready),	// data is ready at dout port
                  .dout(dout),			// data out (received data)
                  .din(din)				// data in (data to transmit)
                );

// RAM coefs interface:
wire [13:0] addrlr;
wire [35:0] datalrout;
wire        wel, wer;
wire [35:0] datalin, datarin;

// Command interpreter:
ioports_psd14 ioports_psd14_1
             ( 
				   .clk(clockext100MHz),	// master clock 
               .reset(reset),		// master reset, assynchronous, active high
               
               .load(rxready),		// load enable for din bus
               .ready(txready),		// ready to consume dout data
               .enout(txen),			// enable loading of dout data
               
               .datain(dout),		// data in bus (8 bits), from USART
               .dataout(din),		// data out bus (8 bits), to USART
               
               .in0(P0in),		  
               .in1(P1in),			
               .in2(P2in),        
               .in3(P3in),			
               .in4(P4in),		  
               .in5(P5in),			
               .in6(P6in),        
               .in7(P7in),			
               
               .out0(P0out),
               .out1(P1out),
               .out2(P2out),
               .out3(P3out),
               				 
				   .out4(P4out), 		
				   .out5(P5out),
				   .out6(P6out),
				   .out7(P7out),
                   
				   .out8(P8out), 					 
				   .out9(P9out),
				   .outa(PAout),
				   .outb(PBout),
                   
				   .outc(PCout), 					 
				   .outd(PDout),
				   .oute(PEout),
				   .outf(PFout),
									
				   .addrlr( addrlr ),        // address for both memories
				   .datalrout( datalrout ),  // data to write to both memories
				   .wel( wel ),              // write enable for the left memory
				   .wer( wer ),              // write enable for the right memory
				   .datalin( datalin ),      // data read from the left memory
				   .datarin( datarin )       // data read from the right memory
					);
					
					
//---------------------------------------------------------------------------------
wire SDATA_IN,SDATA_OUT,SYNC,BIT_CLK;
wire [15:0]DIN;
wire [5:0] REGID;
wire [3:0] STATUS;
wire WE,RE,RDY,DIN_RDY,DOUT_RQST;
wire RESET;
wire [17:0] LEFT_in, RIGHT_in, LEFT_out, RIGHT_out;

LM4550_controler LM4550_controler_1 (
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
                .RIGHT_IN(RIGHT_in),    // from codec
                .LEFT_IN(LEFT_in),
                .DOUT_RQST(DOUT_RQST),
                .RIGHT_OUT(RIGHT_out ),   // to codec
                .LEFT_OUT(LEFT_out ),
                .RESET(reset),
                .CLOCK(clockext100MHz)
					 );
					 
// assign control signals to access the LM4550 programming interface:					 
assign DIN=P2out[15:0];
assign REGID=P3out[5:0];
assign P1in={27'b0,STATUS};
assign WE=PFout[0];
assign RE=PFout[1];
assign P2in={31'd0,RDY};

// multiply ADC outputs by a digital gain, sw5 switches ON/OFF the digital gain:
wire [7:0]  gain;
wire [17:0] LEFT_ing, RIGHT_ing;
assign gain = P5out[7:0];
					 
assign LEFT_ing  = sw5 ? (LEFT_in * gain) : LEFT_in;
assign RIGHT_ing = sw5 ? (RIGHT_in * gain) : RIGHT_in;


// Generate a test signal, sawtooth. Frequeny = 381Hz * (P6+1) 
// Selected with SW7 (left channel) and SW6 (right channel)
reg [17:0] sawtooth;
always @(posedge clockext100MHz)
begin
   if ( reset )
	  sawtooth <= 18'd0;
	else
	begin
	  sawtooth <= sawtooth + P6out[3:0] + 1;
	end
end

assign LEFT_out   = sw7 ? sawtooth : LEFT_ing;					 
assign RIGHT_out  = sw6 ? sawtooth : RIGHT_ing;					 
					 				 

// generate a mono signal rectified to connect the high-order bits to the LEDs:
wire [18:0] mono_digital_mix;
wire [18:0] mono_digital_mix_rectified;
assign mono_digital_mix =  ( {LEFT_out[17], LEFT_out} + {RIGHT_out[17], RIGHT_out} ) / 2;
assign mono_digital_mix_rectified = mono_digital_mix[17] ? ( -mono_digital_mix ) : ( mono_digital_mix );
// Connect to LEDs:
assign {ld7, ld6, ld5, ld4, ld3, ld2, ld1, ld0} = mono_digital_mix_rectified[17:10];



// Read the least 8 significant bits of P0in as the positions of the 8 slide switches
assign P0in[ 7:0] = {sw7, sw6, sw5, sw4, sw3, sw2, sw1, sw0};
assign P0in[15:8] = 8'd0;

// Connect bits [20:16] to the push buttons:
assign P0in[31:16] = {11'd0, btnu, btnr, btnd, btnl, btnc };

// Unused input ports, connected to the output ports:
assign P3in = P3out;
assign P4in = P4out;
assign P5in = P5out;
assign P6in = P6out;

// dummy wires to read the coefs memory:
wire [143:0] dummyL, dummyR;

RAM_coefs  RAM_coefs_1( 
              .clock( clockext100MHz ),
              .reset( reset ),
				  .addrLrw( addrlr ),
				  .addrRrw( addrlr ),
				  .datainLrw( datalrout ),
				  .datainRrw( datalrout ),
				  .dataoutLrw( datalin ),
				  .dataoutRrw( datarin ),
				  .weL( wel ),
				  .weR( wer ),
				  
				  // User read interface, synchronous read:
				  .addrL( PBout[11:0] ), // Connect this to the address bus for the left coefficients
				  .addrR( PBout[11:0] ), // Connect this to the address bus for the right coefficients
				  .coefL( dummyL ),      // 144 bit coefficients ( 4 x 36 )
				  .coefR( dummyR )       // 144 bit coefficients ( 4 x 36 )
                );
				
// Do some assignment to output ports to avoid trimming the RAM logic
assign P7in = dummyL[31:0] ^ dummyL[63:32] ^ dummyL[95:64] ^ dummyL[127:96] ^ dummyL[143:128] ^
              dummyR[31:0] ^ dummyR[63:32] ^ dummyR[95:64] ^ dummyR[127:96] ^ dummyR[143:128];
				
	
endmodule

