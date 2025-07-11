# FPGA-Based Digital RF Frontend

## Overview
This project implements a complete Digital RF Frontend on Xilinx FPGAs, featuring:
- **Digital Downconversion (DDC)** with NCO (Numerically Controlled Oscillator)
- **FIR Filtering** with configurable coefficients
- **Decimation Chain** for sample rate reduction
- **CORDIC** for phase rotation
- **MAC Units** for efficient DSP operations

## Architecture
The system processes high-frequency RF signals by:
1. **ADC Interface**: Receives digitized RF samples
2. **DDC**: Downconverts to baseband using NCO and CORDIC
3. **FIR Filter**: Applies anti-aliasing and channel filtering
4. **Decimation**: Reduces sample rate while maintaining signal quality
5. **Output Interface**: Provides processed baseband data

## Key Components

### 1. NCO (Numerically Controlled Oscillator)
- Phase accumulator with configurable frequency
- Sine/cosine lookup table (LUT) or CORDIC implementation
- Configurable frequency resolution and spurious performance

### 2. DDC Core
- Complex multiplication with NCO output
- I/Q signal separation
- Configurable center frequency

### 3. FIR Filter
- Symmetric or asymmetric filter coefficients
- Configurable number of taps
- Efficient MAC-based implementation
- Support for different filter types (low-pass, band-pass, etc.)

### 4. Decimation Chain
- Cascaded integrator-comb (CIC) filters
- Polyphase FIR filters
- Configurable decimation ratios

## Xilinx Implementation Details

### Target Devices
- **Series 7**: Artix-7, Kintex-7, Virtex-7
- **UltraScale**: Kintex UltraScale, Virtex UltraScale
- **UltraScale+**: Kintex UltraScale+, Virtex UltraScale+

### IP Cores Used
- **DDS Compiler**: For NCO implementation
- **FIR Compiler**: For efficient FIR filtering
- **CIC Compiler**: For decimation/interpolation
- **CORDIC**: For trigonometric functions
- **DSP48E1/DSP48E2**: For MAC operations

### Clock Domains
- **ADC Clock**: High-speed sampling (typically 100-500 MHz)
- **Processing Clock**: DDC and filtering operations
- **Output Clock**: Reduced rate for baseband data

## File Structure
```
├── rtl/                    # RTL source files
│   ├── ddc_core.v         # Main DDC module
│   ├── nco.v              # NCO implementation
│   ├── cordic.v           # CORDIC algorithm
│   ├── fir_filter.v       # FIR filter core
│   ├── decimation.v       # Decimation chain
│   └── mac_unit.v         # MAC unit for DSP
├── sim/                   # Simulation files
│   ├── testbench.v        # Main testbench
│   └── test_vectors/      # Test data
├── constraints/           # Xilinx constraints
│   └── top.xdc           # Pin assignments and timing
├── ip/                    # IP core configurations
│   ├── dds_compiler.xci  # DDS IP core
│   ├── fir_compiler.xci  # FIR IP core
│   └── cic_compiler.xci  # CIC IP core
├── matlab/               # MATLAB scripts for design
│   ├── filter_design.m   # FIR filter coefficient generation
│   ├── ddc_simulation.m  # DDC simulation and verification
│   └── test_data_gen.m   # Test data generation
└── docs/                 # Documentation
    ├── design_spec.md    # Detailed design specification
    └── user_guide.md     # User guide for operation
```

## Design Parameters

### DDC Parameters
- **Input Sample Rate**: 100-500 MHz
- **NCO Frequency Resolution**: 24-32 bits
- **Output Sample Rate**: 1-50 MHz
- **Spurious Free Dynamic Range**: >80 dBc

### FIR Filter Parameters
- **Number of Taps**: 64-512 (configurable)
- **Coefficient Width**: 16-24 bits
- **Data Width**: 16-24 bits
- **Filter Types**: Low-pass, Band-pass, Hilbert

### Decimation Parameters
- **Decimation Ratio**: 2-256 (configurable)
- **CIC Stages**: 3-5 stages
- **Compensation Filter**: Post-CIC compensation

## Performance Specifications
- **Dynamic Range**: >100 dB
- **SFDR**: >80 dBc
- **Noise Figure**: <10 dB
- **Power Consumption**: <5W (typical)
- **Latency**: <100 μs

## Usage
1. **Design Entry**: Use provided RTL modules or IP cores
2. **Simulation**: Run testbench with MATLAB-generated test vectors
3. **Synthesis**: Target specific Xilinx device
4. **Implementation**: Place and route with timing constraints
5. **Verification**: Hardware testing with RF test equipment

## Dependencies
- **Xilinx Vivado**: 2021.2 or later
- **MATLAB**: R2021a or later (for filter design)
- **ModelSim/QuestaSim**: For RTL simulation
- **RF Test Equipment**: For hardware verification

## License
MIT License - See LICENSE file for details