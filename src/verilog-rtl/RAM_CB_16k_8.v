/*
RAM_CB_16k - 16k x 18 dual port circular buffer
PSD 2014/2015 - FEUP internal use only
jca@fe.up.pt

This module implements a 18-bit wide, dual-port memory, with internal 
write address generator and read address relative to the last write address.
The input write port is 18 bit wide (one data item) and the read data port is
4x18=72 bit wide, thus providing four 18 bit data items in each read cycle.

The whole memory operation is synchronous with the master clock. The memory
write port is controlled by the write enable signal (wen). When wen is
high, the 18-bit data at the input port (din) is synchronously written into the 
memory location pointed to by the last written address plus 1. The internal 
write address increments automatically at each write operation, implementing a 16k
circular buffer.

The read port receives an address that is relative to the address of the last written 
data and provides four data per read cycle. Reading from address 0 returns a 72-bit
word formed by the concatenation of the last 4 data items written, the oldest in the 
least 18 bits and the last data written in the most significant 18 bits: for example, if
the last 8 data items written were written in the order a b c d e f g h (a is the 
oldest, h is the last written), reading from address 0 will return the word formed 
by {h g f e} and reading from address 1 will return {d c b a}.

This code is intended to be compiled with XILINX XST, which will infer block RAMS
for implementing the four 18bit x 4k memories. Using ISE 14.6 (Windows version), setting
the optimization goal to speed+high, this synthesizes to 378 LUTs / 20 FFs / 16 BRAMs,
with a maximum clock frequency of 138 MHz (reading inputs from registers and writing
outputs to registers).
*/
module RAM_CB_16k( clock,
               reset,
			   din,
			   wen,
			   addrin,
			   dout
			  );
input         clock;  // Master clock, active int he positive edge
input         reset;  // master reset, synchronous and active high
input  [17:0] din;    // input data port
input         wen;    // Write enable
input  [10:0] addrin; // Read address, 13 bits (2048 x 8 data words)
output [143:0] dout;   // output read data: xn, xn-1  xn-2  xn-3 xn-4 xn-8

// The 4 RAM blocks, total memory is 16 K x 18 bit
// we need to divide the 4096 memories into two slices to convince XST
// to use the memory parity bits as data bits:
reg [17:0] RAM0 [0:2047];
reg [17:0] RAM1 [0:2047];
reg [17:0] RAM2 [0:2047];
reg [17:0] RAM3 [0:2047];
reg [17:0] RAM4 [0:2047];
reg [17:0] RAM5 [0:2047];
reg [17:0] RAM6 [0:2047];
reg [17:0] RAM7 [0:2047];

// write address counter (counts modulo 2^14 -> 0..16383)
reg [13:0] addrreg;

// output registers:
reg [17:0] dout0, dout1, dout2, dout3, dout4, dout5, dout6, dout7;

// Initialize memories with zeros
integer i;
integer k;
initial
begin
  k = 0;
  for(i=0; i<2048; i=i+1)
  begin
    RAM0[i] = 18'd0;
    RAM1[i] = 18'd0;
    RAM2[i] = 18'd0;
    RAM3[i] = 18'd0;
    RAM4[i] = 18'd0;
    RAM5[i] = 18'd0;
    RAM6[i] = 18'd0;
    RAM7[i] = 18'd0;
/*	
	RAM0A[i] =   k;
    RAM1A[i] = k+1;
    RAM2A[i] = k+2;
    RAM3A[i] = k+3;
    RAM0B[i] = 2048*4+k;
    RAM1B[i] = 2048*4+k+1;
    RAM2B[i] = 2048*4+k+2;
    RAM3B[i] = 2048*4+k+3;
	k = k + 4;
*/
end
end


// Address write counter: data is written sequentially from address 0
always  @(posedge clock)
begin
  if ( reset )
    addrreg <= 14'd0;
  else
    if ( wen )
	  addrreg <= addrreg + 1'b1;
end


// write process RAM0:
always  @(posedge clock)
begin
    if ( wen & ~addrreg[13] & ( addrreg[1:0] == 2'b00 ) )
	  RAM0[ addrreg[12:2] ] <= din;
end

always  @(posedge clock)
begin
    if ( wen & addrreg[13] & ( addrreg[1:0] == 2'b00 ) )
	  RAM1[ addrreg[12:2] ] <= din;
end



// write process RAM1:
always  @(posedge clock)
begin
    if ( wen & ~addrreg[13] & ( addrreg[1:0] == 2'b01 ) )
	  RAM2[ addrreg[13:2] ] <= din;
end

always  @(posedge clock)
begin
    if ( wen & addrreg[13] & ( addrreg[1:0] == 2'b01 ) )
	  RAM3[ addrreg[12:2] ] <= din;
end


// write process RAM2:
always  @(posedge clock)
begin
    if ( wen & ~addrreg[13] & ( addrreg[1:0] == 2'b10 ) )
	  RAM4[ addrreg[12:2] ] <= din;
end

always  @(posedge clock)
begin
    if ( wen & addrreg[13] & ( addrreg[1:0] == 2'b10 ) )
	  RAM5[ addrreg[12:2] ] <= din;
end


// write process RAM3:
always  @(posedge clock)
begin
    if ( wen & ~addrreg[13] & ( addrreg[1:0] == 2'b11 ) )
	  RAM6[ addrreg[12:2] ] <= din;
end

always  @(posedge clock)
begin
    if ( wen & addrreg[13] & ( addrreg[1:0] == 2'b11 ) )
	  RAM7[ addrreg[12:2] ] <= din;
end


// Read process:
// A read from address K will return the 4 data samples from the absolute read address:
// wr_addr - (addrin+1)*4:

wire [13:0] rd_addr, rd_addr0, rd_addr1, rd_addr2, rd_addr3, rd_addr4, rd_addr5, rd_addr6, rd_addr7;

// Calculate read address from the current write address:
assign rd_addr = addrreg - ( (addrin+1'b1) << 2'd2) ;

// read address from memories 0, 1, 2 and 3:
assign rd_addr0 = rd_addr + 3'd0;
assign rd_addr1 = rd_addr + 3'd1;
assign rd_addr2 = rd_addr + 3'd2;
assign rd_addr3 = rd_addr + 3'd3;
assign rd_addr4 = rd_addr + 3'd4;
assign rd_addr5 = rd_addr + 3'd5;
assign rd_addr6 = rd_addr + 3'd6;
assign rd_addr7 = rd_addr + 3'd7;

// Sequential read processes from each RAM
// address is formed by the upper 10 bits
// The lower 2 bits select the memory to read from

// Define the read address for RAM0 ~ RAM3:
reg [10:0] rd_addr_ram0;
reg [10:0] rd_addr_ram1;
reg [10:0] rd_addr_ram2;
reg [10:0] rd_addr_ram3;
reg [10:0] rd_addr_ram0;
reg [10:0] rd_addr_ram1;
reg [10:0] rd_addr_ram2;
reg [10:0] rd_addr_ram3;



always @*
begin
  if ( rd_addr0[2:0] == 3'b00 )
    rd_addr_ram0 = rd_addr0[13:3];
  else
    if ( rd_addr1[2:0] == 3'b00 )
      rd_addr_ram0 = rd_addr1[13:3];
    else
      if ( rd_addr2[2:0] == 3'b00 )
        rd_addr_ram0 = rd_addr2[13:3];
      else // rd_addr3[1:0] == 2'b00
        rd_addr_ram0 = rd_addr3[13:3];
end

// Define the read address for RAM1:
always @*
begin
  if ( rd_addr0[2:0] == 2'b01 )
    rd_addr_ram1 = rd_addr0[13:2];
  else
    if ( rd_addr1[2:0] == 2'b01 )
      rd_addr_ram1 = rd_addr1[13:2];
    else
      if ( rd_addr2[2:0] == 2'b01 )
        rd_addr_ram1 = rd_addr2[13:2];
      else // rd_addr3[1:0] == 2'b01
        rd_addr_ram1 = rd_addr3[13:2];
end

// Define the read address for RAM0:
always @*
begin
  if ( rd_addr0[1:0] == 2'b10 )
    rd_addr_ram2 = rd_addr0[13:2];
  else
    if ( rd_addr1[1:0] == 2'b10 )
      rd_addr_ram2 = rd_addr1[13:2];
    else
      if ( rd_addr2[1:0] == 2'b10 )
        rd_addr_ram2 = rd_addr2[13:2];
      else // rd_addr3[1:0] == 2'b10
        rd_addr_ram2 = rd_addr3[13:2];
end

// Define the read address for RAM0:
always @*
begin
  if ( rd_addr0[1:0] == 2'b11 )
    rd_addr_ram3 = rd_addr0[13:2];
  else
    if ( rd_addr1[1:0] == 2'b11 )
      rd_addr_ram3 = rd_addr1[13:2];
    else
      if ( rd_addr2[1:0] == 2'b11 )
        rd_addr_ram3 = rd_addr2[13:2];
      else // rd_addr3[1:0] == 2'b00
        rd_addr_ram3 = rd_addr3[13:2];
end



// Read from memories:
reg  [17:0] doutr0A, doutr1A, doutr2A, doutr3A;
reg  [17:0] doutr0B, doutr1B, doutr2B, doutr3B;
wire [17:0] doutr0, doutr1, doutr2, doutr3;

// RAM0A and RAM0B
always  @(posedge clock)
begin
  if ( ~rd_addr_ram0[11] )
    doutr0A <= RAM0A[ rd_addr_ram0[10:0] ];
end

always  @(posedge clock)
begin
  if ( rd_addr_ram0[11] )
    doutr0B <= RAM0B[ rd_addr_ram0[10:0] ];
end

// RAM1A and RAM1B
always  @(posedge clock)
begin
  if ( ~rd_addr_ram1[11] )
    doutr1A <= RAM1A[ rd_addr_ram1[10:0] ];
end

always  @(posedge clock)
begin
  if ( rd_addr_ram1[11] )
    doutr1B <= RAM1B[ rd_addr_ram1[10:0] ];
end

// RAM2A and RAM2B
always  @(posedge clock)
begin
  if ( ~rd_addr_ram2[11] )
    doutr2A <= RAM2A[ rd_addr_ram2[10:0] ];
end

always  @(posedge clock)
begin
  if ( rd_addr_ram2[11] )
    doutr2B <= RAM2B[ rd_addr_ram2[10:0] ];
end


// RAM3A and RAM3B
always  @(posedge clock)
begin
  if ( ~rd_addr_ram3[11] )
    doutr3A <= RAM3A[ rd_addr_ram3[10:0] ];
end

always  @(posedge clock)
begin
  if ( rd_addr_ram3[11] )
    doutr3B <= RAM3B[ rd_addr_ram3[10:0] ];
end

// read RAM muxes:
assign doutr0 = ~rd_addr_ram0[11] ? doutr0A : doutr0B;
assign doutr1 = ~rd_addr_ram1[11] ? doutr1A : doutr1B;
assign doutr2 = ~rd_addr_ram2[11] ? doutr2A : doutr2B;
assign doutr3 = ~rd_addr_ram3[11] ? doutr3A : doutr3B;


// Align output data:
always  @*
begin
   case ( rd_addr0[1:0] )
   2'b00: begin
            dout0 = doutr0;
            dout1 = doutr1;
            dout2 = doutr2;
            dout3 = doutr3;
          end
   2'b01: begin
            dout0 = doutr1;
            dout1 = doutr2;
            dout2 = doutr3;
            dout3 = doutr0;
          end
   2'b10: begin
            dout0 = doutr2;
            dout1 = doutr3;
            dout2 = doutr0;
            dout3 = doutr1;
          end
   2'b11: begin
            dout0 = doutr3;
            dout1 = doutr0;
            dout2 = doutr1;
            dout3 = doutr2;
          end
	endcase
end


// output 4 x 18 bit = 72 bit bus:
assign dout = { dout3, dout2, dout1, dout0};

  
endmodule
