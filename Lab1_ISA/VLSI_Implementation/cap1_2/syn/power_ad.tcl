proc power { a } {
	read_verilog -netlist ../netlist/IIR_FILTER_ADVANCED.v
	read_saif -input ../saif/IIR_FILTER_ADVANCED_syn.saif -instance tb_fir/UUT -unit ns -scale 1
	create_clock -name MY_CLK CLK
	set filename "power_report"
	append filename $a
	append filename ".txt"
	report_power > $filename
}
