//=============================================================================
// FPGA-Based Digital RF Frontend - Simple Testbench
//=============================================================================
// This is a simplified testbench for basic functionality testing
//
// Author: pater234
// Date: 2025
// Target: Xilinx Series 7, UltraScale, UltraScale+
//=============================================================================

module simple_testbench;

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
    $display("Starting Simple RF Frontend Test");
    
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
    
    // Reset sequence
    #(CLK_PERIOD * 10);
    rst_n = 1;
    #(CLK_PERIOD * 5);
    
    $display("Reset complete, starting basic test...");
    
    // Basic test: Enable DDC and send some data
    enable_ddc = 1;
    nco_freq = 24'h100000; // Set NCO frequency
    
    // Send 100 test samples
    for (integer i = 0; i < 100; i = i + 1) begin
        @(posedge clk);
        adc_valid = 1;
        adc_data = i * 100; // Simple test pattern
    end
    
    adc_valid = 0;
    
    // Wait for processing
    #(CLK_PERIOD * 50);
    
    $display("Basic test completed!");
    $display("DDC Status: %h", ddc_status);
    $display("System Status: %h", system_status);
    
    // End simulation
    #(CLK_PERIOD * 10);
    $display("Simulation completed successfully!");
    $finish;
end

//=============================================================================
// Output Monitoring
//=============================================================================
always @(posedge clk) begin
    if (out_valid && out_ready) begin
        $display("Output: I=%h, Q=%h", i_data_out, q_data_out);
    end
end

endmodule 