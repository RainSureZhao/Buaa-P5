`timescale 1ns / 1ns
module ALU(
	input [31:0]op1,
	input [31:0]op2,
	input [3:0]sel,
	output [31:0]result
//output zero
);
    reg [31:0]res;
	 	always @(*) begin
	     	case(sel)
		      	0 : begin 
					res = op1;//buffer
				end
				//1:res={31'b0,op1[31]};//<0
				2 : begin 
					res = op1 + op2;
				end
				3 : begin 
					res = op1 - op2;
				end
				4 : begin 
					res = op1 & op2;
				end
				5 : begin 
					res = op1 | op2;
				end
				6 : begin 
					res = op1 ^ op2;
				end
				7 : begin 
					res = ~ (op1 | op2);
				end
				8 : begin 
					res = op2 >> (op1[4:0]);
				end
				9 : begin 
					res = ($signed(op2)) >>> (op1[4:0]);
				end
				10 : begin 
					res = op2 << (op1[4:0]);
				end
				//11:res={31'b0,(op1==op2)};
				11 : begin 
					res = (op2 >> (op1[4:0])) | (op2 << (5'b0 - op1[4:0]));
				end
				12 : begin 
					res = {31'b0, ($signed(op1)) < ($signed(op2))};
				end
				13 : begin 
					res = {31'b0, op1 < op2};
				end
				//14:res={31'b0,op1!=0&&(~op1[31])};//>0
				14 : begin 
					res = (op2 << (op1[4:0])) | (op2 >> (5'b0 - op1[4:0]));
				end
				15 : begin 
					res = {31'b0, op1 == 0 || op1[31]};//<=0
				end
		  endcase
	 end
	 assign result=res;
	 //assign zero=(res==0);
endmodule
