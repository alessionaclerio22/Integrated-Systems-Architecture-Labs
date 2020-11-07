vcom -93 -work ./work ../src/constants.vhd
vcom -93 -work ./work ../src/IIR_Filter.vhd
vcom -93 -work ./work ../tb/clk_gen.vhd
vcom -93 -work ./work ../tb/data_maker_new.vhd
vcom -93 -work ./work ../tb/data_sink.vhd
vlog -work ./work ../tb/tb_fir.v
vsim work.tb_fir


