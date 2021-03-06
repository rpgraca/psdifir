`timescale 1ns/1ps

module RAM_xk_tb;

reg         clock;
reg         reset;
reg  [17:0] xin;
reg         enxk;
reg  [11:0] addrin;
wire [71:0] dout;

integer i;

parameter CLOCK_PERIOD = 10;

RAM_CB RAM_CB_1(  .clock( clock ) ,
               .reset( reset ),
			   .din( xin ),
			   .wen( enxk ),
			   .addrin( addrin ),
			   .dout( dout )
			  );

// The four data values			  
wire [17:0] dout0, dout1, dout2, dout3;

assign dout0 = dout[71-18*0:71-18*1+1];
assign dout1 = dout[71-18*1:71-18*2+1];
assign dout2 = dout[71-18*2:71-18*3+1];
assign dout3 = dout[71-18*3:71-18*4+1];

	  
initial
begin
  clock = 0;
  reset = 0;
  enxk = 0;
  xin = 0;
  addrin = 0;
  #3
  forever #(CLOCK_PERIOD/2) clock = ~clock; 
end

initial
begin
  # 100
  reset = 1;
  # 100
  reset = 0;
  # (CLOCK_PERIOD * 2083 * 4096 );
  $stop;
end



// generate enxk clock enable, period = 2083 clocks:
always 
begin
  repeat (2083)
    @(posedge clock);
  # 2
  enxk = 1;
  # CLOCK_PERIOD
  enxk = 0;
end

// freerunning write process into memory:
always @(posedge enxk)
begin
    #1 xin <= xin + 1;
end

// Read memory: one location per clock cycle:
always @(posedge enxk)
begin
  @(posedge clock);
  for(i=0; i<4096; i=i+1)
  begin
    #1
    addrin = i;
    @(posedge clock);
    // @(posedge clock);
  end
end
			  
endmodule
