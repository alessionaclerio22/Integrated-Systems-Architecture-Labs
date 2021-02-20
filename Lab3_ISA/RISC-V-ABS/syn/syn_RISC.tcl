analyze -f vhdl -lib WORK ../src/my_package.vhd
analyze -f vhdl -lib WORK ../src/MUX21.vhd
analyze -f vhdl -lib WORK ../src/MUX31.vhd
analyze -f vhdl -lib WORK ../src/MUX41.vhd
analyze -f vhdl -lib WORK ../src/Absolute_Value.vhd
analyze -f vhdl -lib WORK ../src/Shifter.vhd
analyze -f vhdl -lib WORK ../src/Register.vhd
analyze -f vhdl -lib WORK ../src/Register_File.vhd
analyze -f vhdl -lib WORK ../src/PC_Selector_Contol_Unit.vhd
analyze -f vhdl -lib WORK ../src/ALU.vhd
analyze -f vhdl -lib WORK ../src/Instruction_Encoder.vhd
analyze -f vhdl -lib WORK ../src/Immediate_Generation.vhd
analyze -f vhdl -lib WORK ../src/Hazard_Unit.vhd
analyze -f vhdl -lib WORK ../src/Forwarding_Unit.vhd
analyze -f vhdl -lib WORK ../src/Fetch_Stage.vhd
analyze -f vhdl -lib WORK ../src/Execute_Stage.vhd
analyze -f vhdl -lib WORK ../src/Execute_Mux_Sel_Encoder.vhd
analyze -f vhdl -lib WORK ../src/Decode_Stage.vhd
analyze -f vhdl -lib WORK ../src/Control_Unit.vhd
analyze -f vhdl -lib WORK ../src/Branch_Target_Buffer.vhd
analyze -f vhdl -lib WORK ../src/Branch_Forwarding_Unit.vhd
analyze -f vhdl -lib WORK ../src/Branch_Control_Unit.vhd
analyze -f vhdl -lib WORK ../src/RISC-V.vhd
set power_preserve_rtl_hier_names true
elaborate RISC_V -arch struct -lib WORK
create_clock -name MY_CLK -period 1.80  CLK
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] CLK]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]
compile_ultra
