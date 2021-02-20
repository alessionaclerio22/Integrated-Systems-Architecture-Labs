report_timing > timing_report_RISC_V_ABSV.txt
report_area > area_report_RISC_V_ABSV.txt
ungroup -all -flatten
change_names -hierarchy -rules  verilog
write_sdf ../netlist/RISC_V.sdf
write -f verilog -hierarchy -output ../netlist/RISC_V.v
write_sdc ../netlist//RISC_V.sdc
