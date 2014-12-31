// Testbench tasks for simulation:
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


// Program a register: 
// waits for SYNC and change the tag and slot1/slot2
task ProgramRegister( input [7:0] regaddr, input [15:0] data );
begin
  @(posedge SYNC);
  tagout_w[14:13] = 2'b11;
  tagout_w[15] = 1'b1;
  Slot1_out = { 1'b0, regaddr, 12'd0};
  Slot2_out = { data, 4'd0};
//  @(negedge SYNC);
//  tagout_w[14:13] = 2'b00;  
end
endtask


task clear_out_slots;
begin
  Slot1_out = 0;
  Slot2_out = 0;
  Slot3_out = 0;
  Slot4_out = 0;
  Slot5_out = 0;
  Slot6_out = 0;
  Slot7_out = 0;
  Slot8_out = 0;
  Slot9_out = 0;
  Slot10_out = 0;
  Slot11_out = 0;
  Slot12_out = 0;
end
endtask
