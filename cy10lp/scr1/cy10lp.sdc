

create_clock  -name CY10_CLK_24M       -period 20  [get_ports {CY10_CLK_24M}]
create_clock  -name JTAG_TCK            -period 200 [get_ports {JTAG_TCK}]
create_clock  -name DRAM_CLK            -period 10



create_generated_clock  -source CY10_CLK_24M \
                        -divide_by 5 \
                        -multiply_by 2 \
                        -duty_cycle 50.00 \
                        -name CLK_RISCV \
                        {i_pll|altpll_component|auto_generated|pll1|clk[0]}

create_generated_clock  -source CY10_CLK_24M \
                        -multiply_by 2 \
                        -duty_cycle 50.00 \
                        -name CLK_SDRAM \
                        {i_pll|altpll_component|auto_generated|pll1|clk[1]}

create_generated_clock  -source CY10_CLK_24M \
                        -multiply_by 2 \
                        -phase 108.00 \
                        -duty_cycle 50.00 \
                        -name CLK_SDRAM_EXT \
                        {i_pll|altpll_component|auto_generated|pll1|clk[2]}



derive_pll_clocks -create_base_clocks
derive_clock_uncertainty



set_clock_groups -asynchronous -group {CY10_CLK_24M}
set_clock_groups -asynchronous -group {JTAG_TCK}
set_clock_groups -asynchronous -group {CLK_RISCV}
set_clock_groups -asynchronous -group {CLK_SDRAM_EXT  DRAM_CLK}





set_input_delay  -add_delay -clock_fall -clock JTAG_TCK -max  5 [get_ports {JTAG_TMS JTAG_TDI}]
set_input_delay  -add_delay -clock_fall -clock JTAG_TCK -min  0 [get_ports {JTAG_TMS JTAG_TDI}]
set_output_delay -add_delay -clock_fall -clock JTAG_TCK -max  5 [get_ports {JTAG_TDO}]
set_output_delay -add_delay -clock_fall -clock JTAG_TCK -min  0 [get_ports {JTAG_TDO}]


set_false_path -to   [get_ports {HEX*}]
set_false_path -to   [get_ports {LEDR*}]
set_false_path -to   [get_ports {UART_RXD}]
set_false_path -from [get_ports {UART_TXD}]
set_false_path -from [get_ports {JTAG_TRST_N}]
set_false_path -from [get_ports {KEY*}]
set_false_path -from [get_ports {SW*}]







#**************************************************************
# Set Input Delay
#**************************************************************
# suppose +- 100 ps skew
# Board Delay (Data) + Propagation Delay - Board Delay (Clock)
# max 5.4(max) +0.4(trace delay) +0.1 = 5.9
# min 2.7(min) +0.4(trace delay) -0.1 = 3.0
set_input_delay -max -clock DRAM_CLK 5.9 [get_ports DRAM_DQ*]
set_input_delay -min -clock DRAM_CLK 3.0 [get_ports DRAM_DQ*]

#shift-window
set_multicycle_path -from [get_clocks {DRAM_CLK}] \
                    -to   [get_clocks {CY10_CLK_24M}] \
                    -setup 2

#**************************************************************
# Set Output Delay
#**************************************************************
# suppose +- 100 ps skew
# max : Board Delay (Data) - Board Delay (Clock) + tsu (External Device)
# min : Board Delay (Data) - Board Delay (Clock) - th (External Device)
# max 1.5+0.1 =1.6
# min -0.8-0.1 = 0.9
set_output_delay -max -clock DRAM_CLK  1.6  [get_ports {DRAM_DQ* DRAM_*DQM}]
set_output_delay -min -clock DRAM_CLK -0.9  [get_ports {DRAM_DQ* DRAM_*DQM}]
set_output_delay -max -clock DRAM_CLK  1.6  [get_ports {DRAM_ADDR* DRAM_BA* DRAM_RAS_N DRAM_CAS_N DRAM_WE_N DRAM_CKE DRAM_CS_N}]
set_output_delay -min -clock DRAM_CLK -0.9  [get_ports {DRAM_ADDR* DRAM_BA* DRAM_RAS_N DRAM_CAS_N DRAM_WE_N DRAM_CKE DRAM_CS_N}]
