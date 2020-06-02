/* this module uses an averaging Finite Impluse Response (FIR) filter 
   to process and filter out input noise

   Inputs:
            clk - 50MHz system clock
            reset - resets the filter by pausing data flow when asserted

   Outputs:
            dataIn - 24bit signed input sound signal
            dataOut - 24bit signed output filtered signal
*/

module noise_filter (clk, reset, dataIn, dataOut);
    input logic clk, reset;
    input logic signed [23:0] dataIn;
    output logic signed [23:0] dataOut;

    logic signed [23:0] f0, f1, f2, f3, f4, f5, f6, f7;
    logic signed [23:0] q0, q1, q2, q3, q4, q5, q6, q7;
	 
	 //reg_24 reg0 (clk, reset, dataIn, q0);
    assign f0 = dataIn >>> 3;

    // reg 1 shift assignment 
    reg_24 reg1 (clk, reset, dataIn, q1);
    assign f1 = q1 >>> 3;
    
    // reg 2 shift assignment 
    reg_24 reg2 (clk, reset, q1, q2);
    assign f2 = q2 >>> 3;

    // reg 3 shift assignment 
    reg_24 reg3 (clk, reset, q2, q3);
    assign f3 = q3 >>> 3;

    // reg 4 shift assignment 
    reg_24 reg4 (clk, reset, q3, q4);
    assign f4 = q4 >>> 3;

    // reg 5 shift assignment 
    reg_24 reg5 (clk, reset, q4, q5);
    assign f5 = q5 >>> 3;

    // reg 6 shift assignment 
    reg_24 reg6 (clk, reset, q5, q6);
    assign f6 = q6 >>> 3;

    // reg 7 shift assignment 
    reg_24 reg7 (clk, reset, q6, q7);
    assign f7 = q7 >>> 3;

    // output assignment 
    assign dataOut = f0 + f1 + f2 + f3 + f4 + f5 + f6 + f7;
endmodule

// testbench
module noise_filter_testbench();
    logic clk, reset, enable;
    logic signed [23:0] dataIn, dataOut;

    noise_filter dut (.*);

    // Set up the clock.
	 parameter CLOCK_PERIOD=100;
	 initial begin
		 clk <= 0;
		 forever #(CLOCK_PERIOD>>> 3) clk <= ~clk;
	 end

	 // Set up the inputs to the design. Each line is a clock cycle.
	 initial begin	
				dataIn = 24'd8;		enable = 1;								@(posedge clk);
            dataIn = 0-24'd16;										@(posedge clk);
            dataIn = 24'd24;										@(posedge clk);
            dataIn = 0-24'd32;										@(posedge clk);
            dataIn = 24'd40;										@(posedge clk);
            dataIn = 0-24'd48;										@(posedge clk);
            dataIn = 24'd56;										@(posedge clk);
            dataIn = 0-24'd64;										@(posedge clk);
            dataIn = 24'd72;										@(posedge clk);
            dataIn = 0-24'd80;										@(posedge clk);
            dataIn = 24'd88;										@(posedge clk);
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
endmodule //testbench 