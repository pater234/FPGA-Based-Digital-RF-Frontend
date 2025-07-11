#=============================================================================
# FPGA-Based Digital RF Frontend - Xilinx Constraints File
#=============================================================================
# This file contains pin assignments, timing constraints, and FPGA-specific
# optimizations for the RF frontend system
#
# Author: pater234
# Date: 2025
# Target: Xilinx Series 7, UltraScale, UltraScale+
#=============================================================================

#=============================================================================
# Clock Constraints
#=============================================================================

# System clock (100 MHz)
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]

# ADC clock (250 MHz) - if using separate ADC clock
# create_clock -period 4.000 -name adc_clk -waveform {0.000 2.000} [get_ports adc_clk]

# Virtual clock for input/output timing
create_clock -period 10.000 -name virtual_clk

#=============================================================================
# Pin Assignments
#=============================================================================

# System interface
set_property PACKAGE_PIN Y9 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

set_property PACKAGE_PIN R19 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

# ADC interface (16-bit parallel)
set_property PACKAGE_PIN A10 [get_ports {adc_data[0]}]
set_property PACKAGE_PIN A11 [get_ports {adc_data[1]}]
set_property PACKAGE_PIN A12 [get_ports {adc_data[2]}]
set_property PACKAGE_PIN A13 [get_ports {adc_data[3]}]
set_property PACKAGE_PIN A14 [get_ports {adc_data[4]}]
set_property PACKAGE_PIN A15 [get_ports {adc_data[5]}]
set_property PACKAGE_PIN A16 [get_ports {adc_data[6]}]
set_property PACKAGE_PIN A17 [get_ports {adc_data[7]}]
set_property PACKAGE_PIN A18 [get_ports {adc_data[8]}]
set_property PACKAGE_PIN A19 [get_ports {adc_data[9]}]
set_property PACKAGE_PIN A20 [get_ports {adc_data[10]}]
set_property PACKAGE_PIN A21 [get_ports {adc_data[11]}]
set_property PACKAGE_PIN A22 [get_ports {adc_data[12]}]
set_property PACKAGE_PIN A23 [get_ports {adc_data[13]}]
set_property PACKAGE_PIN A24 [get_ports {adc_data[14]}]
set_property PACKAGE_PIN A25 [get_ports {adc_data[15]}]

set_property PACKAGE_PIN B10 [get_ports adc_valid]
set_property PACKAGE_PIN B11 [get_ports adc_ready]

# Set IOSTANDARD for ADC interface
set_property IOSTANDARD LVCMOS33 [get_ports {adc_data[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports adc_valid]
set_property IOSTANDARD LVCMOS33 [get_ports adc_ready]

# Configuration interface
set_property PACKAGE_PIN C10 [get_ports {nco_freq[0]}]
set_property PACKAGE_PIN C11 [get_ports {nco_freq[1]}]
set_property PACKAGE_PIN C12 [get_ports {nco_freq[2]}]
set_property PACKAGE_PIN C13 [get_ports {nco_freq[3]}]
set_property PACKAGE_PIN C14 [get_ports {nco_freq[4]}]
set_property PACKAGE_PIN C15 [get_ports {nco_freq[5]}]
set_property PACKAGE_PIN C16 [get_ports {nco_freq[6]}]
set_property PACKAGE_PIN C17 [get_ports {nco_freq[7]}]
set_property PACKAGE_PIN C18 [get_ports {nco_freq[8]}]
set_property PACKAGE_PIN C19 [get_ports {nco_freq[9]}]
set_property PACKAGE_PIN C20 [get_ports {nco_freq[10]}]
set_property PACKAGE_PIN C21 [get_ports {nco_freq[11]}]
set_property PACKAGE_PIN C22 [get_ports {nco_freq[12]}]
set_property PACKAGE_PIN C23 [get_ports {nco_freq[13]}]
set_property PACKAGE_PIN C24 [get_ports {nco_freq[14]}]
set_property PACKAGE_PIN C25 [get_ports {nco_freq[15]}]
set_property PACKAGE_PIN D10 [get_ports {nco_freq[16]}]
set_property PACKAGE_PIN D11 [get_ports {nco_freq[17]}]
set_property PACKAGE_PIN D12 [get_ports {nco_freq[18]}]
set_property PACKAGE_PIN D13 [get_ports {nco_freq[19]}]
set_property PACKAGE_PIN D14 [get_ports {nco_freq[20]}]
set_property PACKAGE_PIN D15 [get_ports {nco_freq[21]}]
set_property PACKAGE_PIN D16 [get_ports {nco_freq[22]}]
set_property PACKAGE_PIN D17 [get_ports {nco_freq[23]}]

set_property IOSTANDARD LVCMOS33 [get_ports {nco_freq[*]}]

# Control interface
set_property PACKAGE_PIN E10 [get_ports enable_ddc]
set_property PACKAGE_PIN E11 [get_ports enable_fir]
set_property PACKAGE_PIN E12 [get_ports enable_decimation]
set_property PACKAGE_PIN E13 [get_ports bypass_cic]
set_property PACKAGE_PIN E14 [get_ports bypass_fir]

set_property IOSTANDARD LVCMOS33 [get_ports enable_ddc]
set_property IOSTANDARD LVCMOS33 [get_ports enable_fir]
set_property IOSTANDARD LVCMOS33 [get_ports enable_decimation]
set_property IOSTANDARD LVCMOS33 [get_ports bypass_cic]
set_property IOSTANDARD LVCMOS33 [get_ports bypass_fir]

# Output interface (I/Q data)
set_property PACKAGE_PIN F10 [get_ports {i_data_out[0]}]
set_property PACKAGE_PIN F11 [get_ports {i_data_out[1]}]
set_property PACKAGE_PIN F12 [get_ports {i_data_out[2]}]
set_property PACKAGE_PIN F13 [get_ports {i_data_out[3]}]
set_property PACKAGE_PIN F14 [get_ports {i_data_out[4]}]
set_property PACKAGE_PIN F15 [get_ports {i_data_out[5]}]
set_property PACKAGE_PIN F16 [get_ports {i_data_out[6]}]
set_property PACKAGE_PIN F17 [get_ports {i_data_out[7]}]
set_property PACKAGE_PIN F18 [get_ports {i_data_out[8]}]
set_property PACKAGE_PIN F19 [get_ports {i_data_out[9]}]
set_property PACKAGE_PIN F20 [get_ports {i_data_out[10]}]
set_property PACKAGE_PIN F21 [get_ports {i_data_out[11]}]
set_property PACKAGE_PIN F22 [get_ports {i_data_out[12]}]
set_property PACKAGE_PIN F23 [get_ports {i_data_out[13]}]
set_property PACKAGE_PIN F24 [get_ports {i_data_out[14]}]
set_property PACKAGE_PIN F25 [get_ports {i_data_out[15]}]
set_property PACKAGE_PIN G10 [get_ports {i_data_out[16]}]
set_property PACKAGE_PIN G11 [get_ports {i_data_out[17]}]

set_property PACKAGE_PIN G12 [get_ports {q_data_out[0]}]
set_property PACKAGE_PIN G13 [get_ports {q_data_out[1]}]
set_property PACKAGE_PIN G14 [get_ports {q_data_out[2]}]
set_property PACKAGE_PIN G15 [get_ports {q_data_out[3]}]
set_property PACKAGE_PIN G16 [get_ports {q_data_out[4]}]
set_property PACKAGE_PIN G17 [get_ports {q_data_out[5]}]
set_property PACKAGE_PIN G18 [get_ports {q_data_out[6]}]
set_property PACKAGE_PIN G19 [get_ports {q_data_out[7]}]
set_property PACKAGE_PIN G20 [get_ports {q_data_out[8]}]
set_property PACKAGE_PIN G21 [get_ports {q_data_out[9]}]
set_property PACKAGE_PIN G22 [get_ports {q_data_out[10]}]
set_property PACKAGE_PIN G23 [get_ports {q_data_out[11]}]
set_property PACKAGE_PIN G24 [get_ports {q_data_out[12]}]
set_property PACKAGE_PIN G25 [get_ports {q_data_out[13]}]
set_property PACKAGE_PIN H10 [get_ports {q_data_out[14]}]
set_property PACKAGE_PIN H11 [get_ports {q_data_out[15]}]
set_property PACKAGE_PIN H12 [get_ports {q_data_out[16]}]
set_property PACKAGE_PIN H13 [get_ports {q_data_out[17]}]

set_property IOSTANDARD LVCMOS33 [get_ports {i_data_out[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {q_data_out[*]}]

# Output control signals
set_property PACKAGE_PIN H14 [get_ports out_valid]
set_property PACKAGE_PIN H15 [get_ports out_ready]
set_property PACKAGE_PIN H16 [get_ports ddc_locked]

set_property IOSTANDARD LVCMOS33 [get_ports out_valid]
set_property IOSTANDARD LVCMOS33 [get_ports out_ready]
set_property IOSTANDARD LVCMOS33 [get_ports ddc_locked]

# Status interface
set_property PACKAGE_PIN H17 [get_ports {ddc_status[0]}]
set_property PACKAGE_PIN H18 [get_ports {ddc_status[1]}]
set_property PACKAGE_PIN H19 [get_ports {ddc_status[2]}]
set_property PACKAGE_PIN H20 [get_ports {ddc_status[3]}]
set_property PACKAGE_PIN H21 [get_ports {ddc_status[4]}]
set_property PACKAGE_PIN H22 [get_ports {ddc_status[5]}]
set_property PACKAGE_PIN H23 [get_ports {ddc_status[6]}]
set_property PACKAGE_PIN H24 [get_ports {ddc_status[7]}]
set_property PACKAGE_PIN H25 [get_ports {ddc_status[8]}]
set_property PACKAGE_PIN J10 [get_ports {ddc_status[9]}]
set_property PACKAGE_PIN J11 [get_ports {ddc_status[10]}]
set_property PACKAGE_PIN J12 [get_ports {ddc_status[11]}]
set_property PACKAGE_PIN J13 [get_ports {ddc_status[12]}]
set_property PACKAGE_PIN J14 [get_ports {ddc_status[13]}]
set_property PACKAGE_PIN J15 [get_ports {ddc_status[14]}]
set_property PACKAGE_PIN J16 [get_ports {ddc_status[15]}]

set_property IOSTANDARD LVCMOS33 [get_ports {ddc_status[*]}]

#=============================================================================
# Timing Constraints
#=============================================================================

# Input timing constraints
set_input_delay -clock clk -max 2.000 [get_ports {adc_data[*]}]
set_input_delay -clock clk -min 0.500 [get_ports {adc_data[*]}]

set_input_delay -clock clk -max 1.000 [get_ports adc_valid]
set_input_delay -clock clk -min 0.200 [get_ports adc_valid]

# Output timing constraints
set_output_delay -clock clk -max 3.000 [get_ports {i_data_out[*]}]
set_output_delay -clock clk -min 0.500 [get_ports {i_data_out[*]}]

set_output_delay -clock clk -max 3.000 [get_ports {q_data_out[*]}]
set_output_delay -clock clk -min 0.500 [get_ports {q_data_out[*]}]

set_output_delay -clock clk -max 2.000 [get_ports out_valid]
set_output_delay -clock clk -min 0.200 [get_ports out_valid]

# False paths
set_false_path -from [get_ports {nco_freq[*]}]
set_false_path -from [get_ports enable_ddc]
set_false_path -from [get_ports enable_fir]
set_false_path -from [get_ports enable_decimation]
set_false_path -from [get_ports bypass_cic]
set_false_path -from [get_ports bypass_fir]

#=============================================================================
# FPGA-Specific Optimizations
#=============================================================================

# DSP48E1/E2 optimization attributes
set_property USE_DSP YES [get_cells -hierarchical -filter {PRIMITIVE_TYPE == dsp}]

# Block RAM optimization
set_property RAM_STYLE BLOCK [get_cells -hierarchical -filter {PRIMITIVE_TYPE == ram}]

# Clock buffer optimization
set_property CLOCK_BUFFER_TYPE BUFG [get_nets clk]

#=============================================================================
# Power Optimization
#=============================================================================

# Enable power optimization
set_property POWER_OPTIMIZATION TRUE [current_design]

# Set power constraints
set_operating_conditions -grade extended -junction_temp 85

#=============================================================================
# Area Optimization
#=============================================================================

# Enable area optimization
set_property AREA_OPTIMIZATION TRUE [current_design]

#=============================================================================
# Implementation Constraints
#=============================================================================

# Set implementation strategy
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.ROUTE_DESIGN.TCL.PRE {} [get_runs impl_1]

# Performance constraints
set_property STEPS.PLACE_DESIGN.TCL.PRE {} [get_runs impl_1]
set_property STEPS.ROUTE_DESIGN.TCL.PRE {} [get_runs impl_1]

#=============================================================================
# Debug and Monitoring
#=============================================================================

# Enable debug cores (if using ILA)
# set_property MARK_DEBUG true [get_nets -hierarchical -filter {NAME =~ "*ddc*"}]

#=============================================================================
# Additional Constraints for Specific Devices
#=============================================================================

# For UltraScale devices, add specific constraints
# set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
# set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

# For Series 7 devices, add specific constraints
# set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
# set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

#=============================================================================
# End of Constraints File
#============================================================================= 