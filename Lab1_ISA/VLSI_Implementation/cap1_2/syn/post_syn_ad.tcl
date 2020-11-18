proc post_syn { a } {
	set filename "area_report"
	append filename $a
	append filename ".txt"
	report_area > $filename
	ungroup -all -flatten
	change_names -hierarchy -rules verilog
	write_sdf ../netlist/IIR_FILTER_ADVANCED.sdf
	write -f verilog -hierarchy -output ../netlist/IIR_FILTER_ADVANCED.v
	write_sdc ../netlist/IIR_FILTER_ADVANCED.sdc
}
