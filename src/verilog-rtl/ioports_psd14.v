/*
 general purpose I/O ports (32 bits)
 output port "outf" has automatic return to zero after 4 clock cycles
 This is the version for PSD 2014/2015: includes the automatic addressing for 
 loading the 2 x 16k x 36 bit coefficient memory
 */
`timescale 1ns/100ps

module ioports_psd14( clk,    // master clock 
                reset,  // master reset, synchronous, active high
                load,   // load enable for din bus
                ready,  // ready to consume dout data
                enout,  // enable loading of dout data
                datain, // data in bus (8 bits)
                dataout,// data out bus (8 bits)
                in0,    // 8 32-bit input ports
                in1,    
                in2,    
                in3,    
                in4,    
                in5,    
                in6,    
                in7,    
                out0,   // 16 32-bit output ports
                out1, 
                out2, 
                out3, 
  			    out4, 
				out5,   
				out6,
				out7,
				out8,   
				out9,   
				outa,
				outb,
				outc,   
				outd,   
				oute,
				outf,    // port f has automatic return to zero after 4 clock cycles
				
				addrlr,   // address for the left memory
				datalrout,  // data to write into the memory
				wel,     // write enable for the left memory
				wer,     // write enable for the right memory
				datalin, // data read from the left memory
				datarin  // data read from the right memory
                );

input        clk, reset, load, ready;
output       enout;
input  [7:0] datain;
output [7:0] dataout;

input  [31:0] in0, in1, in2, in3, 
              in4, in5, in6, in7;
output [31:0] out0, out1, out2, out3,
              out4, out5, out6, out7,
              out8, out9, outa, outb,
              outc, outd, oute, outf;
				  
// Coefficient memory interface:				  
output [13:0] addrlr;
output [35:0] datalrout;
output        wel, wer;
input  [35:0] datalin, datarin;

reg [13:0] addrlr;
reg [35:0] datalrout;
reg        wel, wer;

// Registers:
reg    [5:0]  state;
reg    [31:0] out0, out1, out2, out3,
              out4, out5, out6, out7,
              out8, out9, outa, outb,
              outc, outd, oute, outf;
reg    [7:0]  dataout;
reg    [7:0]  byte3, byte2, byte1;
reg    [3:0]  nibble4;
reg           enout;
reg    [3:0]  address;
reg    [31:0] datatoout;
reg    [35:0] datatoout36;

reg           LR; // Selects the left or right memory



// State encoding:
parameter IDLE       = 5'b0,
          WRITECMD   = 5'd1,
          WRITECMD2  = 5'd2,
          WRITECMD3  = 5'd3,
          WRITECMD4  = 5'd4,
          READCMD    = 5'd5,
          READCMD2   = 5'd6,
          READCMD3   = 5'd7,
          READCMD4   = 5'd8,
          READCMD5   = 5'd9,
          READCMD6   = 5'd10,
          READCMD7   = 5'd11,
          READCMD8   = 5'd12,
			 
		  DELAY0     = 5'd13,
		  DELAY1     = 5'd14,
		  DELAY2     = 5'd15,
		  DELAY3     = 5'd16,

		  WRITELR01  = 6'd32,
		  WRITELR02  = 6'd33,
		  WRITELR03  = 6'd34,
		  WRITELR04  = 6'd35,
		  WRITELR05  = 6'd36,

        READLR01   = 6'd37,
        READLR02   = 6'd38,
        READLR03   = 6'd39,
        READLR04   = 6'd40,
        READLR05   = 6'd41,
        READLR06   = 6'd42,
        READLR07   = 6'd43,
        READLR08   = 6'd44,
        READLR09   = 6'd45,
        READLR10   = 6'd46;

// Commands:
parameter RESET      = 3'b001,
          WRITE      = 3'b010,
          READ       = 3'b011,
			 RSTADDR    = 3'b100,
			 WRITELR    = 3'b110,
			 READLR     = 3'b101,
			 XXXXXX     = 3'b111;



always @(posedge clk)
begin
  if ( reset )
  begin
    out0 <= 0;
    out1 <= 0;
    out2 <= 0;
    out3 <= 0;
    out4 <= 0;
    out5 <= 0;
    out6 <= 0;
    out7 <= 0;
    out8 <= 0;
    out9 <= 0;
    outa <= 0;
    outb <= 0;
    outc <= 0;
    outd <= 0;
    oute <= 0;
    outf <= 0;
    enout <= 0;
	byte3 <= 0;
	byte2 <= 0;
	byte1 <= 0;
	state <= 0; 
	
   addrlr <= 0;
   datalrout <= 36'd0;	
	LR <= 1'b0;
	wel <= 0;
	wer <= 0;
	
	datatoout36 <= 36'd0;
  end
  else
  begin
    case ( state )
      IDLE :        begin
                      if ( load )
                        case ( datain[6:4] ) // command
                          RESET : begin      // 001
                                    out0 <= 0;
                                    out1 <= 0;
                                    out2 <= 0;
                                    out3 <= 0;
                                    out4 <= 0;
                                    out5 <= 0;
                                    out6 <= 0;
                                    out7 <= 0;
                                    out8 <= 0;
                                    out9 <= 0;
                                    outa <= 0;
                                    outb <= 0;
                                    outc <= 0;
                                    outd <= 0;
                                    oute <= 0;
                                    outf <= 0;
                                    enout <= 0;
                                    state <= IDLE;
                                  end
                          WRITE : begin   // 010
                                    address <= datain[3:0]; // address of port
                                    state <= WRITECMD;
                                  end
                          READ  : begin   // 011
                                    case ( datain[2:0] )
                                      0: datatoout <= in0;
                                      1: datatoout <= in1;
                                      2: datatoout <= in2;
                                      3: datatoout <= in3;
                                      4: datatoout <= in4;
                                      5: datatoout <= in5;
                                      6: datatoout <= in6;
                                      7: datatoout <= in7;
                                    endcase
                                    state <= READCMD;
                                  end
								  RSTADDR:   // 100
								          begin
											   addrlr <= 0;
												state <= IDLE;
											 end
								  WRITELR:   // 110, bit 7 selects the left (0) or right (1) memory
								          begin
											   nibble4 <= datain[3:0]; // the 4 LSbits of the command
												LR <= datain[7];         // the left-right selector
												state <= WRITELR01;
											 end
								  READLR:   // 101
								          begin
											   if ( ~datain[7] )   // the left-right selector
												  datatoout36 <= datalin; // latch data from memory
												else
												  datatoout36 <= datarin;
											   state <= READLR01;
											 end
											 
 						  default : state <= IDLE;
                        endcase
                      else
                        state <= IDLE;
                    end
                    
      WRITECMD:     begin
                     if ( load )           // byte 3 arrived
                     begin
                       byte3 <= datain;       // load byte
                       state <= WRITECMD2;
                     end
                     else
                     begin
                       state <= WRITECMD;  // keep waiting for MS byte
                     end
                    end
					
     WRITECMD2:    begin
                     if ( load )           // byte 2 arrived
                     begin
                       byte2 <= datain;       // load byte 
                       state <= WRITECMD3;
                     end
                     else
                     begin
                       state <= WRITECMD2;  // keep waiting
                     end
                    end

	WRITECMD3:    begin
                     if ( load )           // byte 1 arrived
                     begin
                       byte1 <= datain;       // load byte 
                       state <= WRITECMD4;
                     end
                     else
                     begin
                       state <= WRITECMD3;  // keep waiting 
                     end
                    end
                    
                    
    WRITECMD4   : begin
                     if ( load )           // LSbyte arrived
                     begin
                       case ( address )
                         0 : out0 <= {byte3, byte2, byte1, datain};
                         1 : out1 <= {byte3, byte2, byte1, datain};
                         2 : out2 <= {byte3, byte2, byte1, datain};
                         3 : out3 <= {byte3, byte2, byte1, datain};
                         4 : out4 <= {byte3, byte2, byte1, datain};
                         5 : out5 <= {byte3, byte2, byte1, datain};
                         6 : out6 <= {byte3, byte2, byte1, datain};
                         7 : out7 <= {byte3, byte2, byte1, datain};
                         8 : out8 <= {byte3, byte2, byte1, datain};
                         9 : out9 <= {byte3, byte2, byte1, datain};
                         10: outa <= {byte3, byte2, byte1, datain};
                         11: outb <= {byte3, byte2, byte1, datain};
                         12: outc <= {byte3, byte2, byte1, datain};
                         13: outd <= {byte3, byte2, byte1, datain};
                         14: oute <= {byte3, byte2, byte1, datain};
                         15: outf <= {byte3, byte2, byte1, datain};
                       endcase
					   if ( address == 15 )
					     state <= DELAY0;  // wait 4 clock cycles
					   else
                         state <= IDLE;
                     end
                     else
                       state <= WRITECMD4;  // keep waiting for LS byte
                    end
					
      DELAY0      : state <= DELAY1;					
                    
      DELAY1      : state <= DELAY2;					
                    
      DELAY2      : state <= DELAY3;					
                    
      DELAY3      : begin
	                  outf <= 0;
	                  state <= IDLE;					
					end
                    
      READCMD     : begin
                      if ( ready )
                      begin
                        dataout <= datatoout[31:24]; // output byte 3
                        enout <= 1;
                        state <= READCMD2;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= READCMD;  // wait for ready
                      end
                    end
                    
      READCMD2    : begin              // wait for ready low
                      if ( ready )
                      begin
                        enout <= 1;    // keep enout active until ready is deasserted
                        state <= READCMD2;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= READCMD3;
                      end
                    end
                      
      READCMD3    : begin
                      if ( ready )
                      begin
                        dataout <= datatoout[23:16]; // output byte 2
                        enout <= 1;
                        state <= READCMD4;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= READCMD3;  // wait for ready
                      end
                    end
                    
      READCMD4    : begin              // wait for ready low
                      if ( ready )
                      begin
                        enout <= 1;    // keep enout active until ready is deasserted
                        state <= READCMD4;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= READCMD5;
                      end
                    end
                      
      READCMD5    : begin
                      if ( ready )
                      begin
                        dataout <= datatoout[15:8]; // output byte 1
                        enout <= 1;
                        state <= READCMD6;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= READCMD5;  // wait for ready
                      end
                    end
                    
      READCMD6    : begin              // wait for ready low
                      if ( ready )
                      begin
                        enout <= 1;    // keep enout active until ready is deasserted
                        state <= READCMD6;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= READCMD7;
                      end
                    end
                      
      READCMD7    : begin
                      if ( ready )
                      begin
                        dataout <= datatoout[7:0]; // output byte 0
                        enout <= 1;
                        state <= READCMD8;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= READCMD7;  // wait for ready
                      end
                    end
                    
      READCMD8    : begin              // wait for ready low
                      if ( ready )
                      begin
                        enout <= 1;    // keep enout active until ready is deasserted
                        state <= READCMD8;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= IDLE;
                      end
                    end
						  
     WRITELR01:    begin
                     if ( load )           // byte 3 arrived
                     begin
                       byte3 <= datain;       // load byte 3
                       state <= WRITELR02;
                     end
                     else
                     begin
                       state <= WRITELR01;  // keep waiting
                     end
                    end	
						  						  
     WRITELR02:    begin
                     if ( load )           // byte 2 arrived
                     begin
                       byte2 <= datain;       // load byte 2
                       state <= WRITELR03;
                     end
                     else
                     begin
                       state <= WRITELR02;  // keep waiting
                     end
                    end			
						  
     WRITELR03:    begin
                     if ( load )           // byte 1 arrived
                     begin
                       byte1 <= datain;       // load byte 1
                       state <= WRITELR04;
                     end
                     else
                     begin
                       state <= WRITELR03;  // keep waiting
                     end
                    end							  

     WRITELR04:    begin
                     if ( load )           // byte 0 arrived, write data into memory
                     begin
                       datalrout <= {nibble4, byte3, byte2, byte1, datain}; // 36 bit data
                       if ( ~LR )
							    wel <= 1'b1;  // LR zero selects left memory
							  else
							    wer <= 1'b1;  // LR one selects right memory
							  state <= WRITELR05;
                     end
                     else
                     begin
                       state <= WRITELR04;  // keep waiting
                     end
                    end	
					
     WRITELR05:    begin
	                  wer <= 1'b0;
							wel <= 1'b0;
							addrlr <= addrlr + 1;
							state <= IDLE;
                    end	
						  
      READLR01     : begin
                      if ( ready )
                      begin
                        dataout <= { {4{datatoout36[35]}}, datatoout36[35:32]}; // output nibble4, sign extend
                        enout <= 1;
                        state <= READLR02;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= READLR01;  // wait for ready
                      end
                    end
                    
      READLR02    : begin              // wait for ready low
                      if ( ready )
                      begin
                        enout <= 1;    // keep enout active until ready is deasserted
                        state <= READLR02;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= READLR03;
                      end
                    end
						  
      READLR03     : begin
                      if ( ready )
                      begin
                        dataout <= datatoout36[31:24]; // output byte3
                        enout <= 1;
                        state <= READLR04;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= READLR03;  // wait for ready
                      end
                    end
                    
      READLR04    : begin              // wait for ready low
                      if ( ready )
                      begin
                        enout <= 1;    // keep enout active until ready is deasserted
                        state <= READLR04;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= READLR05;
                      end
                    end
						  
      READLR05     : begin
                      if ( ready )
                      begin
                        dataout <= datatoout36[23:16]; // output byte2
                        enout <= 1;
                        state <= READLR06;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= READLR05;  // wait for ready
                      end
                    end
                    
      READLR06    : begin              // wait for ready low
                      if ( ready )
                      begin
                        enout <= 1;    // keep enout active until ready is deasserted
                        state <= READLR06;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= READLR07;
                      end
                    end
						  
      READLR07     : begin
                      if ( ready )
                      begin
                        dataout <= datatoout36[15:8]; // output nibble4, sign extend
                        enout <= 1;
                        state <= READLR08;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= READLR07;  // wait for ready
                      end
                    end
                    
      READLR08    : begin              // wait for ready low
                      if ( ready )
                      begin
                        enout <= 1;    // keep enout active until ready is deasserted
                        state <= READLR08;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= READLR09;
                      end
                    end
						  
      READLR09     : begin
                      if ( ready )
                      begin
                        dataout <= datatoout36[7:0]; // output nibble4, sign extend
                        enout <= 1;
                        state <= READLR10;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= READLR09;  // wait for ready
                      end
                    end
                    
      READLR10    : begin              // wait for ready low
                      if ( ready )
                      begin
                        enout <= 1;    // keep enout active until ready is deasserted
                        state <= READLR10;
                      end
                      else
                      begin
                        enout <= 0;
                        state <= IDLE;
                      end
                    end
 						   						   						   						   						  
      default     : begin
                      state <= IDLE;
                    end
    endcase
  end
end


endmodule

