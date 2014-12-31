`timescale 1ns/1ps

module sinegen( clock, phasein, attenuation, sineout );
input clock;
input [15:0] phasein;
input signed [15:0] attenuation;
output signed [63:0] sineout;
wire   signed [63:0] tabout;
reg [23:0] phase;
reg signed [31:0] tabsin[0:1023];

initial
begin
  phase = 0;
  $readmemh("C:\\users\\PSDI\\PSDI-Lab3\\LM4550_SIM\\src\\data\\sintable.hex", tabsin );
end

always @(posedge clock)
begin
  phase <= phase + phasein;
end

assign tabout = tabsin[ phase[23:14] ];

assign sineout = tabout / attenuation;

endmodule

