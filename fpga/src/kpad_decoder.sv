// Sebastian Heredia
// dheredia@g.hmc.edu
// September 16, 2025

// WORKS

module kpad_decoder (
	input logic 		  clk,
	input logic 		  reset,
	input logic 	[3:0] col,
	input logic 	[3:0] row,
	input logic 		  enable, 
	output logic 	[3:0] s1,
	output logic 	[3:0] s2
	);
	
	// Internal logic variables for next_state
	logic [3:0] next_number;
	
	// Update display signals when enable is HIGH
	always_ff @(posedge clk, negedge reset) begin
		if (reset == 0) begin
			s1 <= 4'b0000;
			s2 <= 4'b0000;
		end
		
		else if (enable) begin		// If enable is high, then we are settled in the row/col for that keypad number
			s1 <= next_number;
			s2 <= s1;
		end
	end
	
	// Combinational logic for the next display signal
    always_comb
        case({row, col})
			
			// Concatenating rows + columns
			{4'b0001, 4'b0001}: next_number = 4'b0001;		// 1 	row0, col0
			{4'b0001, 4'b0010}: next_number = 4'b0010;		// 2	row0, col1
			{4'b0001, 4'b0100}: next_number = 4'b0011;		// 3	row0, col2
			{4'b0001, 4'b1000}: next_number = 4'b1010;		// A	row0, col3
			
			{4'b0010, 4'b0001}: next_number = 4'b0100;		// ...	row1, col0
			{4'b0010, 4'b0010}: next_number = 4'b0101;
			{4'b0010, 4'b0100}: next_number = 4'b0110;
			{4'b0010, 4'b1000}: next_number = 4'b1011;
			
			{4'b0100, 4'b0001}: next_number = 4'b0111;		// ... 	row2
			{4'b0100, 4'b0010}: next_number = 4'b1000;
			{4'b0100, 4'b0100}: next_number = 4'b1001;
			{4'b0100, 4'b1000}: next_number = 4'b1100;
			
			{4'b1000, 4'b0001}: next_number = 4'b1110;		// ...	row3
			{4'b1000, 4'b0010}: next_number = 4'b0000;
			{4'b1000, 4'b0100}: next_number = 4'b1111;
			{4'b1000, 4'b1000}: next_number = 4'b1101;
            default: next_number = 4'b0000;
        endcase
endmodule


			

