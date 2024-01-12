create_clock -period 7.500 -name clk [get_ports clk]
set_input_delay -clock "clk" 5.0 [all_inputs]
set_output_delay -clock "clk" 5.0 [all_outputs]


