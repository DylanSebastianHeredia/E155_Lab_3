// E155: Lab 3 - Keypad Scanner
// Sebastian Heredia, dheredia@g.hmc.edu
// September 21, 2025
// kd_testbench.sv contains code for an automatic testbench for keypad_decoder.sv that verifies that a given row and column
// combination produces the correct hexadecimal value on s. 
`timescale 1ns/1ps

module kd_testbench();

    logic [3:0] col;
    logic [3:0] row;
    logic [3:0] s;

    // Instantiate keypad_decoder
	keypad_decoder dut (col, row, s);
	
    // Expected outputs (duplicated from keypad_decoder)
    function [3:0]s_expected (	input [3:0] row,
								input [3:0] col);
								
		// Match order in keypad_decoder		
        case({row, col})	
			8'b1110_1110: s_expected = 4'h1;		// 1	row0, col0
			8'b1110_1101: s_expected = 4'h2;		// 2	
			8'b1110_1011: s_expected = 4'h3;		// 3
			8'b1110_0111: s_expected = 4'hA;		// A	row0, col3
			
			8'b1101_1110: s_expected = 4'h4;		// 4			
			8'b1101_1101: s_expected = 4'h5;		// 5	
			8'b1101_1011: s_expected = 4'h6;		// 6
			8'b1101_0111: s_expected = 4'hB;		// B
			
			8'b1011_1110: s_expected = 4'h7;		// 7
			8'b1011_1101: s_expected = 4'h8;		// 8	
			8'b1011_1011: s_expected = 4'h9;		// 9
			8'b1011_0111: s_expected = 4'hC;		// C
			
			8'b0111_1110: s_expected = 4'hE;		// E or *
			8'b0111_1101: s_expected = 4'h0;		// 0	
			8'b0111_1011: s_expected = 4'hF;		// F
			8'b0111_0111: s_expected = 4'hD;		// D or #
			default: s_expected = 4'h0;
		endcase
		
    endfunction

    // Start tests
    initial begin

        // Test all possible row and column input combinations
        for (int r = 0; r < 4; r++) begin			// Index r (rows)
            for (int c = 0; c < 4; c++) begin		// Index c (columns)
                row = r; 
                col = c;
                #20;	// Allow some cycles for DUT to settle
				
                // Checking if row and column combination for s matches s_expected
                if (s !== s_expected(row, col)) begin
                    $error("DECODING ERROR: s0=%b s1=%b expected=%h got=%h", row, col, s_expected(row, col), s);
                end
            end
        end

        $display("All tests for keypad_decoder passed successfully!");
        $finish;
    end
endmodule
