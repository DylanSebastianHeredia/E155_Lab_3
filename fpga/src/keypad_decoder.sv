// E155: Lab 3 - Keypad Scanner
// Sebastian Heredia, dheredia@g.hmc.edu
// September 16, 2025
// keypad_decoder.sv contains combinational logic to output s, a 4-bit number representing the concatenation 
// of row and column keypad values.

module keypad_decoder(	input logic 		[3:0] col,
						input logic 	 	[3:0] row,
						output logic 		[3:0] s
					  );

	always_comb begin
		case({row, col})				// Concatenating rows and columns
			// Active-LOW keypad
			// row_col
			8'b1110_1110: s = 4'h1;		// 1	row0, col0
			8'b1110_1101: s = 4'h2;		// 2	
			8'b1110_1011: s = 4'h3;		// 3
			8'b1110_0111: s = 4'hA;		// A	row0, col3
			
			8'b1101_1110: s = 4'h4;		// 4			
			8'b1101_1101: s = 4'h5;		// 5	
			8'b1101_1011: s = 4'h6;		// 6
			8'b1101_0111: s = 4'hB;		// B
			
			8'b1011_1110: s = 4'h7;		// 7
			8'b1011_1101: s = 4'h8;		// 8	
			8'b1011_1011: s = 4'h9;		// 9
			8'b1011_0111: s = 4'hC;		// C
			
			8'b0111_1110: s = 4'hE;		// E or *
			8'b0111_1101: s = 4'h0;		// 0	
			8'b0111_1011: s = 4'hF;		// F
			8'b0111_0111: s = 4'hD;		// D or #
			default: s = 4'h0;
		endcase
	end
endmodule
