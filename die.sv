// this module detects is the bird dies
module die(clk, reset, x, gp, gb, die, LEDR);
    input logic clk, reset;
    input logic [9:0] x;
 //   input logic [8:0] y;
    input logic [7:0] gp, gb;
	output logic die, LEDR;

    // possible states
    enum {alive, dead} ps, ns;

    always_comb begin
        case (ps)
            alive: if (x >= 10'd200 & x <= 10'd231 & gp == gb & gp == 8'd255) // green is 255 in both bird and pipe if bird hits pipe
                        ns = dead;
                   else 
                        ns = alive;
            dead:   if (reset)
                     ns = alive;
                   else 
                     ns = dead;   
            
        endcase
    end // always_comb

    always_ff @(posedge clk) begin
        if (reset)
            ps <= alive;
        else 
            ps <= ns;
    end

    assign die = (ps == dead);
    assign LEDR = die; 
     
endmodule // die
	 
// testbench
module die_testbench();
    logic clk, reset;
    logic [9:0] x;
    logic [8:0] y;
    logic [7:0] gp, gb;
    logic die, LEDR;

    die dut(.*);

    // Set up the clock.
	 parameter CLOCK_PERIOD=100;
	 initial begin
		 clk <= 0;
		 forever #(CLOCK_PERIOD/2) clk <= ~clk;
	 end

	 // Set up the inputs to the design. Each line is a clock cycle.
	 initial begin			
			reset = 1;										@(posedge clk);
            reset = 0;    x = 200; gp = 8'd0; gb = 8'd0;    @(posedge clk);
                          x = 211; gp = 8'd0; gb = 8'd255;  @(posedge clk);
                          x = 221; gp = 8'd255; gb = 8'd255;@(posedge clk);
                                                            @(posedge clk);
                                                            @(posedge clk);
						
		
		$stop; // End the simulation.
	 end
endmodule //testbench 

