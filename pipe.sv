/*  Pipe module, draws the pipe from the right of the screen to the left. It will randomly
	choose from 8 different pipe opening position. The pipe will move left 2 pixel each pixel.
	input:
		clk 		- clock input
		resetGame 	- reset 
		updatepipe 	- signal to start drawing the pipe, will not start until pipefinish is asserted
		x 			- x position of current pixel
		y 			- y position of current pixel
		
	output:
		pipefinish 	- status signal that signals the pipe is finished updating and new pipe is avaliable
		r 			- red value ranging from [0-255]
		g 			- green value ranging from [0-255]
		b 			- blue value ranging from [0-255]
		addscore 	- status signal that indicates to addscore
*/
module pipe(clk, resetGame, updatepipe, pipefinish, x, y, r, g, b, addscore);
	input logic clk, resetGame;
	input logic updatepipe;
    input logic [9:0] x;
    input logic [8:0] y;
    output logic [7:0] r, g, b;
	output logic pipefinish;
	output logic addscore;
	enum {start, idle, waitforvideo, update, done}ps, ns;
	
	logic [9:0] count, out;
	logic resetLFSR;
	
	LFSR randm(clk, resetLFSR, out, random);
	
	// FSM next 
	always_ff@(posedge clk) begin
		if(resetGame) 
			ps <= start;
		else
			ps <= ns;
	end
	
	assign resetLFSR = (ps == start); // reset the LFSR as soon as the module is created
	
	// FSM next state assignment
	always_comb begin
		case(ps)
			start: ns = idle;
			idle: ns = updatepipe ? waitforvideo : idle; // stays at idle until updatepipe signal is asserted
			waitforvideo: ns = (x == 10'd639 & y == 9'd479) ? update : waitforvideo; // wait for the pixel to reach bottom left for a fresh start 
			update: ns = (count == 10'd0) ? done : update;/
			done: ns = updatepipe ? done : idle;// stays at update until updatepipe signal is de-asserted
		endcase
	end

	// choose from 8 predetermined pipe opening position using LFSR output and draw each pixel
	always_ff@(posedge clk) begin
		if(ps == update) begin
			r <= 8'd0;
			b <= 8'd0;
			if(x >= count & x <= count + 10'd30)
				if(out < 10'd128) begin
					if(y > 9'd30 & y < 9'd30 + 9'd100)
						g <= 0;
					else 
						g <= 8'd255;
				end else if(out < 10'd256) begin
					if(y > 9'd70 & y < 9'd70 + 9'd100)
						g <= 0;
					else 
						g <= 8'd255;
				end else if(out < 10'd384) begin
					if(y > 9'd110 & y < 9'd110 + 9'd100)
						g <= 0;
					else 
						g <= 8'd255;
				end else if(out < 10'd512) begin
					if(y > 9'd150 & y < 9'd150 + 9'd100)
						g <= 0;
					else 
						g <= 8'd255;
				end else if(out < 10'd640) begin
					if(y > 9'd190 & y < 9'd190 + 9'd100)
						g <= 0;
					else 
						g <= 8'd255;
				end else if(out < 10'd768) begin
					if(y > 9'd230 & y < 9'd230 + 9'd100)
						g <= 0;
					else 
						g <= 8'd255;
				end else if(out < 10'd896) begin
					if(y > 9'd270 & y < 9'd270 + 9'd100)
						g <= 0;
					else 
						g <= 8'd255;
				end else begin
					if(y > 9'd310 & y < 9'd310 + 9'd100)
						g <= 0;
					else 
						g <= 8'd255;
			end else 
				g <= 8'd0;
		end else begin
			r <= 8'd0;
			b <= 8'd0;
			g <= 8'd0;
		end

		if(resetGame | ps != update)
			count = 10'd600;
		else if((ps == update) & (x ==10'd639 & y == 9'd479)) 
			count= count - 10'd2; // move left two pixel
	end

	// status signal
	assign random = (ps == idle);
	assign pipefinish = (ps == done | ps == idle);
	assign addscore = (ps == update) & (count == 170);
endmodule


module pipe_testbench();
	logic clk, resetGame, addscore;
	logic updatepipe;
    logic [9:0] x;
    logic [8:0] y;
    logic [7:0] r, g, b;
	logic pipefinish;
	enum {idle, update, done}ps, ns;
	
	logic [9:0] count;
	
	pipe dut(.*);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	integer i, j,k;
	initial begin
												@(posedge clk);
		resetGame <= 1; 						@(posedge clk);
		resetGame <= 0; updatepipe <= 0; x <= 0; y <= 0;	@(posedge clk);
												@(posedge clk);
												@(posedge clk);
												@(posedge clk);
						 	@(posedge clk);
		updatepipe <= 1; 						@(posedge clk);
												@(posedge clk);
							@(posedge clk);
							
		for (k = 0; k < 3; k++)begin
			for (i = 0; i <= 681; i++) begin
				for (j = 0; j <= 481; j++) begin
					@(posedge clk) x <= i; y <= j;
				
				end
			end		
		end
						
							$stop; // End the simulation.
	 end


endmodule
