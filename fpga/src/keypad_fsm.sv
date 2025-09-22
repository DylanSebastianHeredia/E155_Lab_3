// E155: Lab 3 - Keypad Scanner
// Sebastian Heredia, dheredia@g.hmc.edu
// September 16, 2025
// keypad_fsm.sv contains code to scan the rows of the keypad, debounce button presses, and ensure that
// the output is a single key press at a time. 

module keypad_fsm (
        input logic        clk,
        input logic        reset,          // Intentionally Active-LOW
        input logic  [3:0] col,            // Recall: Active-LOW
        output logic [3:0] row,            // Recall: Active-LOW
        output logic       valid,          // HIGH when a key is pressed
        output logic [3:0] key_value       // Hexadecimal value of the pressed key
    );

    // FSM state encoding
    typedef enum logic [3:0] {
        S0, S0_PRESS, S0_WAIT, 
        S1, S1_PRESS, S1_WAIT,
        S2, S2_PRESS, S2_WAIT,
        S3, S3_PRESS, S3_WAIT
    } state_t;

    state_t state, next_state;

    // Internal logic variable for which row is driven (Active-LOW)
    logic [3:0] active_row; // For each row
    assign row = active_row;
    
    // pb flags when a push button (pb) is pressed
    logic pb;    
    assign pb = (col != 4'b1111);  		// If col is activated (0), set pb = 1
										// Note: When rows are LOW and a button is pressed, the corresponding column goes LOW

    logic pb_debounced;            		// Stores the stable, debounced pb value! Signals that pb was ACTUALLY pressed and registers as ONE signal
    
    logic [15:0] debounce_count;     	// Create counter for ~1ms debounce at 48 MHz (UPDATE)

    // Debounce logic with active-LOW reset
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin          		// active-LOW reset
            debounce_count  <= 0;    
            pb_debounced    <= 0;
        end 
		
		else begin
            if (pb == pb_debounced)
                debounce_count <= 0;  	// Stable now, reset counter
            
			else begin
                debounce_count <= debounce_count + 1;	// Increase wait time until signal stabilizes
				
                if (debounce_count == 16'hFFFF) begin	// All bits are HIGH
                    pb_debounced <= pb; 				// Accept stabilized value
                    debounce_count <= 0;
                end
            end
			
        end
    end

    // Instantiate keypad_decoder.sv
    logic [3:0] s;
    keypad_decoder kd (row, col, s);

    // State register with active-LOW reset
    always_ff @(posedge clk or negedge reset) begin
        if (!reset)
            state <= S0;
        else
            state <= next_state;
    end

    // Next-state logic
    always_comb begin
        next_state = state;
        case (state)
			// If pb_debounce is HIGH (1), then next_state = SX_PRESS state! 
            S0:       next_state = pb_debounced ? S0_PRESS : S1; // row0
            S0_PRESS: next_state = pb_debounced ? S0_PRESS : S0_WAIT;
            S0_WAIT:  next_state = pb_debounced ? S0_PRESS : S1;

            S1:       next_state = pb_debounced ? S1_PRESS : S2; // row1
            S1_PRESS: next_state = pb_debounced ? S1_PRESS : S1_WAIT;
            S1_WAIT:  next_state = pb_debounced ? S1_PRESS : S2;

            S2:       next_state = pb_debounced ? S2_PRESS : S3; // row2
            S2_PRESS: next_state = pb_debounced ? S2_PRESS : S2_WAIT;
            S2_WAIT:  next_state = pb_debounced ? S2_PRESS : S3;

            S3:       next_state = pb_debounced ? S3_PRESS : S0; // row3
            S3_PRESS: next_state = pb_debounced ? S3_PRESS : S3_WAIT;
            S3_WAIT:  next_state = pb_debounced ? S3_PRESS : S0;

            default:  next_state = S0;
        endcase
    end

    // Logic to drive each row active-LOW (0)
    always_comb begin
        active_row = 4'b1111; 	// Start with all rows inactive (HIGH)
        valid = 0;				// Initially 0 since no pb has been pressed 

        case(state)				// If in any state, set each row active-LOW (0) one at a time
            S0, S0_PRESS, S0_WAIT: active_row = 4'b1110; // row0
            S1, S1_PRESS, S1_WAIT: active_row = 4'b1101; // row1
            S2, S2_PRESS, S2_WAIT: active_row = 4'b1011; // row2
            S3, S3_PRESS, S3_WAIT: active_row = 4'b0111; // row3
        endcase

        // Check if keypad press is valid by checking if we are in the PRESS state for a given row
        if ((state == S0_PRESS) || (state == S1_PRESS) || (state == S2_PRESS) || (state == S3_PRESS))
            valid = 1;
    end 

    // Capture the specific keypad number value with active-LOW reset
    always_ff @(posedge clk or negedge reset) begin
        if (!reset)
            key_value <= 4'b0000;
        else if (valid)
            key_value <= s; // valid gets the encoding for the keypad push button (pb) hexadecimal number
    end

endmodule
