// E155: Lab 3 - Keypad Scanner
// Sebastian Heredia, dheredia@g.hmc.edu
// September 16, 2025
// lab3_dsh.sv contains code to instantiate sevensegment.sv to light up a dual 7-segment display and display 
// the last two hexadecimal digits presed on a keyboard. 

module lab3_dsh (	input logic 		  reset,
					input logic 	[3:0] col,
					output logic 	[3:0] row,
					output logic 	[6:0] seg, 
					output logic 		  select, 
					output logic		  notselect
				);
			
	// Instantiate HSOSC
	logic int_osc;						// Integer # of oscillations
	
	HSOSC #(.CLKHF_DIV(2'b01)) 			// Divides clk to 24MHz
		hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

	// Clock divider
	logic [31:0] counter = 0;			// Start with counter at 0
	logic ON_OFF = 0;					// Toggle signal for clk divider
	
	always @(posedge int_osc or negedge reset) begin
		if (!reset)begin					// Intentionally active-LOW, NOT reset since using internal FPGA pull-up system
			counter <= 0;
			ON_OFF <= 0;
		end 
		else if (counter == 50000-1) begin	// 50,000 counts since indexing from 0-49,999
			counter   <= 0;
			ON_OFF <= ~ON_OFF;  			// Toggle LED from ON to OFF after 5E4 counts (Active-LOW)
		end 
		else begin
			counter <= counter + 1;			// Continue incrementing counter for next toggle
		end
	end
	
	// select and notselect represent the right and left side of the dual 7-segment display, respectively
	// (avoided "state" variable to avoid confusion with fsm)
	assign select = ON_OFF;
	assign notselect = ~ON_OFF;	
	
	// Synchronizer (to sync human input w/ clk and align input timing before FSM)
	logic [3:0] async_in; 		// Asynchronous column input signal to synchronizer 
	logic [3:0] sync_out;		// Synchronous column output signal from synchronizer
	
	always @(posedge ON_OFF or negedge reset) begin	// async reset goes through on negedge for active-LOW
		if (!reset) begin
			async_in <= 4'b1111;
			sync_out <= 4'b1111;
		end else begin
			async_in <= col;
			sync_out <= async_in;	// Holds synchronized [3:0] col input for the fsm
		end
	end
	
	// Instantiate keypad_fsm
	logic valid;
	logic [3:0] key_value;
	
	keypad_fsm kf (
		.clk(ON_OFF), 				// ON_OFF holds the divided clk signal
		.reset(reset), 	
		.col(sync_out), 			// col = sync_out (4-bit row input with correctly sync-ed timing)
		.row(row), 
		.valid(valid), 
		.key_value(key_value)
	);
	
	// Number shifter to update display for new numbers
	logic [3:0] left_digit;				// Register is used to hold [3:0]s
	logic [3:0] right_digit;			// Having issues using "logic" type 

	always @(posedge ON_OFF or negedge reset) begin
		if (!reset) begin 
			left_digit <= 4'b0000;		// Sets the 3-bit diplay code in "s" to show 0
			right_digit <= 4'b0000;
		end 
		else if (valid) begin			// No else since if not reset or not a valid press, nothing should happen on the display
			left_digit <= right_digit;
			right_digit <= key_value;
		end
	end	
	
	// Instantiate sevensegment
	logic [3:0] s;
	
	assign s = (ON_OFF) ? right_digit : left_digit;
	
	sevensegment sevenseg (s, seg);
	
endmodule
