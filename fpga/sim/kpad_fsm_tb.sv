// fsm testbench
// dheredia@g.hmc.edu


module kpad_fsm_tb();
	
	logic clk;
	logic reset;
	logic [3:0] col;
	logic [3:0] row;
	logic [3:0] row_pressed;
	logic enable;
	// logic [3:0] led;
	
	// Instantiate synchronizer
	logic [3:0] col_sync;

	synchronizer sync (clk, reset, col, col_sync);

	// Instantiate kpad_fsm
	kpad_fsm fsm (clk, reset, col, row, row_pressed, enable);

	always begin
		clk = 0; #5;
		clk = 1; #5;
	end

	initial begin
		col = 4'b0000; 			
		reset = 0; #10;
		reset = 1; #10;
		reset = 0; #10;
		reset = 1; #10;
		#60;

		col = 4'b0001; #10; 
		col = 4'b0000; #35;		// Not on rising clk edge
		col = 4'b0001; #10;
		col = 4'b0000; #40;		
		col = 4'b0110; #10;		// Two simultaneous key presses in different columns
		col = 4'b0000; #55;
		col = 4'b0100; #10;
		col = 4'b0000; #55;
		col = 4'b1000; #10;		
		col = 4'b1000; #65;		// Sending repeat signal
		col = 4'b0000;
	end

	
endmodule
