vcom -93 -work ./work ../src/MBE_Multiplier/types.vhd
vcom -93 -work ./work ../src/MBE_Multiplier/HA.vhd
vcom -93 -work ./work ../src//MBE_Multiplier/FA.vhd
vcom -93 -work ./work ../src/MBE_Multiplier/A_gen.vhd
vcom -93 -work ./work ../src/MBE_Multiplier/Sign_Ext.vhd
vcom -93 -work ./work ../src/MBE_Multiplier/MBE_recoder.vhd
vcom -93 -work ./work ../src/MBE_Multiplier/Dadda_Tree.vhd
vcom -93 -work ./work ../src/MBE_Multiplier/Dadda_Multiplier.vhd
vlog -sv ../tb/top.sv
vsim top


