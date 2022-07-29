`timescale 1ns / 1ns
module PC(
	input 				clk,
	input 				en,
	input 				reset,
	input [31:0]		next,
	output reg [31:0]	IAddr = 32'h00003000
);
    always @(posedge clk) begin
	    if(reset) begin
			IAddr <= 32'h00003000;
		end
		else if(en) begin
			IAddr <= next;
		end
	end
endmodule
