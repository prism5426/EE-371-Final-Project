module pipe(clk, resetGame, updatepipe, pipefinish, x, y, r, g, b);
	input logic clk, resetGame;
	input logic updatepipe;
    input logic [9:0] x;
    input logic [8:0] y;
    output logic [7:0] r, g, b;
	output logic pipefinish;
	enum {idle, waitforvideo, update, done}ps, ns;
	
	logic [9:0] count, out;
	
	LFSR randm(clk, resetGame, out, random);
	
	always_ff@(posedge clk) begin
		if(resetGame) 
			ps <= idle;
		else
			ps <= ns;
	end
	
	
	always_comb begin
		case(ps)
			idle: ns = updatepipe ? waitforvideo : idle;
			waitforvideo: ns = (x ==10'd639 & y == 9'd479) ? update : waitforvideo;
//			update: ns = (x ==10'd640 & y == 9'd480) ? done : update;
			update: ns = done;
			done: ns = updatepipe ? done : idle;
		endcase
	end
	
	assign pipefinish = (ps == done);
	
	always_ff@(posedge clk) begin
		r = 8'd0;
		b = 8'd0;
		if(x >= count & x <= count + 10'd30)
			if(out < 10'd256) begin
				if(y > 9'd100 & y < 9'd100 + 9'd100)
					g = 0;
				else 
					g = 8'd255;
			end else if(out < 10'd512) begin
				if(y > 9'd175 & y < 9'd175 + 9'd100)
					g = 0;
				else 
					g = 8'd255;
			end else if(out < 10'd768) begin
				if(y > 9'd250 & y < 9'd250 + 9'd100)
					g = 0;
				else 
					 g = 8'd255;
			end else begin
				if(y > 9'd325 & y < 9'd325 + 9'd100)
					g = 0;
				else 
					g = 8'd255;
		end else 
			g = 8'd0;
		
		if(resetGame)
			count = 10'd600;
		else if(ps == update) begin
			if(count == 10'd0) begin
				random = 1;
				count = 10'd600;
			end
			else begin
				count= count - 10'd10;
				random = 0;
			end
		end
	end
	
endmodule


module pipe_testbench();
	logic clk, resetGame;
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
