// This module controls the bird by mic input
/* Inputs:
            clk - system clock
            reset - resets the game
            readdata_left - left channel mic input
            readdata_right - right channel mic input

    Outputs:
            LEDR - led light to indicate mic volume
            fly - signal to fly the bird
*/
module voiceControl(clk, reset, readdata_left, readdata_right, LEDR, fly);
    input logic clk, reset;
    input logic signed [23:0] readdata_left, readdata_right;
    output logic LEDR;
    output logic fly;

    // enable high for 1 cycle every second
    logic enable;
    birdCounter #(2**20-1) en(clk, reset, enable);
	 
	 // abs of readdata
	 logic [23:0] abs_left, abs_right;
	 always_ff @(posedge clk) begin
		// abs_left <= readdata_left[23] ? 0-readdata_left : readdata_left;
		// abs_right <= readdata_right[23] ? 0-readdata_right : readdata_right;
        if (readdata_left[23])
            abs_left <= 0-readdata_left;
        else 
            abs_left <= readdata_left;

        if (readdata_right[23])
            abs_right <= 0-readdata_right;
        else 
            abs_right <= readdata_right;    
	 end

   always_ff @(posedge clk) begin  
        if (abs_right > 24'd10000) begin 
            LEDR <=  1'b1;
				fly <= 1;
		  end // if
        else begin
            LEDR <=  1'b0;
				fly = 0;
		  end // else		  
    end // always_ff 
    
endmodule // voiceControl

// testbench
module voiceControl_testbench();
    logic clk, reset;
    logic signed [23:0] readdata_left, readdata_right;
    logic [9:0] LEDR;
    logic fly;

    voiceControl dut(.*);

    // Set up the clock.
	 parameter CLOCK_PERIOD=100;
	 initial begin
		 clk <= 0;
		 forever #(CLOCK_PERIOD/2) clk <= ~clk;
	 end

	 // Set up the inputs to the design. Each line is a clock cycle.
	 initial begin			
		reset = 1;										                                        @(posedge clk);
        reset = 0;  readdata_left = 0-23'd111; readdata_right = 23'd111;                         @(posedge clk);
                                                                                                @(posedge clk);
                                                                                                @(posedge clk);
                                                                                                @(posedge clk);
                                                                                                @(posedge clk);
						
		
		$stop; // End the simulation.
	 end
endmodule //testbench 