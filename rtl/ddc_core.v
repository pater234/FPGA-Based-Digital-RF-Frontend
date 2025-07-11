//=============================================================================
// FPGA-Based Digital RF Frontend - DDC Core Module
//=============================================================================
// This module implements the main Digital Downconversion (DDC) core
// featuring NCO, complex multiplication, and I/Q signal separation
//
// Author: pater234
// Date: 2025
// Target: Xilinx Series 7, UltraScale, UltraScale+
//=============================================================================

module ddc_core #(
    parameter DATA_WIDTH = 16,           // Input data width
    parameter NCO_WIDTH = 24,            // NCO phase accumulator width
    parameter OUTPUT_WIDTH = 18,         // Output data width
    parameter CORDIC_ITERATIONS = 12     // CORDIC iterations for sine/cosine
)(
    input wire clk,                      // System clock
    input wire rst_n,                    // Active low reset
    input wire enable,                   // Enable DDC processing
    
    // Configuration interface
    input wire [NCO_WIDTH-1:0] nco_freq, // NCO frequency control word
    input wire [15:0] nco_phase_offset,  // NCO phase offset
    
    // Input data interface
    input wire [DATA_WIDTH-1:0] rf_data, // RF input data
    input wire rf_valid,                 // Input data valid
    output wire rf_ready,                // Input ready signal
    
    // Output data interface
    output wire [OUTPUT_WIDTH-1:0] i_data, // In-phase output
    output wire [OUTPUT_WIDTH-1:0] q_data, // Quadrature output
    output wire iq_valid,                   // Output valid signal
    input wire iq_ready,                    // Output ready signal
    
    // Status and control
    output wire nco_locked,              // NCO frequency locked indicator
    output wire [15:0] status            // Status register
);

//=============================================================================
// Internal signals and registers
//=============================================================================
reg [NCO_WIDTH-1:0] phase_acc;
reg [NCO_WIDTH-1:0] phase_acc_next;
reg [15:0] sine_val, cosine_val;
reg [OUTPUT_WIDTH-1:0] i_data_reg, q_data_reg;
reg iq_valid_reg;
reg nco_locked_reg;
reg [15:0] status_reg;

// Complex multiplication results
wire [OUTPUT_WIDTH-1:0] i_result, q_result;
wire mult_valid;

// CORDIC interface
wire [15:0] cordic_sine, cordic_cosine;
wire cordic_valid;
wire cordic_ready;

//=============================================================================
// NCO Phase Accumulator
//=============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        phase_acc <= {NCO_WIDTH{1'b0}};
    end else if (enable) begin
        phase_acc <= phase_acc_next;
    end
end

always @(*) begin
    phase_acc_next = phase_acc + nco_freq + nco_phase_offset;
end

//=============================================================================
// CORDIC Instance for Sine/Cosine Generation
//=============================================================================
cordic #(
    .DATA_WIDTH(16),
    .ITERATIONS(CORDIC_ITERATIONS)
) cordic_inst (
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable),
    .angle(phase_acc[NCO_WIDTH-1:NCO_WIDTH-16]), // Use upper 16 bits
    .sine(cordic_sine),
    .cosine(cordic_cosine),
    .valid(cordic_valid),
    .ready(cordic_ready)
);

//=============================================================================
// Complex Multiplication
//=============================================================================
complex_multiplier #(
    .DATA_WIDTH(DATA_WIDTH),
    .OUTPUT_WIDTH(OUTPUT_WIDTH)
) mult_inst (
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable),
    .a_real(rf_data),
    .a_imag(16'h0000), // RF data is real
    .b_real(cordic_cosine),
    .b_imag(cordic_sine),
    .result_real(i_result),
    .result_imag(q_result),
    .valid(mult_valid),
    .ready(rf_ready)
);

//=============================================================================
// Output Register Stage
//=============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        i_data_reg <= {OUTPUT_WIDTH{1'b0}};
        q_data_reg <= {OUTPUT_WIDTH{1'b0}};
        iq_valid_reg <= 1'b0;
    end else if (enable && mult_valid && iq_ready) begin
        i_data_reg <= i_result;
        q_data_reg <= q_result;
        iq_valid_reg <= 1'b1;
    end else if (iq_ready) begin
        iq_valid_reg <= 1'b0;
    end
end

//=============================================================================
// Status and Control Logic
//=============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        nco_locked_reg <= 1'b0;
        status_reg <= 16'h0000;
    end else if (enable) begin
        // Simple lock detection (can be enhanced)
        nco_locked_reg <= (nco_freq != 0);
        
        // Status register
        status_reg[0] <= enable;
        status_reg[1] <= rf_valid;
        status_reg[2] <= iq_valid_reg;
        status_reg[3] <= cordic_valid;
        status_reg[4] <= mult_valid;
        status_reg[15:5] <= 11'h000;
    end
end

//=============================================================================
// Output Assignments
//=============================================================================
assign i_data = i_data_reg;
assign q_data = q_data_reg;
assign iq_valid = iq_valid_reg;
assign nco_locked = nco_locked_reg;
assign status = status_reg;

endmodule 