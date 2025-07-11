//=============================================================================
// FPGA-Based Digital RF Frontend - Top Level Module
//=============================================================================
// This module integrates DDC, FIR filtering, and decimation into a complete
// RF frontend system optimized for Xilinx FPGAs
//
// Author: pater234
// Date: 2025
// Target: Xilinx Series 7, UltraScale, UltraScale+
//=============================================================================

module rf_frontend_top #(
    parameter ADC_WIDTH = 16,            // ADC data width
    parameter NCO_WIDTH = 24,            // NCO frequency control width
    parameter DDC_WIDTH = 18,            // DDC output width
    parameter FIR_WIDTH = 18,            // FIR filter width
    parameter OUTPUT_WIDTH = 18,         // Final output width
    parameter FIR_TAPS = 64,             // Number of FIR filter taps
    parameter CIC_STAGES = 3,            // Number of CIC stages
    parameter CIC_DECIMATION = 8,        // CIC decimation ratio
    parameter FIR_DECIMATION = 4         // FIR decimation ratio
)(
    input wire clk,                      // System clock
    input wire rst_n,                    // Active low reset
    
    // ADC Interface
    input wire [ADC_WIDTH-1:0] adc_data, // ADC input data
    input wire adc_valid,                // ADC data valid
    output wire adc_ready,               // ADC ready signal
    
    // Configuration Interface
    input wire [NCO_WIDTH-1:0] nco_freq, // NCO frequency control word
    input wire [15:0] nco_phase_offset,  // NCO phase offset
    input wire [7:0] cic_decimation,     // CIC decimation ratio
    input wire [7:0] fir_decimation,     // FIR decimation ratio
    input wire bypass_cic,               // Bypass CIC filter
    input wire bypass_fir,               // Bypass FIR filter
    
    // FIR Filter Coefficient Interface
    input wire [17:0] fir_coeff_data,    // FIR coefficient data
    input wire [7:0] fir_coeff_addr,     // FIR coefficient address
    input wire fir_coeff_wr,             // FIR coefficient write enable
    input wire fir_coeff_ld,             // Load FIR coefficient set
    
    // Control Interface
    input wire enable_ddc,               // Enable DDC processing
    input wire enable_fir,               // Enable FIR filtering
    input wire enable_decimation,        // Enable decimation
    
    // Output Interface
    output wire [OUTPUT_WIDTH-1:0] i_data_out, // In-phase output
    output wire [OUTPUT_WIDTH-1:0] q_data_out, // Quadrature output
    output wire out_valid,               // Output valid signal
    input wire out_ready,                // Output ready signal
    
    // Status Interface
    output wire ddc_locked,              // DDC frequency locked
    output wire [15:0] ddc_status,       // DDC status register
    output wire [15:0] fir_status,       // FIR status register
    output wire [15:0] decim_status,     // Decimation status register
    output wire [15:0] system_status     // System status register
);

//=============================================================================
// Internal signals
//=============================================================================
// DDC outputs
wire [DDC_WIDTH-1:0] ddc_i_out, ddc_q_out;
wire ddc_valid;
wire ddc_ready;

// FIR filter outputs
wire [FIR_WIDTH-1:0] fir_i_out, fir_q_out;
wire fir_valid;
wire fir_ready;

// Decimation outputs
wire [OUTPUT_WIDTH-1:0] decim_i_out, decim_q_out;
wire decim_valid;
wire decim_ready;

// System status
reg [15:0] system_status_reg;

//=============================================================================
// DDC Core Instance
//=============================================================================
ddc_core #(
    .DATA_WIDTH(ADC_WIDTH),
    .NCO_WIDTH(NCO_WIDTH),
    .OUTPUT_WIDTH(DDC_WIDTH),
    .CORDIC_ITERATIONS(12)
) ddc_inst (
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable_ddc),
    .nco_freq(nco_freq),
    .nco_phase_offset(nco_phase_offset),
    .rf_data(adc_data),
    .rf_valid(adc_valid),
    .rf_ready(adc_ready),
    .i_data(ddc_i_out),
    .q_data(ddc_q_out),
    .iq_valid(ddc_valid),
    .iq_ready(ddc_ready),
    .nco_locked(ddc_locked),
    .status(ddc_status)
);

//=============================================================================
// FIR Filter Instance (I-channel)
//=============================================================================
fir_filter #(
    .DATA_WIDTH(DDC_WIDTH),
    .COEFF_WIDTH(18),
    .OUTPUT_WIDTH(FIR_WIDTH),
    .NUM_TAPS(FIR_TAPS),
    .SYMMETRIC(1)
) fir_i_inst (
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable_fir),
    .coeff_data(fir_coeff_data),
    .coeff_addr(fir_coeff_addr),
    .coeff_wr(fir_coeff_wr),
    .coeff_ld(fir_coeff_ld),
    .data_in(ddc_i_out),
    .data_valid(ddc_valid),
    .data_ready(ddc_ready),
    .data_out(fir_i_out),
    .out_valid(fir_valid),
    .out_ready(fir_ready),
    .status(fir_status)
);

//=============================================================================
// FIR Filter Instance (Q-channel)
//=============================================================================
fir_filter #(
    .DATA_WIDTH(DDC_WIDTH),
    .COEFF_WIDTH(18),
    .OUTPUT_WIDTH(FIR_WIDTH),
    .NUM_TAPS(FIR_TAPS),
    .SYMMETRIC(1)
) fir_q_inst (
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable_fir),
    .coeff_data(fir_coeff_data),
    .coeff_addr(fir_coeff_addr),
    .coeff_wr(fir_coeff_wr),
    .coeff_ld(fir_coeff_ld),
    .data_in(ddc_q_out),
    .data_valid(ddc_valid),
    .data_ready(), // Shared ready signal from I-channel
    .data_out(fir_q_out),
    .out_valid(), // Shared valid signal from I-channel
    .out_ready(fir_ready),
    .status() // Status from I-channel is sufficient
);

//=============================================================================
// Decimation Chain Instance
//=============================================================================
decimation #(
    .DATA_WIDTH(FIR_WIDTH),
    .OUTPUT_WIDTH(OUTPUT_WIDTH),
    .CIC_STAGES(CIC_STAGES),
    .CIC_DECIMATION(CIC_DECIMATION),
    .FIR_DECIMATION(FIR_DECIMATION),
    .FIR_TAPS(32)
) decim_inst (
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable_decimation),
    .cic_decimation(cic_decimation),
    .fir_decimation(fir_decimation),
    .bypass_cic(bypass_cic),
    .bypass_fir(bypass_fir),
    .i_data_in(fir_i_out),
    .q_data_in(fir_q_out),
    .data_valid(fir_valid),
    .data_ready(fir_ready),
    .i_data_out(decim_i_out),
    .q_data_out(decim_q_out),
    .out_valid(decim_valid),
    .out_ready(decim_ready),
    .status(decim_status)
);

//=============================================================================
// Output Stage
//=============================================================================
assign i_data_out = decim_i_out;
assign q_data_out = decim_q_out;
assign out_valid = decim_valid;
assign decim_ready = out_ready;

//=============================================================================
// System Status Logic
//=============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        system_status_reg <= 16'h0000;
    end else begin
        system_status_reg[0] <= enable_ddc;
        system_status_reg[1] <= enable_fir;
        system_status_reg[2] <= enable_decimation;
        system_status_reg[3] <= ddc_locked;
        system_status_reg[4] <= adc_valid;
        system_status_reg[5] <= out_valid;
        system_status_reg[6] <= bypass_cic;
        system_status_reg[7] <= bypass_fir;
        system_status_reg[15:8] <= 8'h00;
    end
end

assign system_status = system_status_reg;

//=============================================================================
// Clock Domain Crossing Considerations
//=============================================================================
// Note: This design assumes all modules operate in the same clock domain
// For multi-clock domain designs, proper CDC logic would be required

//=============================================================================
// Performance Monitoring
//=============================================================================
// The status registers provide visibility into:
// - DDC lock status and performance
// - FIR filter operation status
// - Decimation chain status
// - Overall system health

endmodule 