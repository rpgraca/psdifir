

module RAM_coefs( clock,
                  reset,
				  addrLrw,
				  addrRrw,
				  datainLrw,
				  datainRrw,
				  dataoutLrw,
				  dataoutRrw,
				  weL,
				  weR,
				  addrL,
				  addrR,
				  coefL,
				  coefR
                );
			
input clock;
input reset;
input  [13:0] addrLrw;		// write address, 14 bits for 16k	
input  [13:0] addrRrw;			
input  [35:0] datainLrw;
input  [35:0] datainRrw;
output [35:0] dataoutLrw;
output [35:0] dataoutRrw;
reg    [35:0] dataoutLrw;
reg    [35:0] dataoutRrw;
input         weL;
input         weR;
input  [11:0] addrL;      // read address, 12 bits for 4k
input  [11:0] addrR;
output [143:0] coefL;				
output [143:0] coefR;
reg    [143:0] coefL;				
reg    [143:0] coefR;

// Memory for left coefficients, 4 banks, 36 x 4096:
reg [35:0] Lmem0[0:4095];				
reg [35:0] Lmem1[0:4095];				
reg [35:0] Lmem2[0:4095];				
reg [35:0] Lmem3[0:4095];		

// Memory for right coefficients, 4 banks, 36 x 4096:
reg [35:0] Rmem0[0:4095];				
reg [35:0] Rmem1[0:4095];				
reg [35:0] Rmem2[0:4095];				
reg [35:0] Rmem3[0:4095];		


initial
begin
  $readmemh("../sim_data/coefs_RAM0.hex", Rmem0 );
  $readmemh("../sim_data/coefs_RAM1.hex", Rmem1 );
  $readmemh("../sim_data/coefs_RAM2.hex", Rmem2 );
  $readmemh("../sim_data/coefs_RAM3.hex", Rmem3 );

  $readmemh("../sim_data/coefs_RAM0.hex", Lmem0 );
  $readmemh("../sim_data/coefs_RAM1.hex", Lmem1 );
  $readmemh("../sim_data/coefs_RAM2.hex", Lmem2 );
  $readmemh("../sim_data/coefs_RAM3.hex", Lmem3 );
end

	
//------------------------------------------
// Write process for left memory:
wire [1:0] selLmem;
// select which memory to write in:
assign selLmem = addrLrw[1:0];
always @(posedge clock)
begin
  if ( weL )
  begin
    case ( selLmem )
      2'b00: Lmem0[ addrLrw[13:2] ] <= datainLrw;
      2'b01: Lmem1[ addrLrw[13:2] ] <= datainLrw;
      2'b10: Lmem2[ addrLrw[13:2] ] <= datainLrw;
      2'b11: Lmem3[ addrLrw[13:2] ] <= datainLrw;
    endcase
  end
end

//------------------------------------------
// Write process for right memory:
wire [1:0] selRmem;
// select which memory to write in:
assign selRmem = addrRrw[1:0];
always @(posedge clock)
begin
  if ( weR )
  begin
    case ( selRmem )
      2'b00: Rmem0[ addrRrw[13:2] ] <= datainRrw;
      2'b01: Rmem1[ addrRrw[13:2] ] <= datainRrw;
      2'b10: Rmem2[ addrRrw[13:2] ] <= datainRrw;
      2'b11: Rmem3[ addrRrw[13:2] ] <= datainRrw;
    endcase
  end
end


//------------------------------------------
// Read process for left memory:
// select which memory to read from:
reg  [35:0] dataoutLrw0,
            dataoutLrw1,
            dataoutLrw2,
            dataoutLrw3;
			
always @(posedge clock)
begin
  dataoutLrw0 <= Lmem0[ addrLrw[13:2] ];
end

always @(posedge clock)
begin
  dataoutLrw1 <= Lmem1[ addrLrw[13:2] ];
end

always @(posedge clock)
begin
  dataoutLrw2 <= Lmem2[ addrLrw[13:2] ];
end

always @(posedge clock)
begin
  dataoutLrw3 <= Lmem3[ addrLrw[13:2] ];
end

// output selector for left channel:
always @*
begin
  case( selLmem )
    2'b00: dataoutLrw = dataoutLrw0;
    2'b01: dataoutLrw = dataoutLrw1;
    2'b10: dataoutLrw = dataoutLrw2;
    2'b11: dataoutLrw = dataoutLrw3;
  endcase
end


//------------------------------------------
// Read process for right memory:
// select which memory to read from:
reg  [35:0] dataoutRrw0,
            dataoutRrw1,
            dataoutRrw2,
            dataoutRrw3;
 
always @(posedge clock)
begin
  dataoutRrw0 <= Rmem0[ addrRrw[13:2] ];
end

always @(posedge clock)
begin
  dataoutRrw1 <= Rmem1[ addrRrw[13:2] ];
end

always @(posedge clock)
begin
  dataoutRrw2 <= Rmem2[ addrRrw[13:2] ];
end

always @(posedge clock)
begin
  dataoutRrw3 <= Rmem3[ addrRrw[13:2] ];
end

// output selector for left channel:
always @*
begin
  case( selRmem )
    2'b00: dataoutRrw = dataoutRrw0;
    2'b01: dataoutRrw = dataoutRrw1;
    2'b10: dataoutRrw = dataoutRrw2;
    2'b11: dataoutRrw = dataoutRrw3;
  endcase
end

//----------------------------------------
// Application memory data port (read only):
// Read process for left memory:
always @(posedge clock)
begin
  coefL <= { Lmem0[ addrL ], Lmem1[ addrL ], Lmem2[ addrL ], Lmem3[ addrL ] }; 
end

// Read process for right memory:
always @(posedge clock)
begin
  coefR <= { Rmem0[ addrR ], Rmem1[ addrR ], Rmem2[ addrR ], Rmem3[ addrR ] }; 
end



endmodule
				