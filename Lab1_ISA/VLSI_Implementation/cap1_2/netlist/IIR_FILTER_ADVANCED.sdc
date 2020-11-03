###################################################################

# Created by write_sdc on Tue Nov  3 12:39:28 2020

###################################################################
set sdc_version 2.1

set_units -time ns -resistance MOhm -capacitance fF -voltage V -current mA
set_load -pin_load 3.40189 [get_ports VOUT]
set_load -pin_load 3.40189 [get_ports {DOUT[8]}]
set_load -pin_load 3.40189 [get_ports {DOUT[7]}]
set_load -pin_load 3.40189 [get_ports {DOUT[6]}]
set_load -pin_load 3.40189 [get_ports {DOUT[5]}]
set_load -pin_load 3.40189 [get_ports {DOUT[4]}]
set_load -pin_load 3.40189 [get_ports {DOUT[3]}]
set_load -pin_load 3.40189 [get_ports {DOUT[2]}]
set_load -pin_load 3.40189 [get_ports {DOUT[1]}]
set_load -pin_load 3.40189 [get_ports {DOUT[0]}]
create_clock [get_ports CLK]  -name MY_CLK  -period 8.84  -waveform {0 4.42}
set_clock_uncertainty 0.07  [get_clocks MY_CLK]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports RST_n]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports VIN]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {DIN[8]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {DIN[7]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {DIN[6]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {DIN[5]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {DIN[4]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {DIN[3]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {DIN[2]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {DIN[1]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {DIN[0]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A1[8]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A1[7]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A1[6]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A1[5]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A1[4]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A1[3]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A1[2]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A1[1]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A1[0]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A2[8]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A2[7]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A2[6]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A2[5]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A2[4]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A2[3]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A2[2]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A2[1]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {A2[0]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B0[8]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B0[7]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B0[6]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B0[5]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B0[4]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B0[3]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B0[2]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B0[1]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B0[0]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B1[8]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B1[7]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B1[6]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B1[5]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B1[4]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B1[3]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B1[2]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B1[1]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B1[0]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B2[8]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B2[7]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B2[6]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B2[5]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B2[4]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B2[3]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B2[2]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B2[1]}]
set_input_delay -clock MY_CLK  -max 0.5  [get_ports {B2[0]}]
set_output_delay -clock MY_CLK  -max 0.5  [get_ports VOUT]
set_output_delay -clock MY_CLK  -max 0.5  [get_ports {DOUT[8]}]
set_output_delay -clock MY_CLK  -max 0.5  [get_ports {DOUT[7]}]
set_output_delay -clock MY_CLK  -max 0.5  [get_ports {DOUT[6]}]
set_output_delay -clock MY_CLK  -max 0.5  [get_ports {DOUT[5]}]
set_output_delay -clock MY_CLK  -max 0.5  [get_ports {DOUT[4]}]
set_output_delay -clock MY_CLK  -max 0.5  [get_ports {DOUT[3]}]
set_output_delay -clock MY_CLK  -max 0.5  [get_ports {DOUT[2]}]
set_output_delay -clock MY_CLK  -max 0.5  [get_ports {DOUT[1]}]
set_output_delay -clock MY_CLK  -max 0.5  [get_ports {DOUT[0]}]
