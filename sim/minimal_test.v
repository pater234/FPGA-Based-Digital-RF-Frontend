//=============================================================================
// Minimal Test - Basic Verilog Test
//=============================================================================
// This is a minimal test to verify Verilog compilation
//
// Author: pater234
// Date: 2025
//=============================================================================

module minimal_test;

reg clk;
reg rst_n;
reg [15:0] test_data;
wire [17:0] test_output;

// Simple clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Simple test stimulus
initial begin
    $display("Starting minimal test...");
    
    rst_n = 0;
    test_data = 0;
    
    #20;
    rst_n = 1;
    
    // Send some test data
    for (integer i = 0; i < 10; i = i + 1) begin
        @(posedge clk);
        test_data = i * 100;
        $display("Test data: %d", test_data);
    end
    
    #50;
    $display("Minimal test completed!");
    $finish;
end

endmodule 