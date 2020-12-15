analyze -f vhdl -lib WORK ../../src/fpnormalize_fpnormalize.vhd
analyze -f vhdl -lib WORK ../../src/fpround_fpround.vhd
analyze -f vhdl -lib WORK ../../src/packfp_packfp.vhd
analyze -f vhdl -lib WORK ../../src/unpackfp_unpackfp.vhd
analyze -f vhdl -lib WORK ../../src/fpmul_stage1_struct.vhd
analyze -f vhdl -lib WORK ../../src/fpmul_stage2_struct.vhd
analyze -f vhdl -lib WORK ../../src/fpmul_stage3_struct.vhd
analyze -f vhdl -lib WORK ../../src/fpmul_stage4_struct.vhd
analyze -f vhdl -lib WORK ../../src/fpmul_single_cycle.vhd
analyze -f vhdl -lib WORK ../../src/fpmul_pipeline.vhd
set power_preserve_rtl_hier_names true
elaborate FPmul -arch pipeline -lib WORK
create_clock -name MY_CLK -period 4.28 clk
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] clk]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]
ungroup -all -flatten
set_implementation DW02_mult/csa [find cell *mult*]
compile

