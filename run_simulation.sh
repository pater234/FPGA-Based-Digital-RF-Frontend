#!/bin/bash

# FPGA-Based Digital RF Frontend - Simulation Script
# This script compiles and runs the Verilog simulation

echo "=========================================="
echo "FPGA-Based Digital RF Frontend Simulation"
echo "=========================================="

# Create output directory
mkdir -p sim/output

# Compile all Verilog files
echo "Compiling Verilog files..."
iverilog -o sim/output/rf_frontend_sim \
    rtl/cordic.v \
    rtl/complex_multiplier.v \
    rtl/mac_unit.v \
    rtl/fir_filter.v \
    rtl/decimation.v \
    rtl/ddc_core.v \
    rtl/rf_frontend_top.v \
    sim/testbench.v

if [ $? -eq 0 ]; then
    echo "Compilation successful!"
    
    # Run simulation
    echo "Running simulation..."
    vvp sim/output/rf_frontend_sim
    
    if [ $? -eq 0 ]; then
        echo "Simulation completed successfully!"
        echo "Check sim/output/ for waveform files (if generated)"
    else
        echo "Simulation failed!"
        exit 1
    fi
else
    echo "Compilation failed!"
    exit 1
fi

echo "=========================================="
echo "Simulation complete!"
echo "==========================================" 