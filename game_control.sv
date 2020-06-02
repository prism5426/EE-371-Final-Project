module game_control(clk, resetGame, press, 
				  birdfinish, pipefinish, gameover, 
				  update_bird, update_pipe,
				  x, y, r, g, b);
	input logic clk, resetGame, press;
	input logic birdfinish, pipefinish, gameover; // status signal
	output logic update_bird, update_pipe;        // control signal
    input logic [9:0] x;
    input logic [8:0] y;
    output logic [7:0] r, g, b;
	enum {s_start, s_bird, s_pipe, s_logic, s_done} ps, ns;
	
	always_ff@(posedge clk) begin
		if(resetGame)
			ps <= s_start;
		else 
			ps <= ns;
	end
	
	always_comb begin
		case(ps)
			s_start: ns = press ? s_bird : s_start;
			s_bird : ns = birdfinish ? s_pipe : s_bird;
			s_pipe : ns = pipefinish ? s_logic : s_pipe;
			s_logic: ns = gameover ? s_done : s_bird;
			s_done : ns = press ? s_done : s_start;
		endcase
	end
	
	assign update_bird = (ps == s_bird);
	assign update_pipe = (ps == s_pipe);
	

endmodule
