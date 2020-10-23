onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_fir/CLK_i
add wave -noupdate -format Logic /tb_fir/RST_n_i
add wave -noupdate -format Literal -radix decimal /tb_fir/DIN_i
add wave -noupdate -format Logic /tb_fir/VIN_i
add wave -noupdate -format Literal -radix decimal /tb_fir/A1_i
add wave -noupdate -format Literal -radix decimal /tb_fir/A2_i
add wave -noupdate -format Literal -radix decimal /tb_fir/B0_i
add wave -noupdate -format Literal -radix decimal /tb_fir/B1_i
add wave -noupdate -format Literal -radix decimal /tb_fir/B2_i
add wave -noupdate -format Literal -radix decimal /tb_fir/DOUT_i
add wave -noupdate -format Logic /tb_fir/VOUT_i
add wave -noupdate -format Logic /tb_fir/END_SIM_i
add wave -noupdate -divider -height 28 IIR_Filter
add wave -noupdate -format Logic /tb_fir/UUT/vin
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/din
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/a1
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/a2
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/b0
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/b1
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/b2
add wave -noupdate -format Logic /tb_fir/UUT/vout
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/dout
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/sw
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/fb
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/fb_ext
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/ff
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/ff_ext
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/psum_b
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/psum_f
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/w
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/y_ext
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/y
add wave -noupdate -format Literal -radix decimal /tb_fir/UUT/dout_ext
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {33 ns} 0}
configure wave -namecolwidth 200
configure wave -valuecolwidth 100
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
update
WaveRestoreZoom {0 ns} {995 ns}
