// bird counter
module birdCounter #(parameter LENGTH=500)(clk, reset, enable);
	input logic clk, reset;
	output logic enable;
	logic [60:0] count;
	
	always_comb begin 
		if (count > LENGTH)
			enable = 1;
		else 
			enable = 0;
	end 
	
	always_ff @(posedge clk) begin
		if (reset | count > LENGTH)
			count <= 0;
		else 
			count <= count + 1;
	end
	
endmodule

module birdCounter_testbench();
	logic clk, reset;
	logic enable;
	
	birdCounter #(.LENGTH(20)) dut(clk, reset, enable);
	
	// Set up the clock.
	 parameter CLOCK_PERIOD=100;
	 initial begin
		 clk <= 0;
		 forever #(CLOCK_PERIOD/2) clk <= ~clk;
	 end

	 // Set up the inputs to the design. Each line is a clock cycle.
	 initial begin	
			reset = 1;							@(posedge clk); // cycle 1 							
			reset = 0;							@(posedge clk);
													@(posedge clk); // cycle 3
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk); // cycle 8
													@(posedge clk); 
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk); // cycle 13
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk); // cycle 18
													@(posedge clk); // cycle 19
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk); // cycle 24
													@(posedge clk); // cycle 1 							
													
		 $stop; // End the simulation.
	 end
endmodule 