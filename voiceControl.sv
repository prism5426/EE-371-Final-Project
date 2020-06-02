// voice control module
module voiceControl(clk, reset, readdata_left, readdata_right, LEDR, fly);
    input logic clk, reset;
    input logic signed [23:0] readdata_left, readdata_right;
    output logic [9:0] LEDR;
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

    // sum of data in 1 second
    logic [23:0] sum;

    always_ff @(posedge clk) begin
        if (enable | reset) begin
            sum <= 0;
        end // if
        else begin  
            sum <= sum + abs_right + abs_left;
           // sum <= sum + readdata_left + readdata_right;
        end // else
    end // alawys_ff

    // average of data in 1 second
    logic [23:0] mean;
   always_ff @(posedge clk) begin  
         mean <= sum >>> 16; // log2(48,000) = 15.5
/*			if (enable)
				if (mean >= 31'd500) 
						 LEDR <= 10'b0000000001;
					else if (mean >= 31'd400) 
						 LEDR <= 10'b0000000010;
					else if (mean >= 31'd300)
						 LEDR <= 10'b0000000100;
					else if (mean >= 31'd200) 
						 LEDR <= 10'b0000001000;
					else if (mean >= 31'd100) 
						 LEDR <= 10'b0000010000;
					else if (mean >= 31'd0)
						 LEDR <= 10'b0000100000;
					else    
						 LEDR <= 10'b0001000000;  */
        if (abs_right > 24'd10000) begin 
            LEDR <=  10'b0000000001;
				fly <= 1;
		  end
        else begin
            LEDR <=  10'b0000000000;
				fly = 0;
		  end 
			  
    end // always_ff 

/*    enum {fly, fall} ps, ns;
    always_comb begin
        case (ps)
            fly:  if (mean)
            
        endcase
    end    */ 
    
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