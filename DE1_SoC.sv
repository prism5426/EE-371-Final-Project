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
	logic start;
	assign start = SW[0];

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

/*	always_ff @(posedge CLOCK_50) begin
		r <= 8'd65;
		g <= 8'd105;
		b <= 8'd225;
	end */

	logic [7:0] rb, gb, bb;
	logic [7:0] rp, gp, bp;
	always_ff @(posedge CLOCK_50) begin
		r = rb | rp;
		g = gb | gp;
		b = bb | bp;

	end

	bird bd(CLOCK_25, resetGame, press, x, y, rb, gb, bb);
	pipe pi(CLOCK_25, resetGame, clk[20], pipefinish, x, y, rp, gp, bp);

	assign LEDR[0] = clk[20];
	assign LEDR[1] = press;

	//game_control gc(CLOCK_25, resetGame, press, birdfinish, pipefinish, gameover, update_bird, update_pipe);
	//game_logic   gl(CLOCK_25, resetGame, press, gameover, birdy, pipex, pipey, pipe_len);


	// bird module
	logic in;
	assign in = SW[0]? fly : press;
	bird bd(CLOCK_25, resetGame, in, x, y, r, g, b);

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

	logic fly;
	// voice control module
	 voiceControl vc(CLOCK_50, resetGame, writedata_left, writedata_right, LEDR, fly);
	// voiceControl vc(CLOCK_50, resetGame, readdata_left, readdata_right, LEDR, fly);

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

	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;

endmodule
