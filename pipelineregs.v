`timescale 1ns / 1ns
module preg1(
	input 		clk,
	input 		en,
	input 		reset,
	input 		in,
	output reg  out = 0
);
    always @(posedge clk) begin
	    if(reset) begin 
			out = 0;
		end
		else if(en) begin 
			out = in;
		end
	end
endmodule

module preg5(
	input 		clk,
	input 		en,
	input 		reset,
	input [4:0] in,
	output reg [4:0] out = 0
);
    always @(posedge clk) begin
	    if(reset) begin 
			out = 0;
		end
		else if(en) begin 
			out = in;
		end
	end
endmodule

module preg32(
	input 		clk,
	input 		en,
	input 		reset,
	input [31:0] in,
	output reg [31:0] out = 0
);
    always @(posedge clk) begin
	    if(reset) begin 
			out = 0;
		end
		else if(en) begin 
			out = in;
		end
	end
endmodule
