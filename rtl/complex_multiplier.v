//=============================================================================
// FPGA-Based Digital RF Frontend - Complex Multiplier Module
//=============================================================================
// This module implements complex multiplication optimized for Xilinx DSP48E1/E2
// slices. It performs: (a_real + j*a_imag) * (b_real + j*b_imag)
//
// Author: pater234
// Date: 2025
// Target: Xilinx Series 7, UltraScale, UltraScale+
//=============================================================================

module complex_multiplier #(
    parameter DATA_WIDTH = 16,           // Input data width
    parameter OUTPUT_WIDTH = 18          // Output data width
)(
    input wire clk,                      // System clock
    input wire rst_n,                    // Active low reset
    input wire enable,                   // Enable processing
    input wire [DATA_WIDTH-1:0] a_real,  // Real part of first operand
    input wire [DATA_WIDTH-1:0] a_imag,  // Imaginary part of first operand
    input wire [DATA_WIDTH-1:0] b_real,  // Real part of second operand
    input wire [DATA_WIDTH-1:0] b_imag,  // Imaginary part of second operand
    output reg [OUTPUT_WIDTH-1:0] result_real, // Real part of result
    output reg [OUTPUT_WIDTH-1:0] result_imag, // Imaginary part of result
    output reg valid,                    // Output valid signal
    output wire ready                    // Ready for new input
);

//=============================================================================
// Internal signals and registers
//=============================================================================
reg [OUTPUT_WIDTH-1:0] temp_real, temp_imag;
reg [1:0] pipeline_stage;
reg processing;

// Complex multiplication intermediate results
// (a_real + j*a_imag) * (b_real + j*b_imag) = 
// (a_real*b_real - a_imag*b_imag) + j*(a_real*b_imag + a_imag*b_real)
reg [OUTPUT_WIDTH-1:0] real_real_prod, imag_imag_prod;
reg [OUTPUT_WIDTH-1:0] real_imag_prod, imag_real_prod;

//=============================================================================
// Complex multiplication pipeline
//=============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pipeline_stage <= 2'h0;
        processing <= 1'b0;
        valid <= 1'b0;
        result_real <= {OUTPUT_WIDTH{1'b0}};
        result_imag <= {OUTPUT_WIDTH{1'b0}};
        real_real_prod <= {OUTPUT_WIDTH{1'b0}};
        imag_imag_prod <= {OUTPUT_WIDTH{1'b0}};
        real_imag_prod <= {OUTPUT_WIDTH{1'b0}};
        imag_real_prod <= {OUTPUT_WIDTH{1'b0}};
    end else if (enable) begin
        case (pipeline_stage)
            2'h0: begin
                // Stage 0: Start new multiplication
                if (!processing) begin
                    processing <= 1'b1;
                    pipeline_stage <= 2'h1;
                    valid <= 1'b0;
                    
                    // Perform the four multiplications in parallel
                    // These will be mapped to DSP48E1/E2 slices
                    real_real_prod <= a_real * b_real;
                    imag_imag_prod <= a_imag * b_imag;
                    real_imag_prod <= a_real * b_imag;
                    imag_real_prod <= a_imag * b_real;
                end
            end
            
            2'h1: begin
                // Stage 1: Complete multiplications and start additions
                pipeline_stage <= 2'h2;
                
                // Store intermediate results
                temp_real <= real_real_prod - imag_imag_prod;
                temp_imag <= real_imag_prod + imag_real_prod;
            end
            
            2'h2: begin
                // Stage 2: Complete additions and output results
                pipeline_stage <= 2'h0;
                processing <= 1'b0;
                valid <= 1'b1;
                
                // Final results with proper scaling
                result_real <= temp_real;
                result_imag <= temp_imag;
            end
        endcase
    end else begin
        valid <= 1'b0;
    end
end

//=============================================================================
// Ready signal generation
//=============================================================================
assign ready = !processing;

//=============================================================================
// DSP48E1/E2 Optimization Attributes
//=============================================================================
// These attributes help Vivado map the multipliers to DSP slices efficiently
(* USE_DSP = "YES" *)
(* attribute USE_DSP of real_real_prod : signal is "YES" *)
(* attribute USE_DSP of imag_imag_prod : signal is "YES" *)
(* attribute USE_DSP of real_imag_prod : signal is "YES" *)
(* attribute USE_DSP of imag_real_prod : signal is "YES" *)

endmodule 