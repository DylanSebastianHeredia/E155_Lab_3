// Sebastian Heredia
// dheredia@g.hmc.edu
// September 16, 2025

// sychronizer.sv contains code to generate a synchronizer that aligns asynchronous signals with 
// the project clock.

module synchronizer (
	input logic		      clk,
	input logic		   	  reset,
	input logic		[3:0] async_input,		// Asynchronous column input
	output logic 	[3:0] sync_output		// Synchronous column output from synchronizer
	);
	
	 //Internal logic variable to store asynchronous column input
	logic [3:0] n;
	
	always_ff @(posedge clk, negedge reset) begin
		if (reset == 0) begin
			n <= 4'b0000;
			sync_output <= 4'b0000;
		end
		else begin
			n <= async_input;
			sync_output <= n;
		end
	end
endmodule
