module LFSR(clk, reset, out, enable);
	input logic clk, reset, enable;
	output logic [9:0] out;
	logic Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10;
	
	
	DFFs dff1 (clk, reset, Q7 ^~ Q10, Q1);
	DFFs dff2 (clk, reset, Q1, Q2);
	DFFs dff3 (clk, reset, Q2, Q3);
	DFFs dff4 (clk, reset, Q3, Q4);
	DFFs dff5 (clk, reset, Q4, Q5);
	DFFs dff6 (clk, reset, Q5, Q6);
	DFFs dff7 (clk, reset, Q6, Q7);
	DFFs dff8 (clk, reset, Q7, Q8);
	DFFs dff9 (clk, reset, Q8, Q9);
	DFFs dff10 (clk, reset, Q9, Q10);
	

	always_ff @(posedge clk) begin
		if(enable)
			out <= {Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10};
	end
	
endmodule


module LFSR_testbench();
	logic clk, reset;
	logic [9:0] out;
	logic Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10;
	
	
		LFSR dut(.clk, .reset, .out);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	initial begin
												@(posedge clk);
		 reset <= 1; 						@(posedge clk);
		 reset <= 0; 	@(posedge clk);
												@(posedge clk);
												@(posedge clk);
												@(posedge clk);
						 	@(posedge clk);
												@(posedge clk);
												@(posedge clk);
							@(posedge clk);
												@(posedge clk);
												@(posedge clk);
							@(posedge clk);
												@(posedge clk);
						@(posedge clk);
												@(posedge clk);
							@(posedge clk);
							@(posedge clk);
						@(posedge clk);
												@(posedge clk);
												@(posedge clk);
							@(posedge clk);
												@(posedge clk);
												@(posedge clk);
							@(posedge clk);
												@(posedge clk);
							@(posedge clk);
												@(posedge clk);
							@(posedge clk);
							@(posedge clk);
		  						@(posedge clk);
		  	@(posedge clk);
												@(posedge clk);
												@(posedge clk);
												@(posedge clk);
						 	@(posedge clk);
												@(posedge clk);
												@(posedge clk);
							@(posedge clk);
												@(posedge clk);
												@(posedge clk);
							@(posedge clk);
												@(posedge clk);
							@(posedge clk);
												@(posedge clk);
							@(posedge clk);
							@(posedge clk);
						 	@(posedge clk);
												@(posedge clk);
												@(posedge clk);
							@(posedge clk);
												@(posedge clk);
												@(posedge clk);
							@(posedge clk);
												@(posedge clk);
							@(posedge clk);
							@(posedge clk);
							@(posedge clk);
						
							$stop; // End the simulation.
	 end

endmodule
