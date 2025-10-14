// Sebastian Heredia
// dheredia@g.hmc.edu
// October 13, 2025

// kpad_decoder_tb automatically tests all valid row & column combinations on the keypad
// to verify correct hexadecimal decoding.

`timescale 1ns/1ps

module kpad_decoder_tb();

	logic clk;
	logic reset;
	logic enable;
	logic [3:0] col;
	logic [3:0] row;
	logic [3:0] s1;
	logic [3:0] s2;

	// Instantiate kpad_decoder
	kpad_decoder dut (clk, reset, col, row, enable, s1, s2);

	// Clock generation: 10ns period
	always begin
		clk = 0; #5;
		clk = 1; #5;
	end

	// Expected next number function
	function automatic [3:0] exp_next_number(input [3:0] r, input [3:0] c);
		case ({r, c})
			{4'b0001, 4'b0001}: exp_next_number = 4'b0001;	// 1
			{4'b0001, 4'b0010}: exp_next_number = 4'b0010;	// 2
			{4'b0001, 4'b0100}: exp_next_number = 4'b0011;	// 3
			{4'b0001, 4'b1000}: exp_next_number = 4'b1010;	// A
			
			{4'b0010, 4'b0001}: exp_next_number = 4'b0100;	// 4
			{4'b0010, 4'b0010}: exp_next_number = 4'b0101;	// 5
			{4'b0010, 4'b0100}: exp_next_number = 4'b0110;	// 6
			{4'b0010, 4'b1000}: exp_next_number = 4'b1011;	// B
			
			{4'b0100, 4'b0001}: exp_next_number = 4'b0111;	// 7
			{4'b0100, 4'b0010}: exp_next_number = 4'b1000;	// 8
			{4'b0100, 4'b0100}: exp_next_number = 4'b1001;	// 9
			{4'b0100, 4'b1000}: exp_next_number = 4'b1100;	// C
			
			{4'b1000, 4'b0001}: exp_next_number = 4'b1110;	// E
			{4'b1000, 4'b0010}: exp_next_number = 4'b0000;	// 0
			{4'b1000, 4'b0100}: exp_next_number = 4'b1111;	// F
			{4'b1000, 4'b1000}: exp_next_number = 4'b1101;	// D
			
			default: exp_next_number = 4'b0000;
		endcase
	endfunction

	initial begin
		reset = 0;
		enable = 0;
		row = 0;
		col = 0; #20;
		reset = 1; #20;

		// Test only valid single-row/single-column combinations
		for (int r = 0; r < 4; r++) begin
			row = (1 << r);
			for (int c = 0; c < 4; c++) begin
				col = (1 << c);
				enable = 1;
				@(posedge clk);
				enable = 0;
				@(posedge clk);

				if (s1 !== exp_next_number(row, col))
					$display("ERROR: row=%b col=%b -> s1=%b expected=%b",
							 row, col, s1, exp_next_number(row, col));
			end
		end

		$display("All valid keypad combinations tested successfully!");
		$finish;
	end

endmodule
