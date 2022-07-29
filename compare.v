`timescale 1ns / 1ns
module compare(
	input [31:0]	c1,
	input [31:0]	c2,
	input [2:0]		sel,
	output reg 		true
);
// 比较器
    always @(*) begin
	    case(sel)
		    0 : begin
				true = c1 == c2; // 等于判断
			end
			1 : begin 
				true = c1 != c2;  // 不等于判断
			end
			2 : begin 
				true = c1 == 0 || c1[31];  // c1 <= 0
			end
			3 : begin
				 true = c1 != 0 && ~c1[31];  // c1 > 0
			end
			4 : begin 
				true = c1[31];  // c1 < 0
			end
			5 : begin 
				true = ~c1[31];  // c1 >= 0
			end
		endcase
	end
endmodule
