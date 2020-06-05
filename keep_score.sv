/*  keep_score module that connects to three 7 segment display.
	input:
		clk 	 - clock signal
		reset 	 - reset signal, reset the score to 0
		addscore - signal that tells the module to increment score
	output:
		HEX2 	 - third digit of the HEX display
		HEX1 	 - second digit of the HEX display
		HEX0 	 - first digit of the HEX display
*/
module keep_score(clk, reset, addscore,HEX2, HEX1, HEX0);
	input logic clk, reset, addscore;
	output logic [6:0] HEX2, HEX1, HEX0;
	enum{start, idle, update, done}ps,ns;
	
	logic [9:0] count;
	
	// FSM state update
	always_ff @(posedge clk) begin
		if(reset) 
			ps <= start;
		else
			ps <= ns;
	end
	
	// Next state assignment
	always_comb begin
		case(ps)
			start: ns <= idle;
			idle: ns <= addscore ? update : idle;
			update: ns <=  done;
			done: ns <= addscore ? done : idle;
		endcase
	end

	// condition for changing the count
	always_ff @(posedge clk) begin
		if(ps == start)
			count <= 0;
		else if(ps == update)
			count <= count + 1;
	end
	
	seg7 first (count % 10, HEX0);
	seg7 second((count/10) % 10, HEX1);
	seg7 third((count/100) % 10, HEX2);
endmodule
