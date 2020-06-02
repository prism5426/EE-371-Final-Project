// this module is a 24-bit register
module reg_24 (clk, reset, d, q);
    input logic clk, reset;
    input logic [23:0] d;
    output logic [23:0] q;

    always_ff @(posedge clk) begin
        q <= d;
    end
endmodule 

// testbench
module reg_24_testbench();
    logic clk, reset;
    logic [23:0] d, q;

    reg_24 dut (.*);

    // Set up the clock.
	 parameter CLOCK_PERIOD=100;
	 initial begin
		 clk <= 0;
		 forever #(CLOCK_PERIOD/2) clk <= ~clk;
	 end

	 // Set up the inputs to the design. Each line is a clock cycle.
	 initial begin			
			d = 24'd8;										@(posedge clk);
            d = 24'd100;                                    @(posedge clk);
                                                            @(posedge clk);
											
						
		
		$stop; // End the simulation.
	 end
endmodule //testbench