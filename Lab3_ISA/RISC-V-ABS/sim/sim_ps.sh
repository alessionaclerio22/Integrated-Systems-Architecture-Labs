vcom -93 -work ./work ../src/my_package.vhd
vcom -93 -work ./work ../tb/IRAM.vhd
vcom -93 -work ./work ../tb/DRAM.vhd
vlog -work ./work ../netlist/RISC_V.v
vcom -93 -work ./work ../tb/tb_RISC_V.vhd
vsim -L /software/dk/nangate45/verilog/msim6.2g work.tb_RISC_V

