// Sebastian Heredia
// dheredia@g.hmc.edu
// October 13, 2025

// lab3_dsh_tb contains code to verify functionality of the main function instantiations 
// and clock toggle. 

`timescale 1ns/1ps

module lab3_dsh_tb();

    logic clk;
    logic reset;
    logic [3:0] col;
    logic [3:0] row;
    logic select;
    logic notselect;
    logic [6:0] seg;

    // Internal logic
    logic [3:0] col_sync;
    logic [3:0] row_pressed;
    logic enable;
    logic [3:0] s1, s2, s;

  // Instantiate modules from lab3_dsh.sv
    synchronizer sync (clk, reset, col, col_sync);
  
    kpad_fsm fsm (clk, reset, col_sync, row, row_pressed, enable);
  
    kpad_decoder decoder (clk, reset, col_sync, row_pressed, enable, s1, s2);
  
    input_mux multiplexer (clk, reset, s1, s2, select, notselect, s);
  
    sevensegment sevenseg (s, seg);

    // Generate clock
    always begin
        clk = 0; #100;
        clk = 1; #100;
    end
  
    initial begin
        integer r, c;

        col   = 4'b0000;
        reset = 0;
        @(posedge clk);
        reset = 1;
        @(posedge clk);

        // Simulate a slow row & col pattern for clearer visual on Questa WaveSim
        for (r = 0; r < 4; r = r + 1) begin
            
            repeat (3) @(posedge clk);
            $display("[%0t] Testing row %0d", $time, r);

            for (c = 0; c < 4; c = c + 1) begin
                @(posedge clk);
                col = (4'b0001 << c);
                $display("[%0t] Pressing key Row=%0d Col=%0d", $time, r, c);
                repeat (4) @(posedge clk);

                col = 4'b0000;
                repeat (2) @(posedge clk);
            end
        end

        $display("Tests Completed!");
        repeat (10) @(posedge clk);
        $finish;
    end
endmodule
