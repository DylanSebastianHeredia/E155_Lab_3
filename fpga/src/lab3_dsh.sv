// Sebastian Heredia
// dheredia@g.hmc.edu
// September 16, 2025

// lab3_dsh.sv contains code to instantiate the modules required to register asynchronous keypad button presses
// and output the correct hexadecimal number on a dual 7-segment display. 

module lab3_dsh ( 
	input logic			  	  reset,
	input logic 		[3:0] col, 
	output logic		[3:0] row,
	output logic 		  	  select,
	output logic 		  	  notselect,
	output logic		[6:0] seg
	// output logic 		  led
	);
	
	// Instantiate toggle
	logic clk;
	
	toggle clock (reset, clk);
	
	// Instantiate synchronizer
	logic [3:0] col_sync;
	
	synchronizer sync (clk, reset, col, col_sync);
	
	// Instantiate kpad_fsm
	logic [3:0] row_pressed;
	logic enable;
	
	kpad_fsm fsm (clk, reset, col_sync, row, row_pressed, enable);
	
	// Instantiate kpad_decoder
	logic [3:0] s1;
	logic [3:0] s2;
	
	kpad_decoder decoder (clk, reset, col_sync, row_pressed, enable, s1, s2);
	
	// Instantiate input_mux
	logic [3:0] s;
	
	input_mux multiplexer (clk, reset, s1, s2, select, notselect, s);
	
	// Instatiate sevensegment
	sevensegment sevenseg (s, seg);
	
endmodule 
