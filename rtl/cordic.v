//=============================================================================
// FPGA-Based Digital RF Frontend - CORDIC Module
//=============================================================================
// This module implements the CORDIC (COrdinate Rotation DIgital Computer)
// algorithm for efficient sine/cosine generation
//
// Author: pater234
// Date: 2025
// Target: Xilinx Series 7, UltraScale, UltraScale+
//=============================================================================

module cordic #(
    parameter DATA_WIDTH = 16,           // Data width for sine/cosine output
    parameter ITERATIONS = 12,           // Number of CORDIC iterations
    parameter ANGLE_WIDTH = 16           // Angle input width
)(
    input wire clk,                      // System clock
    input wire rst_n,                    // Active low reset
    input wire enable,                   // Enable CORDIC processing
    input wire [ANGLE_WIDTH-1:0] angle,  // Input angle (0 to 2π)
    output reg [DATA_WIDTH-1:0] sine,    // Sine output
    output reg [DATA_WIDTH-1:0] cosine,  // Cosine output
    output reg valid,                    // Output valid signal
    output wire ready                    // Ready for new input
);

//=============================================================================
// CORDIC Constants and Lookup Tables
//=============================================================================
// Pre-computed arctangent values for each iteration
// These are fixed-point values scaled by 2^15
reg [15:0] atan_table [0:ITERATIONS-1];

// Initial values for CORDIC algorithm
reg [DATA_WIDTH-1:0] x_init, y_init, z_init;

//=============================================================================
// Internal signals
//=============================================================================
reg [DATA_WIDTH-1:0] x [0:ITERATIONS], y [0:ITERATIONS], z [0:ITERATIONS];
reg [ITERATIONS-1:0] iteration_valid;
reg [ITERATIONS-1:0] iteration_done;
reg processing;
reg [4:0] iteration_count;

//=============================================================================
// Initialize CORDIC constants
//=============================================================================
initial begin
    // Arctangent table (scaled by 2^15)
    atan_table[0]  = 16'h4000; // atan(1) = π/4
    atan_table[1]  = 16'h25C8; // atan(1/2)
    atan_table[2]  = 16'h13F6; // atan(1/4)
    atan_table[3]  = 16'h0A22; // atan(1/8)
    atan_table[4]  = 16'h0516; // atan(1/16)
    atan_table[5]  = 16'h028B; // atan(1/32)
    atan_table[6]  = 16'h0145; // atan(1/64)
    atan_table[7]  = 16'h00A2; // atan(1/128)
    atan_table[8]  = 16'h0051; // atan(1/256)
    atan_table[9]  = 16'h0028; // atan(1/512)
    atan_table[10] = 16'h0014; // atan(1/1024)
    atan_table[11] = 16'h000A; // atan(1/2048)
    
    // Initial values for rotation mode
    x_init = (1 << (DATA_WIDTH-2)); // 0.5 in fixed-point
    y_init = 0;
    z_init = 0;
end

//=============================================================================
// Input processing and angle normalization
//=============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        processing <= 1'b0;
        iteration_count <= 5'h0;
        valid <= 1'b0;
        sine <= {DATA_WIDTH{1'b0}};
        cosine <= {DATA_WIDTH{1'b0}};
    end else if (enable && !processing) begin
        // Start new CORDIC calculation
        processing <= 1'b1;
        iteration_count <= 5'h0;
        valid <= 1'b0;
        
        // Initialize first iteration
        x[0] <= x_init;
        y[0] <= y_init;
        z[0] <= angle[ANGLE_WIDTH-1:ANGLE_WIDTH-16]; // Use upper 16 bits
    end else if (processing) begin
        // CORDIC iteration pipeline
        if (iteration_count < ITERATIONS) begin
            iteration_count <= iteration_count + 1;
            
            // CORDIC iteration logic
            if (z[iteration_count] >= 0) begin
                // Positive rotation
                x[iteration_count + 1] <= x[iteration_count] - (y[iteration_count] >>> iteration_count);
                y[iteration_count + 1] <= y[iteration_count] + (x[iteration_count] >>> iteration_count);
                z[iteration_count + 1] <= z[iteration_count] - atan_table[iteration_count];
            end else begin
                // Negative rotation
                x[iteration_count + 1] <= x[iteration_count] + (y[iteration_count] >>> iteration_count);
                y[iteration_count + 1] <= y[iteration_count] - (x[iteration_count] >>> iteration_count);
                z[iteration_count + 1] <= z[iteration_count] + atan_table[iteration_count];
            end
        end else begin
            // CORDIC calculation complete
            processing <= 1'b0;
            valid <= 1'b1;
            
            // Output results (scaled by CORDIC gain)
            cosine <= x[ITERATIONS];
            sine <= y[ITERATIONS];
        end
    end else begin
        valid <= 1'b0;
    end
end

//=============================================================================
// Ready signal generation
//=============================================================================
assign ready = !processing;

endmodule 