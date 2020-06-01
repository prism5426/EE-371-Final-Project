// output: detect a user input, press is 1, release is 0
module user_in (clk, KEY, press);
	input logic clk, KEY;
	output logic press;
	
	logic ps;
	
	// DFF
	always_ff @(posedge clk) begin
		ps <= KEY;
	end
	
	assign press = ~ps;
endmodule

module user_in_testbench();
	logic clk, KEY;
	logic press;
	
	user_in dut(clk, KEY, press);
	 
	 // Set up the clock.
	 parameter CLOCK_PERIOD=100;
	 initial begin
		 clk <= 0;
		 forever #(CLOCK_PERIOD/2) clk <= ~clk;
	 end

	 // Set up the inputs to the design. Each line is a clock cycle.
	 initial begin			
													@(posedge clk); // cycle 1 							
													@(posedge clk);
						 KEY <= 1; 				@(posedge clk); // cycle 3
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
						 KEY <= 0;				@(posedge clk); // cycle 8
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
						 KEY <= 1;				@(posedge clk); // cycle 13
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk); // cycle 18
						 KEY <= 0;				@(posedge clk); // cycle 19
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk); // cycle 24
		 $stop; // End the simulation.
	 end
endmodule 