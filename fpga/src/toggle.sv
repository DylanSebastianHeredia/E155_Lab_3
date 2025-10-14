// Sebastian Heredia
// dheredia@g.hmc.edu
// September 16, 2025

// toggle.sv contains code to divide the 48MHz HSOSC system clock to 240Hz.

module toggle (
	input logic 	reset, 
	output logic 	toggle
	);

	// Define internal logic for oscillator
	logic int_osc;
	logic [31:0] counter;
	
	// Instatiate high-speed oscillator
	HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));	// 48MHz
		
	always_ff @(posedge int_osc) begin
		if (reset == 0) begin			// Intentionally active LOW
			counter  <= 0;
			toggle <= 0;
		end 
												
		else if (counter == 100000-1) begin
			counter   <= 0;
			toggle <= ~toggle;  		// Toggle after 100,000 counts for 240Hz
		end 
		
		else begin
			counter <= counter + 1;		// Continue incrementing counter for next toggle
		end
	end
endmodule
