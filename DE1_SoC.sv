module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW,
					 CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS, // VGA ports
					 CLOCK2_50,FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT); // audio ports

	// port delaration
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;

	input CLOCK_50, CLOCK2_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;

	// resets VGA
	logic reset;
	assign reset = ~KEY[0];

	// resets game
	logic resetGame;
	assign resetGame = ~KEY[1];

	// start game
	// logic start;
	// assign start = SW[0];

	// user input
	logic press;
	user_in uIn(CLOCK_50, KEY[2], press);

	// coordinates and color
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;

	// VGA connection
	video_driver #(.WIDTH(640), .HEIGHT(480))
		v1 (.CLOCK_50, .reset, .x, .y, .r, .g, .b,
			 .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
			 .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);

	// clock divider
	logic [31:0] clk;
	logic CLOCK_25;

	 clock_divider divider (.clock(CLOCK_50), .divided_clocks(clk));

	 assign CLOCK_25 = clk[0]; // 25MHz clock

	logic [7:0] rb, gb, bb;
	logic [7:0] rp [3:0];
	logic [7:0] gp [3:0];
	logic [7:0] bp [3:0];


	//logic [7:0] rp, gp, bp;
	always_ff @(posedge CLOCK_50) begin
		r <= die? rDie : rb | rp[0] | rp[1] | rp[2] | rp[3];
		g <= die? gDie : gb | gp[0] | gp[1] | gp[2] | gp[3];
		b <= die? bDie : bb | bp[0] | bp[1] | bp[2] | bp[3];
	end
	
	// die module
	//assign LEDR[1] = press;		
	logic die;
	die d(CLOCK_50, resetGame, x, gp[0] | gp[1] | gp[2] | gp[3], gb, die, LEDR[1]);

	// die Display
	logic [7:0] rDie, gDie, bDie;
	dieDisplay dd(CLOCK_50, resetGame, die, x, y, rDie, gDie, bDie);

	// bird & pipe
	bird bd(CLOCK_25, resetGame, in, x, y, rb, gb, bb);

	genvar k;	
	generate	
		for (k = 0; k < 4; k++) begin : four_pipes	
			pipe pi(CLOCK_25, resetGame, pipefinish & count[k], pipefinish, x, y, rp[k], gp[k], bp[k]);	
		end	
	endgenerate	

	logic [3:0] count;	
	always_ff @(posedge clk[25]) begin	
		if(count == 4'b1000 | resetGame)	
			count <= 4'b0001;	
		else	
			count <= count << 1;	

	end

	logic in;
	assign in = SW[0]? fly : press;

	// noise filter logic
	logic signed [23:0] rl, rr;
	logic signed [23:0] wl, wr;

	// noise filter
	always @(posedge CLOCK_50) begin
		rl <= read_ready ? readdata_left : rl;
		rr <= read_ready ? readdata_right : rr;
		writedata_left <= write_ready ? wl : writedata_left;
		writedata_right <= write_ready ? wr : writedata_left;
	end // always_ff

	noise_filter nf_left (CLOCK_50, reset, rl, wl);
	noise_filter nf_right (CLOCK_50, reset, rr, wr);

	// voice control module
	logic fly;
	voiceControl vc(CLOCK_50, resetGame, writedata_left, writedata_right, LEDR[0], fly);

	// audio
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;

	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	wire [23:0] writedata_left, writedata_right;

	/* Your code goes here */

	// assign writedata_left = readdata_left;	//Your code goes here
	// assign writedata_right = readdata_right;	//Your code goes here
	assign read = read_ready;	//Your code goes here
	assign write = write_ready;	//Your code goes here

	clock_generator my_clock_gen(
		CLOCK2_50,
		reset,
		AUD_XCK
	);

	audio_and_video_config cfg(
		CLOCK_50,
		reset,
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		CLOCK_50,
		reset,
		read,
		write,
		writedata_left,
		writedata_right,
		AUD_ADCDAT,
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);

	//assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;

endmodule

module DE1_SoC_testbench ();
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;

	logic CLOCK_50, CLOCK2_50;
	logic [7:0] VGA_R;
	logic [7:0] VGA_G;
	logic [7:0] VGA_B;
	logic VGA_BLANK_N;
	logic VGA_CLK;
	logic VGA_HS;
	logic VGA_SYNC_N;
	logic VGA_VS;
	logic reset;
	logic in;
	logic resetGame;
	logic start;
	logic press;
	logic FPGA_I2C_SCLK;
	logic FPGA_I2C_SDAT;
	logic AUD_XCK;
	logic AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	logic AUD_ADCDAT;
	logic AUD_DACDAT;
	logic fly;
	logic [3:0] count;
	logic signed [23:0] rl, rr;
	logic signed [23:0] wl, wr;
	logic [7:0] rp, gp, bp [3:0];
	logic CLOCK_25;
	logic clk;
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;


	DE1_SoC dut(.*);

	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	assign CLOCK_25 = clk;
	assign in = 0;
	assign rb = 0;
	assign gb = 0;
	assign bb= 0;
	integer i, j,k;

	initial begin
		KEY[1] <= 0;	@(posedge clk);
		KEY[1] <= 1;				@(posedge clk);

		for (k = 0; k < 3; k++) begin
			for (i = 0; i <= 681; i++) begin
				for (j = 0; j <= 481; j++) begin
					@(posedge clk) x <= i; y <= j;

				end
			end
		end

							$stop; // End the simulation.
	end

endmodule
