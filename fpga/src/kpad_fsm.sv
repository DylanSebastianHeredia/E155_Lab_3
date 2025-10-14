// Sebastian Heredia
// dheredia@g.hmc.edu
// September 16, 2025

// kpad_fsm.sv contains code to ensure that keypad button presses function as intended. 

module kpad_fsm (
	input logic			  clk,
	input logic			  reset, 
	input logic		[3:0] col, 
	output logic	[3:0] row,
	output logic 	[3:0] row_pressed, 
	output logic 		  enable
	// output logic    [4:0] led
	);
	
	// State encoding
	typedef enum logic [4:0] {	// Sufficient bits to cover 20 states
		r0, r1, r2, r3,			// row
		p0, p1, p2, p3,			// press
		s0, s1, s2, s3,			// synced	(avoided S/s, too similar)
		e0, e1, e2, e3,			// enable
		w0, w1, w2, w3			// wait
	} state_t;
	
	state_t state, next_state;
	
	always_ff @(posedge clk, negedge reset) begin
		if (reset == 0) begin
			state <= r0;		// Verified by led[0] being lit when reset is activated
		end
		else begin
			state <= next_state;
		end
	end
	
	// Check that only 1 push button is active-HIGH
	logic press;
	assign press = col[0] ^ col[1] ^ col[2] ^ col[3];
	
	logic [3:0] first_col;

	always_ff @(posedge clk) begin
		if(reset == 0) begin
			first_col <= 4'b0000;
		end
		
		else if (enable) begin
			first_col <= col;
		end
	end
	
	logic oneCol;
	assign oneCol = (col & first_col) != 4'b0000;
	
	// LED debugging
	// assign led [3:0] = row;
	// assign led [4] = press;
	
	// Next-state logic
	always_comb
		case(state)
			// Check if row 0 is pressed
			r0: begin
					if (press == 1) next_state = p0; // if ($countones (col) == 1); 
					else next_state = r1;		
				end
			
			// Check row 1
			r1: begin
					if (press == 1) next_state = p1;
					else next_state = r2;
				end
				
			// Check row 2
			r2: begin
					if (press == 1) next_state = p2;
					else next_state = r3;
				end
	
			// Check row 3
			r3: begin
					if (press == 1) next_state = p3;
					else next_state = r0;
				end
			
			// Two counts behind to synchronize row logic with synchronized column logic
			
			// Row 0 pressed
			p2: next_state = s2;		// Always (catch asynchronous column signal)
			s2: next_state = e2; 		// Always (set sychronous column signal)
			e2: next_state = w2;		// Always (pulse enable after syncing)
			
			w2: begin
					if (oneCol) next_state = w2;
					else next_state = r2;
				end
				
			// Row 1 pressed
			p3: next_state = s3;
			s3: next_state = e3;
			e3: next_state = w3;
			
			w3: begin
					if (oneCol) next_state = w3;
					else next_state = r3;
				end
	
			// Row 2 pressed
			p0: next_state = s0;
			s0: next_state = e0;
			e0: next_state = w0;
			
			w0: begin
					if (oneCol) next_state = w0;
					else next_state = r0;
				end
			
			// Row 3 pressed
			p1: next_state = s1;
			s1: next_state = e1;
			e1: next_state = w1;
			
			w1: begin
					if (oneCol) next_state = w1;
					else next_state = r1;
				end
				
			default: next_state = r0;	// Default back to the idle row loop
		endcase
	
	// FSM output logic
	
	always_comb begin
		if 		((state == r0) || (state == p2) || (state == s2) || (state == e2) || (state == w2)) row = 4'b0100; 	// Offset encoding row encoding to account for offset column syncing
		else if ((state == r1) || (state == p3) || (state == s3) || (state == e3) || (state == w3)) row = 4'b1000;	
		else if ((state == r2) || (state == p0) || (state == s0) || (state == e0) || (state == w0)) row = 4'b0001;
		else if ((state == r3) || (state == p1) || (state == s1) || (state == e1) || (state == w1)) row = 4'b0010;
		else row = 4'b0001;
	end
	
	// row and row_pressed hold the same value, row_pressed is actually used to display numbers across the other modules
	assign row_pressed = row;
	
	assign enable = (state == e0) | (state == e1) | (state == e2) | (state == e3);	// If we are in any of the enable states, enable is activated (1)
	
endmodule
