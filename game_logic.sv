module game_logic(clk, resetGame, press, gameover, birdy, pipex, pipey, pipe_len);
	input logic clk, resetGame, press;
    input logic [9:0] pipex;
	input logic [8:0] pipe_len;
	input logic [8:0] birdy, pipey;
	output logic gameover;
	
	always_comb begin
		// if(birdy) collision logic
	
	end
	
	assign gameover = 0; // temporary

endmodule
