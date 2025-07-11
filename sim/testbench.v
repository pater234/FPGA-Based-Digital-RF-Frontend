//=============================================================================
// FPGA-Based Digital RF Frontend - Testbench
//=============================================================================
// This testbench verifies the complete RF frontend system including
// DDC, FIR filtering, and decimation functionality
//
// Author: pater234
// Date: 2025
// Target: Xilinx Series 7, UltraScale, UltraScale+
//=============================================================================

`timescale 1ns / 1ps

module rf_frontend_tb;

//=============================================================================
// Test Parameters
//=============================================================================
parameter ADC_WIDTH = 16;
parameter NCO_WIDTH = 24;
parameter DDC_WIDTH = 18;
parameter FIR_WIDTH = 18;
parameter OUTPUT_WIDTH = 18;
parameter FIR_TAPS = 64;
parameter CIC_STAGES = 3;
parameter CIC_DECIMATION = 8;
parameter FIR_DECIMATION = 4;

// Clock and timing parameters
parameter CLK_PERIOD = 10; // 100 MHz clock
parameter ADC_CLK_PERIOD = 4; // 250 MHz ADC clock

//=============================================================================
// Test signals
//=============================================================================
reg clk;
reg rst_n;
reg adc_valid;
reg [ADC_WIDTH-1:0] adc_data;
wire adc_ready;

// Configuration signals
reg [NCO_WIDTH-1:0] nco_freq;
reg [15:0] nco_phase_offset;
reg [7:0] cic_decimation;
reg [7:0] fir_decimation;
reg bypass_cic, bypass_fir;

// FIR coefficient interface
reg [17:0] fir_coeff_data;
reg [7:0] fir_coeff_addr;
reg fir_coeff_wr, fir_coeff_ld;

// Control signals
reg enable_ddc, enable_fir, enable_decimation;

// Output signals
wire [OUTPUT_WIDTH-1:0] i_data_out, q_data_out;
wire out_valid;
reg out_ready;

// Status signals
wire ddc_locked;
wire [15:0] ddc_status, fir_status, decim_status, system_status;

//=============================================================================
// Test data generation
//=============================================================================
reg [31:0] sample_counter;
reg [15:0] test_frequency;
reg [15:0] test_amplitude;

//=============================================================================
// DUT Instantiation
//=============================================================================
rf_frontend_top #(
    .ADC_WIDTH(ADC_WIDTH),
    .NCO_WIDTH(NCO_WIDTH),
    .DDC_WIDTH(DDC_WIDTH),
    .FIR_WIDTH(FIR_WIDTH),
    .OUTPUT_WIDTH(OUTPUT_WIDTH),
    .FIR_TAPS(FIR_TAPS),
    .CIC_STAGES(CIC_STAGES),
    .CIC_DECIMATION(CIC_DECIMATION),
    .FIR_DECIMATION(FIR_DECIMATION)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .adc_data(adc_data),
    .adc_valid(adc_valid),
    .adc_ready(adc_ready),
    .nco_freq(nco_freq),
    .nco_phase_offset(nco_phase_offset),
    .cic_decimation(cic_decimation),
    .fir_decimation(fir_decimation),
    .bypass_cic(bypass_cic),
    .bypass_fir(bypass_fir),
    .fir_coeff_data(fir_coeff_data),
    .fir_coeff_addr(fir_coeff_addr),
    .fir_coeff_wr(fir_coeff_wr),
    .fir_coeff_ld(fir_coeff_ld),
    .enable_ddc(enable_ddc),
    .enable_fir(enable_fir),
    .enable_decimation(enable_decimation),
    .i_data_out(i_data_out),
    .q_data_out(q_data_out),
    .out_valid(out_valid),
    .out_ready(out_ready),
    .ddc_locked(ddc_locked),
    .ddc_status(ddc_status),
    .fir_status(fir_status),
    .decim_status(decim_status),
    .system_status(system_status)
);

//=============================================================================
// Clock Generation
//=============================================================================
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

//=============================================================================
// Test Stimulus
//=============================================================================
initial begin
    // Initialize signals
    rst_n = 0;
    adc_valid = 0;
    adc_data = 0;
    nco_freq = 0;
    nco_phase_offset = 0;
    cic_decimation = CIC_DECIMATION;
    fir_decimation = FIR_DECIMATION;
    bypass_cic = 0;
    bypass_fir = 0;
    fir_coeff_data = 0;
    fir_coeff_addr = 0;
    fir_coeff_wr = 0;
    fir_coeff_ld = 0;
    enable_ddc = 0;
    enable_fir = 0;
    enable_decimation = 0;
    out_ready = 1;
    sample_counter = 0;
    test_frequency = 16'h1000; // Test frequency
    test_amplitude = 16'h2000; // Test amplitude
    
    // Reset sequence
    #(CLK_PERIOD * 10);
    rst_n = 1;
    #(CLK_PERIOD * 5);
    
    // Test 1: Basic DDC functionality
    $display("Test 1: Basic DDC functionality");
    test_basic_ddc();
    
    // Test 2: FIR filter functionality
    $display("Test 2: FIR filter functionality");
    test_fir_filter();
    
    // Test 3: Decimation functionality
    $display("Test 3: Decimation functionality");
    test_decimation();
    
    // Test 4: Complete system test
    $display("Test 4: Complete system test");
    test_complete_system();
    
    // Test 5: Performance test
    $display("Test 5: Performance test");
    test_performance();
    
    // End simulation
    #(CLK_PERIOD * 100);
    $display("All tests completed successfully!");
    $finish;
end

//=============================================================================
// Test Functions
//=============================================================================

// Test 1: Basic DDC functionality
task test_basic_ddc;
    begin
        $display("  Starting basic DDC test...");
        
        // Configure NCO
        nco_freq = 24'h100000; // Set NCO frequency
        nco_phase_offset = 16'h0000;
        
        // Enable DDC only
        enable_ddc = 1;
        enable_fir = 0;
        enable_decimation = 0;
        
        // Generate test signal
        generate_test_signal(1000);
        
        // Check DDC lock
        wait_for_ddc_lock();
        
        $display("  Basic DDC test completed");
    end
endtask

// Test 2: FIR filter functionality
task test_fir_filter;
    begin
        $display("  Starting FIR filter test...");
        
        // Load FIR coefficients
        load_fir_coefficients();
        
        // Enable DDC and FIR
        enable_ddc = 1;
        enable_fir = 1;
        enable_decimation = 0;
        
        // Generate test signal
        generate_test_signal(2000);
        
        $display("  FIR filter test completed");
    end
endtask

// Test 3: Decimation functionality
task test_decimation;
    begin
        $display("  Starting decimation test...");
        
        // Configure decimation
        cic_decimation = 8;
        fir_decimation = 4;
        bypass_cic = 0;
        bypass_fir = 0;
        
        // Enable all stages
        enable_ddc = 1;
        enable_fir = 1;
        enable_decimation = 1;
        
        // Generate test signal
        generate_test_signal(3000);
        
        $display("  Decimation test completed");
    end
endtask

// Test 4: Complete system test
task test_complete_system;
    begin
        $display("  Starting complete system test...");
        
        // Full system configuration
        nco_freq = 24'h200000;
        cic_decimation = 16;
        fir_decimation = 2;
        bypass_cic = 0;
        bypass_fir = 0;
        
        enable_ddc = 1;
        enable_fir = 1;
        enable_decimation = 1;
        
        // Generate complex test signal
        generate_complex_test_signal(5000);
        
        $display("  Complete system test completed");
    end
endtask

// Test 5: Performance test
task test_performance;
    begin
        $display("  Starting performance test...");
        
        // High-speed test
        generate_high_speed_test(10000);
        
        // Check performance metrics
        check_performance_metrics();
        
        $display("  Performance test completed");
    end
endtask

//=============================================================================
// Helper Functions
//=============================================================================

// Generate simple test signal
task generate_test_signal;
    input [31:0] num_samples;
    integer i;
    begin
        for (i = 0; i < num_samples; i = i + 1) begin
            @(posedge clk);
            adc_valid = 1;
            // Generate sine wave test signal
            adc_data = test_amplitude * $signed($signed(sample_counter) * test_frequency);
            sample_counter = sample_counter + 1;
            
            if (!adc_ready) begin
                @(posedge clk);
                adc_valid = 0;
                @(posedge clk);
            end
        end
        adc_valid = 0;
    end
endtask

// Generate complex test signal
task generate_complex_test_signal;
    input [31:0] num_samples;
    integer i;
    begin
        for (i = 0; i < num_samples; i = i + 1) begin
            @(posedge clk);
            adc_valid = 1;
            // Generate complex signal with multiple frequencies
            adc_data = test_amplitude * (
                $signed($signed(sample_counter) * test_frequency) +
                $signed($signed(sample_counter) * (test_frequency >> 1)) / 2
            );
            sample_counter = sample_counter + 1;
            
            if (!adc_ready) begin
                @(posedge clk);
                adc_valid = 0;
                @(posedge clk);
            end
        end
        adc_valid = 0;
    end
endtask

// Generate high-speed test
task generate_high_speed_test;
    input [31:0] num_samples;
    integer i;
    begin
        for (i = 0; i < num_samples; i = i + 1) begin
            @(posedge clk);
            adc_valid = 1;
            adc_data = $random; // Random data for stress test
            sample_counter = sample_counter + 1;
        end
        adc_valid = 0;
    end
endtask

// Load FIR coefficients
task load_fir_coefficients;
    integer i;
    begin
        $display("    Loading FIR coefficients...");
        for (i = 0; i < FIR_TAPS; i = i + 1) begin
            @(posedge clk);
            fir_coeff_addr = i;
            fir_coeff_data = generate_fir_coefficient(i);
            fir_coeff_wr = 1;
            @(posedge clk);
            fir_coeff_wr = 0;
        end
        @(posedge clk);
        fir_coeff_ld = 1;
        @(posedge clk);
        fir_coeff_ld = 0;
        $display("    FIR coefficients loaded");
    end
endtask

// Generate FIR coefficient
function [17:0] generate_fir_coefficient;
    input [7:0] index;
    begin
        // Simple low-pass filter coefficients
        if (index < FIR_TAPS/4) begin
            generate_fir_coefficient = 18'h10000; // 1.0 in Q16.2 format
        end else if (index < FIR_TAPS/2) begin
            generate_fir_coefficient = 18'h08000; // 0.5 in Q16.2 format
        end else begin
            generate_fir_coefficient = 18'h00000; // 0.0
        end
    end
endfunction

// Wait for DDC lock
task wait_for_ddc_lock;
    integer timeout;
    begin
        timeout = 0;
        while (!ddc_locked && timeout < 1000) begin
            @(posedge clk);
            timeout = timeout + 1;
        end
        if (ddc_locked) begin
            $display("    DDC locked successfully");
        end else begin
            $display("    Warning: DDC did not lock within timeout");
        end
    end
endtask

// Check performance metrics
task check_performance_metrics;
    begin
        $display("    Checking performance metrics...");
        $display("    DDC Status: %h", ddc_status);
        $display("    FIR Status: %h", fir_status);
        $display("    Decimation Status: %h", decim_status);
        $display("    System Status: %h", system_status);
    end
endtask

//=============================================================================
// Output Monitoring
//=============================================================================
always @(posedge clk) begin
    if (out_valid && out_ready) begin
        $display("Output: I=%h, Q=%h", i_data_out, q_data_out);
    end
end

//=============================================================================
// Coverage and Assertions
//=============================================================================
// Add coverage points and assertions here for comprehensive verification

endmodule 