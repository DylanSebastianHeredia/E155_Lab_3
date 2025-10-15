// Sebastian Heredia
// dheredia@g.hmc.edu
// October 14, 2025
// synchronizer_tb.sv contains code to verify synchronizer module function. 

`timescale 1ns/1ps

module synchronizer_tb;

    // Tb signals
    logic clk;
    logic reset;
    logic [3:0] async_input;
    logic [3:0] sync_output;

    // Instantiate synchronizer
    synchronizer dut (clk, reset, async_input, sync_output);
   
    always #5 clk = ~clk;

    initial begin
    
        clk = 0;
        reset = 0;
        async_input = 4'b0000; #10;
		
        reset = 1;
        $display("Time=%0t : Reset released", $time); #8;

        // Apply some asynchronous inputs
        async_input = 4'b1010; #12;
        async_input = 4'b0101; #10;
        async_input = 4'b1111; #7;
        sync_input  = 4'b0001; #15;
        async_input = 4'b1000; #20;

        $finish;
    end
endmodule
