#!/bin/bash

# FPGA-Based Digital RF Frontend - Simple Simulation Script
# This script compiles and runs the simplified Verilog simulation

echo "=========================================="
echo "FPGA-Based Digital RF Frontend - Simple Test"
echo "=========================================="

# Create output directory
mkdir -p sim/output

# Compile all Verilog files with simple testbench
echo "Compiling Verilog files..."
iverilog -o sim/output/simple_rf_frontend_sim \
    rtl/cordic.v \
    rtl/complex_multiplier.v \
    rtl/mac_unit.v \
    rtl/fir_filter.v \
    rtl/decimation.v \
    rtl/ddc_core.v \
    rtl/rf_frontend_top.v \
    sim/simple_testbench.v

if [ $? -eq 0 ]; then
    echo "Compilation successful!"
    
    # Run simulation
    echo "Running simulation..."
    vvp sim/output/simple_rf_frontend_sim
    
    if [ $? -eq 0 ]; then
        echo "Simulation completed successfully!"
    else
        echo "Simulation failed!"
        exit 1
    fi
else
    echo "Compilation failed!"
    exit 1
fi

echo "=========================================="
echo "Simple test complete!"
echo "==========================================" 