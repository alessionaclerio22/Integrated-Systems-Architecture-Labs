vcom -93 -work ./work ../src/constants.vhd
vlog -work ./work ../netlist/IIR_Filter.v
vcom -93 -work ./work ../tb/clk_gen.vhd
vcom -93 -work ./work ../tb/data_maker_new.vhd
vcom -93 -work ./work ../tb/data_sink.vhd
vlog -work ./work ../tb/tb_fir.v
vsim -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /tb_fir/UUT=../netlist/IIR_Filter.sdf work.tb_fir


