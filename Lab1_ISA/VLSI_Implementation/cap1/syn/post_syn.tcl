proc post_syn { a } {
	set filename "area_report"
	append filename $a
	append filename ".txt"
	report_area > $filename
	ungroup -all -flatten
	change_names -hierarchy -rules verilog
	write_sdf ../netlist/IIR_Filter.sdf
	write -f verilog -hierarchy -output ../netlist/IIR_Filter.v
	write_sdc ../netlist/IIR_Filter.sdc
}
