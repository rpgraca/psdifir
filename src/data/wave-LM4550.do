onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Master clock and reset}
add wave -noupdate -format Logic -label {Clock in (24.576MHz)} /LM4550_sim_tb/XTAL_IN
add wave -noupdate -format Logic -label RESET_N /LM4550_sim_tb/RESET_N
add wave -noupdate -divider {AC LINK interface}
add wave -noupdate -format Logic -label SYNC /LM4550_sim_tb/SYNC
add wave -noupdate -format Logic -label SDATA_OUT /LM4550_sim_tb/SDATA_OUT
add wave -noupdate -format Logic -label BIT_CLK /LM4550_sim_tb/BIT_CLK
add wave -noupdate -format Logic -label SDATA_IN /LM4550_sim_tb/SDATA_IN
add wave -noupdate -divider {Analog inputs}
add wave -noupdate -color {Light Blue} -format Analog-Step -height 74 -itemcolor {Light Blue} -label {Microphone in (-0.1V..+0.1V)} -max 0.10000000000000001 -min -0.10000000000000001 -radix decimal /LM4550_sim_tb/MIC
add wave -noupdate -color Salmon -format Analog-Step -height 88 -itemcolor Salmon -label {Line in left (-0.5V..+0.5V)} -max 0.5 -min -0.5 -radix decimal /LM4550_sim_tb/LINE_IN_L
add wave -noupdate -color {Spring Green} -format Analog-Step -height 74 -itemcolor {Spring Green} -label {Line in right (-0.5V..+0.5V)} -max 0.5 -min -0.5 -radix decimal /LM4550_sim_tb/LINE_IN_R
add wave -noupdate -divider {Analog outputs}
add wave -noupdate -color Salmon -format Analog-Step -height 50 -itemcolor Salmon -label {Phones left (-2.5V..+2.5V)} -max 2.5 -min -2.5 /LM4550_sim_tb/HP_OUT_L
add wave -noupdate -color {Spring Green} -format Analog-Step -height 50 -itemcolor {Spring Green} -label {Phones right (-2.5V..+2.5V)} -max 2.5 -min -2.5 /LM4550_sim_tb/HP_OUT_R
add wave -noupdate -color Salmon -format Analog-Step -height 50 -itemcolor Salmon -label {Line out left (-2.5V..+2.5V)} -max 2.5 -min -2.5 /LM4550_sim_tb/LINE_OUT_L
add wave -noupdate -color {Spring Green} -format Analog-Step -height 50 -itemcolor {Spring Green} -label {Line out right (-2.5V..+2.5V)} -max 2.5 -min -2.5 /LM4550_sim_tb/LINE_OUT_R
add wave -noupdate -divider {Internal analog signals}
add wave -noupdate -color Pink -format Analog-Step -height 50 -label {Mic mux input} -max 2.5 -min -2.5 /LM4550_sim_tb/LM4550_sim_1/MIC_MUX
add wave -noupdate -color Pink -format Analog-Step -height 50 -label {MIC mix 1 input} -max 2.5 -min -2.5 /LM4550_sim_tb/LM4550_sim_1/MIC_MIX1
add wave -noupdate -color Salmon -format Analog-Step -height 40 -label {Line in left mix 1} -max 2.5 -min -2.5 /LM4550_sim_tb/LM4550_sim_1/LINE_LEFT_MIX1
add wave -noupdate -color {Spring Green} -format Analog-Step -height 40 -itemcolor {Spring Green} -label {Line in right mix 1} -max 2.5 -min -2.5 /LM4550_sim_tb/LM4550_sim_1/LINE_RIGHT_MIX1
add wave -noupdate -color Salmon -format Analog-Step -height 40 -label {MIX 1 output left} -max 2.5 -min -2.5 /LM4550_sim_tb/LM4550_sim_1/MIX1_LEFT
add wave -noupdate -color {Spring Green} -format Analog-Step -height 40 -itemcolor {Spring Green} -label {MIX 1 output right} -max 2.5 -min -2.5 /LM4550_sim_tb/LM4550_sim_1/MIX1_RIGHT
add wave -noupdate -format Analog-Step -height 40 -label {MIX 1 mono mux input} -max 2.5 -min -2.5 /LM4550_sim_tb/LM4550_sim_1/MIX1_MONO
add wave -noupdate -color Salmon -format Analog-Step -height 40 -label {Rec mux output left} -max 2.5 -min -2.5 /LM4550_sim_tb/LM4550_sim_1/REC_MUX_L
add wave -noupdate -color {Spring Green} -format Analog-Step -height 40 -itemcolor {Spring Green} -label {Rec mux output right} -max 2.5 -min -2.5 /LM4550_sim_tb/LM4550_sim_1/REC_MUX_R
add wave -noupdate -divider {ADC path}
add wave -noupdate -color Salmon -format Analog-Step -height 40 -label {ADC input left} -max 2.5 -min -2.5 /LM4550_sim_tb/LM4550_sim_1/ADC_IN_L
add wave -noupdate -color {Spring Green} -format Analog-Step -height 40 -itemcolor {Spring Green} -label {ADC input right} -max 2.5 -min -2.5 /LM4550_sim_tb/LM4550_sim_1/ADC_IN_R
add wave -noupdate -color Salmon -format Analog-Step -height 40 -label {ADC left (digital)} -max 131072.0 -min -131072.0 /LM4550_sim_tb/LM4550_sim_1/ADC_LEFT
add wave -noupdate -color {Spring Green} -format Analog-Step -height 40 -itemcolor {Spring Green} -label {ADC right (digital)} -max 131072.0 -min -131072.0 /LM4550_sim_tb/LM4550_sim_1/ADC_RIGHT
add wave -noupdate -divider {DAC path}
add wave -noupdate -color Salmon -format Analog-Step -height 40 -label {DAC input left (digital)} -max 131072.0 -min -131072.0 /LM4550_sim_tb/LM4550_sim_1/DAC_LEFT_I
add wave -noupdate -color {Spring Green} -format Analog-Step -height 40 -itemcolor {Spring Green} -label {DAC input right (digital)} -max 131072.0 -min -131072.0 /LM4550_sim_tb/LM4550_sim_1/DAC_RIGHT_I
add wave -noupdate -color Salmon -format Analog-Step -height 40 -label {DAC output left} -max 2.5 -min -2.5 -radix decimal /LM4550_sim_tb/LM4550_sim_1/DAC_LEFT
add wave -noupdate -color {Spring Green} -format Analog-Step -height 40 -itemcolor {Spring Green} -label {DAC output right} -max 2.5 -min -2.5 /LM4550_sim_tb/LM4550_sim_1/DAC_RIGHT
add wave -noupdate -color Salmon -format Analog-Step -height 40 -label {DAC left MIX1} -max 2.5 -min -2.5 /LM4550_sim_tb/LM4550_sim_1/DAC_LEFT_MIX1
add wave -noupdate -color {Spring Green} -format Analog-Step -height 40 -itemcolor {Spring Green} -label {DAC right MIX1} -max 2.5 -min -2.5 /LM4550_sim_tb/LM4550_sim_1/DAC_RIGHT_MIX1
add wave -noupdate -divider {LM4550 registers}
add wave -noupdate -color Yellow -format Literal -itemcolor Yellow -label {(00) RESET} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[0]}
add wave -noupdate -color {Light Blue} -format Literal -itemcolor {Light Blue} -label {(02) Master Volume} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[2]}
add wave -noupdate -color Yellow -format Literal -itemcolor Yellow -label {(04) Headphone Volume} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[4]}
add wave -noupdate -color {Light Blue} -format Literal -itemcolor {Light Blue} -label {(06) Mono volume (X)} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[6]}
add wave -noupdate -color Yellow -format Literal -itemcolor Yellow -label {(0A) PC beep volume (X)} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[10]}
add wave -noupdate -color {Light Blue} -format Literal -itemcolor {Light Blue} -label {(0C) Phone volume (X)} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[12]}
add wave -noupdate -color Yellow -format Literal -itemcolor Yellow -label {(0E) Mic Volume} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[14]}
add wave -noupdate -color {Light Blue} -format Literal -itemcolor {Light Blue} -label {(10) Line in volume} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[16]}
add wave -noupdate -color Yellow -format Literal -itemcolor Yellow -label {(12) CD volume (X)} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[18]}
add wave -noupdate -color {Light Blue} -format Literal -itemcolor {Light Blue} -label {(14) Video volume (X)} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[20]}
add wave -noupdate -color Yellow -format Literal -itemcolor Yellow -label {(16) Aux volume (X)} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[22]}
add wave -noupdate -color {Light Blue} -format Literal -itemcolor {Light Blue} -label {(18) PCM volume (DAC)} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[24]}
add wave -noupdate -color Yellow -format Literal -itemcolor Yellow -label {(1A) Record select} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[26]}
add wave -noupdate -color {Light Blue} -format Literal -itemcolor {Light Blue} -label {(1C) Record gain} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[28]}
add wave -noupdate -color Yellow -format Literal -itemcolor Yellow -label {(20) General purpose (X)} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[32]}
add wave -noupdate -color {Light Blue} -format Literal -itemcolor {Light Blue} -label {(22) 3D control (X)} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[34]}
add wave -noupdate -color Yellow -format Literal -itemcolor Yellow -label {(26) Powerdown/Status} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[38]}
add wave -noupdate -color {Light Blue} -format Literal -itemcolor {Light Blue} -label {(2A) Ext audio ctrl/stat} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[42]}
add wave -noupdate -color Yellow -format Literal -itemcolor Yellow -label {(2C) PCM DAC rate} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[44]}
add wave -noupdate -color {Light Blue} -format Literal -itemcolor {Light Blue} -label {(32) PCM ADC rate} -radix hexadecimal {/LM4550_sim_tb/LM4550_sim_1/REGS[50]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 5} {646940445 ps} 0} {{Cursor 6} {12189302875 ps} 0}
configure wave -namecolwidth 192
configure wave -valuecolwidth 185
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {25312163063 ps}
