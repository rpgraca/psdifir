

module RAM_coefs_8( clock,
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
input  [10:0] addrL;      // read address, 11 bits for 2k
input  [10:0] addrR;
output [287:0] coefL;				
output [287:0] coefR;
reg    [287:0] coefL;				
reg    [287:0] coefR;

// Memory for left coefficients, 8 banks, 36 x 2048:
reg [35:0] Lmem0[0:2047];				
reg [35:0] Lmem1[0:2047];				
reg [35:0] Lmem2[0:2047];				
reg [35:0] Lmem3[0:2047];		
reg [35:0] Lmem4[0:2047];				
reg [35:0] Lmem5[0:2047];				
reg [35:0] Lmem6[0:2047];				
reg [35:0] Lmem7[0:2047];		

// Memory for left coefficients, 8 banks, 36 x 2048:
reg [35:0] Rmem0[0:2047];				
reg [35:0] Rmem1[0:2047];				
reg [35:0] Rmem2[0:2047];				
reg [35:0] Rmem3[0:2047];		
reg [35:0] Rmem4[0:2047];				
reg [35:0] Rmem5[0:2047];				
reg [35:0] Rmem6[0:2047];				
reg [35:0] Rmem7[0:2047];		


initial
begin
  $readmemh("sim_data/coefs_RAM0.hex", Rmem0 );
  $readmemh("sim_data/coefs_RAM1.hex", Rmem1 );
  $readmemh("sim_data/coefs_RAM2.hex", Rmem2 );
  $readmemh("sim_data/coefs_RAM3.hex", Rmem3 );
  $readmemh("sim_data/coefs_RAM4.hex", Rmem4 );
  $readmemh("sim_data/coefs_RAM5.hex", Rmem5 );
  $readmemh("sim_data/coefs_RAM6.hex", Rmem6 );
  $readmemh("sim_data/coefs_RAM7.hex", Rmem7 );

  $readmemh("sim_data/coefs_RAM0.hex", Lmem0 );
  $readmemh("sim_data/coefs_RAM1.hex", Lmem1 );
  $readmemh("sim_data/coefs_RAM2.hex", Lmem2 );
  $readmemh("sim_data/coefs_RAM3.hex", Lmem3 );
  $readmemh("sim_data/coefs_RAM4.hex", Lmem4 );
  $readmemh("sim_data/coefs_RAM5.hex", Lmem5 );
  $readmemh("sim_data/coefs_RAM6.hex", Lmem6 );
  $readmemh("sim_data/coefs_RAM7.hex", Lmem7 );
end

	
//------------------------------------------
// Write process for left memory:
wire [2:0] selLmem;
// select which memory to write in:
assign selLmem = addrLrw[2:0];
always @(posedge clock)
begin
  if ( weL )
  begin
    case ( selLmem )
      3'b000: Lmem0[ addrLrw[13:3] ] <= datainLrw;
      3'b001: Lmem1[ addrLrw[13:3] ] <= datainLrw;
      3'b010: Lmem2[ addrLrw[13:3] ] <= datainLrw;
      3'b011: Lmem3[ addrLrw[13:3] ] <= datainLrw;
      3'b100: Lmem4[ addrLrw[13:3] ] <= datainLrw;
      3'b101: Lmem5[ addrLrw[13:3] ] <= datainLrw;
      3'b110: Lmem6[ addrLrw[13:3] ] <= datainLrw;
      3'b111: Lmem7[ addrLrw[13:3] ] <= datainLrw;
    endcase
  end
end

//------------------------------------------
// Write process for right memory:
wire [2:0] selRmem;
// select which memory to write in:
assign selRmem = addrRrw[2:0];
always @(posedge clock)
begin
  if ( weR )
  begin
    case ( selRmem )
      3'b000: Rmem0[ addrRrw[13:3] ] <= datainRrw;
      3'b001: Rmem1[ addrRrw[13:3] ] <= datainRrw;
      3'b010: Rmem2[ addrRrw[13:3] ] <= datainRrw;
      3'b011: Rmem3[ addrRrw[13:3] ] <= datainRrw;
      3'b100: Rmem4[ addrRrw[13:3] ] <= datainRrw;
      3'b101: Rmem5[ addrRrw[13:3] ] <= datainRrw;
      3'b110: Rmem6[ addrRrw[13:3] ] <= datainRrw;
      3'b111: Rmem7[ addrRrw[13:3] ] <= datainRrw;
    endcase
  end
end


//------------------------------------------
// Read process for left memory:
// select which memory to read from:
reg  [35:0] dataoutLrw0,
            dataoutLrw1,
            dataoutLrw2,
            dataoutLrw3,
            dataoutLrw4,
            dataoutLrw5,
            dataoutLrw6,
            dataoutLrw7;
			
always @(posedge clock)
begin
  dataoutLrw0 <= Lmem0[ addrLrw[13:3] ];
end

always @(posedge clock)
begin
  dataoutLrw1 <= Lmem1[ addrLrw[13:3] ];
end

always @(posedge clock)
begin
  dataoutLrw2 <= Lmem2[ addrLrw[13:3] ];
end

always @(posedge clock)
begin
  dataoutLrw3 <= Lmem3[ addrLrw[13:3] ];
end
			
always @(posedge clock)
begin
  dataoutLrw4 <= Lmem4[ addrLrw[13:3] ];
end

always @(posedge clock)
begin
  dataoutLrw5 <= Lmem5[ addrLrw[13:3] ];
end

always @(posedge clock)
begin
  dataoutLrw6 <= Lmem6[ addrLrw[13:3] ];
end

always @(posedge clock)
begin
  dataoutLrw7 <= Lmem7[ addrLrw[13:3] ];
end

// output selector for left channel:
always @*
begin
  case( selLmem )
    3'b000: dataoutLrw = dataoutLrw0;
    3'b001: dataoutLrw = dataoutLrw1;
    3'b010: dataoutLrw = dataoutLrw2;
    3'b011: dataoutLrw = dataoutLrw3;
    3'b100: dataoutLrw = dataoutLrw4;
    3'b101: dataoutLrw = dataoutLrw5;
    3'b110: dataoutLrw = dataoutLrw6;
    3'b111: dataoutLrw = dataoutLrw7;
  endcase
end


//------------------------------------------
// Read process for right memory:
// select which memory to read from:
reg  [35:0] dataoutRrw0,
            dataoutRrw1,
            dataoutRrw2,
            dataoutRrw3,
            dataoutRrw4,
            dataoutRrw5,
            dataoutRrw6,
            dataoutRrw7;
 
always @(posedge clock)
begin
  dataoutRrw0 <= Rmem0[ addrRrw[13:3] ];
end

always @(posedge clock)
begin
  dataoutRrw1 <= Rmem1[ addrRrw[13:3] ];
end

always @(posedge clock)
begin
  dataoutRrw2 <= Rmem2[ addrRrw[13:3] ];
end

always @(posedge clock)
begin
  dataoutRrw3 <= Rmem3[ addrRrw[13:3] ];
end

always @(posedge clock)
begin
  dataoutRrw4 <= Rmem4[ addrRrw[13:3] ];
end

always @(posedge clock)
begin
  dataoutRrw5 <= Rmem5[ addrRrw[13:3] ];
end

always @(posedge clock)
begin
  dataoutRrw6 <= Rmem6[ addrRrw[13:3] ];
end

always @(posedge clock)
begin
  dataoutRrw7 <= Rmem7[ addrRrw[13:3] ];
end

// output selector for left channel:
always @*
begin
  case( selRmem )
    3'b000: dataoutRrw = dataoutRrw0;
    3'b001: dataoutRrw = dataoutRrw1;
    3'b010: dataoutRrw = dataoutRrw2;
    3'b011: dataoutRrw = dataoutRrw3;
    3'b100: dataoutRrw = dataoutRrw4;
    3'b101: dataoutRrw = dataoutRrw5;
    3'b110: dataoutRrw = dataoutRrw6;
    3'b111: dataoutRrw = dataoutRrw7;
  endcase
end

//----------------------------------------
// Application memory data port (read only):
// Read process for left memory:
always @(posedge clock)
begin
  coefL <= { Lmem0[ addrL ], Lmem1[ addrL ], Lmem2[ addrL ], Lmem3[ addrL ], Lmem4[ addrL ] , Lmem5[ addrL ] , Lmem6[ addrL ] , Lmem7[ addrL ]  }; 
end

// Read process for right memory:
always @(posedge clock)
begin
  coefR <= { Rmem0[ addrR ], Rmem1[ addrR ], Rmem2[ addrR ], Rmem3[ addrR ], Rmem4[ addrR ] , Rmem5[ addrR ] , Rmem6[ addrR ] , Rmem7[ addrR ]  }; 
end



endmodule
				
