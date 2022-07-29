`timescale 1ns / 1ns
module ALU(
	input [31 : 0]	op1,
	input [31 : 0]	op2,
	input [4 : 0]	sel,
	//0 : 
	//1 : 判断负数
	//2 : 加法运算
	//3 : 减法运算
	//4 : 按位与运算
	//5 : 按位或运算
	//6 : 按位异或
	//7 : 按位或非
	//8 : 逻辑右移
	//9 : 算术右移
	//10 : 算术/逻辑左移
	//11 : 判断是否相等
	//12 : 带符号 op1 小于 op2 判断
	//13 : 无符号 op1 小于 op2 判断
	//14 : op1 大于 0判断
	//15 : op1 小于 0 判断
	output [31:0]	result
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
					res = op1 + op2;  // 加法运算
				end
				3 : begin  
					res = op1 - op2;  // 减法运算
				end
				4 : begin 
					res = op1 & op2;  // 按位与运算
				end
				5 : begin  
					res = op1 | op2;  // 按位或运算
				end
				6 : begin 
					res = op1 ^ op2;  // 按位异或运算
				end
				7 : begin 
					res = ~ (op1 | op2);  // 或非运算
				end
				8 : begin 
					res = op2 >> (op1[4:0]);  // 逻辑右移
				end
				9 : begin 
					res = ($signed(op2)) >>> (op1[4:0]);  // 算术右移
				end
				10 : begin 
					res = op2 << (op1[4:0]);  // 算术/逻辑左移
				end
				//11:res={31'b0,(op1==op2)};
				11 : begin 
					res = (op2 >> (op1[4:0])) | (op2 << (5'b0 - op1[4:0]));  // 
				end
				12 : begin 
					res = {31'b0, ($signed(op1)) < ($signed(op2))};  // 带符号小于判断
				end
				13 : begin 
					res = {31'b0, op1 < op2};  // op1 小于 op2
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
