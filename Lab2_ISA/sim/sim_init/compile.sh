vcom -93 -work ./work ../../src/fpnormalize_fpnormalize.vhd
vcom -93 -work ./work ../../src/fpround_fpround.vhd
vcom -93 -work ./work ../../src/packfp_packfp.vhd
vcom -93 -work ./work ../../src/unpackfp_unpackfp.vhd
vcom -93 -work ./work ../../src/fpmul_stage1_struct.vhd
vcom -93 -work ./work ../../src/fpmul_stage2_struct.vhd
vcom -93 -work ./work ../../src/fpmul_stage3_struct.vhd
vcom -93 -work ./work ../../src/fpmul_stage4_struct.vhd
vcom -93 -work ./work ../../src/fpmul_single_cycle.vhd
vcom -93 -work ./work ../../src/fpmul_pipeline_first.vhd
vcom -93 -work ./work ../../tb/clk_gen.vhd
vcom -93 -work ./work ../../tb/data_maker.vhd
vcom -93 -work ./work ../../tb/data_sink.vhd
vlog -work ./work ../../tb/tb_fpmul.v



