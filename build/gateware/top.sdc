create_clock -name clk50 -period 20.0 [get_ports {clk50}]
derive_pll_clocks -use_net_name