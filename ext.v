`timescale 1ns / 1ns
module ext(
	input [15:0]	imm,
	input [1:0]		EOp,
	output [31:0]	ext
);
    reg [31:0]out;
	 	always @(*) begin
	     	case(EOp)
		      	0 : begin
					out = {{16{imm[15]}}, imm};
				end
				1 : begin 
					out = {16'h0000, imm};
				end
				2 : begin
					out = {imm, 16'h0000};
				end
				3 : begin 
					out = {{14{imm[15]}}, imm, 2'b00};
				end
		  	endcase
	 	end

	assign ext = out;
endmodule

module extbyte(
	input [7:0]	imm,
	input 		EOp,
	output [31:0] ext
);
	assign ext = EOp ? {24'b0, imm} : {{24{imm[7]}}, imm};
endmodule
