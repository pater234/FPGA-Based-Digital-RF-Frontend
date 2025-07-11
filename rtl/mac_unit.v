//=============================================================================
// FPGA-Based Digital RF Frontend - MAC Unit Module
//=============================================================================
// This module implements a high-performance MAC (Multiply-Accumulate) unit
// optimized for Xilinx DSP48E1/E2 slices
//
// Author: pater234
// Date: 2025
// Target: Xilinx Series 7, UltraScale, UltraScale+
//=============================================================================

module mac_unit #(
    parameter DATA_WIDTH = 18,           // Data width
    parameter COEFF_WIDTH = 18,          // Coefficient width
    parameter ACC_WIDTH = 48,            // Accumulator width
    parameter PIPELINE_STAGES = 3        // Number of pipeline stages
)(
    input wire clk,                      // System clock
    input wire rst_n,                    // Active low reset
    input wire enable,                   // Enable MAC processing
    
    // Data interface
    input wire [DATA_WIDTH-1:0] data_in, // Input data
    input wire [COEFF_WIDTH-1:0] coeff,  // Coefficient
    input wire data_valid,               // Input data valid
    output wire data_ready,              // Input ready signal
    
    // Control interface
    input wire clear_acc,                // Clear accumulator
    input wire load_acc,                 // Load accumulator with value
    input wire [ACC_WIDTH-1:0] acc_load_value, // Value to load into accumulator
    
    // Output interface
    output reg [ACC_WIDTH-1:0] acc_out,  // Accumulator output
    output reg acc_valid,                // Accumulator output valid
    input wire acc_ready,                // Output ready signal
    
    // Status
    output wire [15:0] status            // Status register
);

//=============================================================================
// Internal signals and registers
//=============================================================================
reg [ACC_WIDTH-1:0] accumulator;
reg [ACC_WIDTH-1:0] accumulator_next;
reg [DATA_WIDTH+COEFF_WIDTH-1:0] mult_result;
reg [PIPELINE_STAGES-1:0] pipeline_valid;
reg [PIPELINE_STAGES-1:0] pipeline_clear;
reg [PIPELINE_STAGES-1:0] pipeline_load;
reg [ACC_WIDTH-1:0] pipeline_load_value [0:PIPELINE_STAGES-1];
reg [15:0] status_reg;

// Pipeline registers for multiplication result
reg [DATA_WIDTH+COEFF_WIDTH-1:0] mult_pipeline [0:PIPELINE_STAGES-1];

//=============================================================================
// MAC Pipeline Implementation
//=============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        accumulator <= {ACC_WIDTH{1'b0}};
        for (integer i = 0; i < PIPELINE_STAGES; i = i + 1) begin
            mult_pipeline[i] <= {(DATA_WIDTH+COEFF_WIDTH){1'b0}};
            pipeline_valid[i] <= 1'b0;
            pipeline_clear[i] <= 1'b0;
            pipeline_load[i] <= 1'b0;
            pipeline_load_value[i] <= {ACC_WIDTH{1'b0}};
        end
        acc_valid <= 1'b0;
        acc_out <= {ACC_WIDTH{1'b0}};
    end else if (enable) begin
        // Pipeline stage 0: Input and multiplication
        if (data_valid && data_ready) begin
            mult_pipeline[0] <= data_in * coeff;
            pipeline_valid[0] <= 1'b1;
            pipeline_clear[0] <= clear_acc;
            pipeline_load[0] <= load_acc;
            pipeline_load_value[0] <= acc_load_value;
        end else begin
            pipeline_valid[0] <= 1'b0;
            pipeline_clear[0] <= 1'b0;
            pipeline_load[0] <= 1'b0;
        end
        
        // Pipeline stages 1 to N-1: Shift through pipeline
        for (integer i = 1; i < PIPELINE_STAGES; i = i + 1) begin
            mult_pipeline[i] <= mult_pipeline[i-1];
            pipeline_valid[i] <= pipeline_valid[i-1];
            pipeline_clear[i] <= pipeline_clear[i-1];
            pipeline_load[i] <= pipeline_load[i-1];
            pipeline_load_value[i] <= pipeline_load_value[i-1];
        end
        
        // Final pipeline stage: Accumulation
        if (pipeline_valid[PIPELINE_STAGES-1]) begin
            if (pipeline_clear[PIPELINE_STAGES-1]) begin
                // Clear accumulator
                accumulator <= {ACC_WIDTH{1'b0}};
            end else if (pipeline_load[PIPELINE_STAGES-1]) begin
                // Load accumulator with value
                accumulator <= pipeline_load_value[PIPELINE_STAGES-1];
            end else begin
                // Normal accumulation
                accumulator <= accumulator + mult_pipeline[PIPELINE_STAGES-1];
            end
            
            // Output result
            acc_out <= accumulator_next;
            acc_valid <= 1'b1;
        end else begin
            acc_valid <= 1'b0;
        end
    end else begin
        acc_valid <= 1'b0;
    end
end

//=============================================================================
// Accumulator next value calculation
//=============================================================================
always @(*) begin
    if (pipeline_clear[PIPELINE_STAGES-1]) begin
        accumulator_next = {ACC_WIDTH{1'b0}};
    end else if (pipeline_load[PIPELINE_STAGES-1]) begin
        accumulator_next = pipeline_load_value[PIPELINE_STAGES-1];
    end else begin
        accumulator_next = accumulator + mult_pipeline[PIPELINE_STAGES-1];
    end
end

//=============================================================================
// Status and control logic
//=============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        status_reg <= 16'h0000;
    end else if (enable) begin
        status_reg[0] <= enable;
        status_reg[1] <= data_valid;
        status_reg[2] <= acc_valid;
        status_reg[3] <= clear_acc;
        status_reg[4] <= load_acc;
        status_reg[7:5] <= 3'h0;
        status_reg[15:8] <= 8'h0;
    end
end

//=============================================================================
// Output assignments
//=============================================================================
assign data_ready = enable;
assign status = status_reg;

//=============================================================================
// DSP48E1/E2 Optimization Attributes
//=============================================================================
// These attributes help Vivado map the MAC operations to DSP slices efficiently
(* USE_DSP = "YES" *)
(* attribute USE_DSP of mult_pipeline : signal is "YES" *)
(* attribute USE_DSP of accumulator : signal is "YES" *)

//=============================================================================
// DSP48E1/E2 Specific Optimizations
//=============================================================================
// For Series 7 devices (DSP48E1)
// - A input: data_in
// - B input: coeff
// - C input: accumulator (for accumulation)
// - P output: mult_result
// - ALUMODE: 0000 for P = A*B + C

// For UltraScale devices (DSP48E2)
// - Similar mapping but with enhanced features
// - Support for wider accumulators
// - Better pipeline optimization

endmodule 