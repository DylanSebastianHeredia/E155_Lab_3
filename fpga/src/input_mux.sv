// Sebastian Heredia
// dheredia@g.hmc.edu
// September 16, 2025

// WORKS

module input_mux (
	input logic 	   clk, 
	input logic 	   reset,
	input logic  [3:0] s1,			// 1st s input
	input logic  [3:0] s2,			// 2nd s input
	output logic 	   select, 	
	output logic 	   notselect,
	output logic [3:0] s
	);
	
	// Internal logic counter
	logic [17:0] counter;
	
	assign notselect = ~select;
	
	always_ff @ (posedge clk) begin	// Removed: ", negedge reset" since bad for asynch 
		if (reset == 0) begin
			select <= 1;
			s <= s1;
		end
		
		else begin
			if (select)
				s <= s2;
				
			else 
				s <= s1;
				select <= ~select;
		
		end
	end
endmodule				
