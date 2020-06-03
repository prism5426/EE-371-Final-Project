module DFFs(clk, reset, in, out);
	input logic clk, reset, in;
	output logic out;
	

	always_ff @(posedge clk) begin
		if(reset)
			out <= 0;
		else
			out <= in;
	end
	

endmodule
