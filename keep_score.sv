module keep_score(clk, reset, addscore,HEX2, HEX1, HEX0);
	input logic clk, reset, addscore;
	output logic [6:0] HEX2, HEX1, HEX0;
	enum{start, idle, update, done}ps,ns;
	
	logic [9:0] count;
	
	always_ff @(posedge clk) begin
		if(reset) 
			ps <= start;
		else
			ps <= ns;
	end
	
	
	always_comb begin
		case(ps)
			start: ns <= idle;
			idle: ns <= addscore ? update : idle;
			update: ns <=  done;
			done: ns <= addscore ? done : idle;
		endcase
	end

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
