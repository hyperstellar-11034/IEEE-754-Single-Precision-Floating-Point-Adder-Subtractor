`timescale 1ns/1ps

module testbench;
    reg clk, reset, mode;
    reg [31:0] Number1, Number2;
    wire [31:0] Result;

    IEEE_SP_FP_ADDER dut (
        .clk(clk),
        .reset(reset),
        .mode(mode),
        .Number1(Number1),
        .Number2(Number2),
        .Result(Result)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, testbench);

        clk = 0;
        reset = 1;
        mode = 0;
        Number1 = 32'b0;
        Number2 = 32'b0;

        #10 reset = 0;

        // Test 1: 1.5 + 2.5 = 4.0
        Number1 = 32'b00111111110000000000000000000000;  // 1.5 decimal
        Number2 = 32'b01000000001000000000000000000000;  // 2.5 decimal
        mode = 0;
        @(posedge clk);
        repeat (6) @(posedge clk);
        // Expected Result: 4.0 = 32'b01000000100000000000000000000000
        $display("Test 1 Result = %b", Result);

        // Test 2: -2.0 + 3.0 = 1.0
        Number1 = 32'b11000000000000000000000000000000;  // -2.0 decimal
        Number2 = 32'b01000000010000000000000000000000;  // 3.0 decimal
        mode = 0;
        @(posedge clk);
        repeat (6) @(posedge clk);
        // Expected Result: 1.0 = 32'b00111111100000000000000000000000
        $display("Test 2 Result = %b", Result);

        // Test 3: 2.5 - 1.5 = 1.0
        Number1 = 32'b01000000001000000000000000000000;  // 2.5 decimal
        Number2 = 32'b00111111110000000000000000000000;  // 1.5 decimal
        mode = 1;
        @(posedge clk);
        repeat (6) @(posedge clk);
        // Expected Result: 1.0 = 32'b00111111100000000000000000000000
        $display("Test 3 Result = %b", Result);

        // Test 4: Normalization check with a small number
        // Number1 = 1.0 (binary: 00111111100000000000000000000000)
        // Number2 = ~1.0e-5 (binary: 00110110101000000000000000000000)
        // Expected Result ≈ 1.00001 decimal
        Number1 = 32'b00111111100000000000000000000000;  // 1.0 decimal
        Number2 = 32'b00110110101000000000000000000000;  // ~1.0e-5 decimal
        mode = 0;
        @(posedge clk);
        repeat (6) @(posedge clk);
        $display("Normalization Test Result = %b", Result);
        // Expected: exact result! 00111111100000001000000000000000

        $finish;
    end

    always #5 clk = ~clk;  // 10 ns clock period

endmodule