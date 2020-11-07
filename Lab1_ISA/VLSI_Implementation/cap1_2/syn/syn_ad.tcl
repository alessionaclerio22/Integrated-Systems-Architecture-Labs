analyze -f vhdl -lib WORK ../src/constants.vhd
analyze -f vhdl -lib WORK ../src/IIR_FILTER_ADVANCED.vhd
set power_preserve_rtl_hier_names true
elaborate IIR_FILTER_ADVANCED -arch structural -lib WORK
create_clock -name MY_CLK -period 8.84  CLK  
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] CLK]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]
compile
