`timescale 1ns / 1ns

module DM_8bit(
	input clk,
	input WE,
	input reset,
	input isu,
	input [1:0]MemDst,
	input [13:0]Addr,
	input [31:0]WData,
	input [31:0]IAddr,
	output [31:0]RData
);
    reg 	[7:0]	ram [0:16383];  // 128 * 128
	wire 	[31:0]	out1;
	wire 	[31:0]	out2;
	integer 	i;
	wire 	[31:0]	tmp;
	wire 	[4:0]	sh;
	reg 	[31:0]	temp;
	initial begin
	    for(i = 0; i < 16384; i = i + 4) begin
			{ram[i + 3], ram[i + 2], ram[i + 1], ram[i]} = 0;  // 初始化为零
		end
	end
	always @(posedge clk) begin
	    if(reset) for( i = 0; i < 16384; i = i + 4) begin
			{ram[i + 3], ram[i + 2], ram[i + 1], ram[i]} = 0; 
		end 
		else if(WE) begin
		    i = {18'b0, Addr[13:2], 2'b0};
				case(MemDst)
					0 : begin
					    ram[Addr] = WData[7:0]; //sb  存储字节
					end
					1 : begin
					    { ram[{Addr[13:1], 1'b1}], ram[{Addr[13:1], 1'b0}]} = WData[15:0]; //sh 存储半字
					end
					2 : begin
					    temp = {ram[i+3], ram[i+2], ram[i+1], ram[i] };
						  //{ram[i+3],ram[i+2],ram[i+1],ram[i]}=sh==0?WData:(((temp<<(5'b0-sh))>>(5'b0-sh))|(WData<<sh));//swr
						{ram[i+3], ram[i+2], ram[i+1], ram[i]} = sh == 24 ? WData : (((temp >> (5'b1000 + sh)) << (5'b1000 + sh)) | (WData >> (5'b11000 - sh )));//swl
					end
					3:begin
					    {ram[i+3], ram[i+2], ram[i+1], ram[i]} = WData; //sw  存储字
					end
				endcase
//				$display("@%h: *%h <= %h",IAddr, i,{ram[i+3],ram[i+2],ram[i+1],ram[i]});
				$display("%d@%h: *%h <= %h",$time, IAddr, i, {ram[i+3], ram[i+2], ram[i+1], ram[i]});
		end
	end
	assign tmp = {18'b0, Addr[13:2], 2'b0};
	assign sh = {Addr[1:0], 3'b000};  // sh
	ext extend1({ram[{Addr[13:1], 1'b1}], ram[{Addr[13:1], 1'b0}]}, {1'b0,isu}, out1); // lh,lhu
	 //ext extend1({ram[Addr+1],ram[Addr]},{1'b0,isu},out1);//ulh(u)
	extbyte extend2(ram[Addr], isu, out2); // lb,lbu
	assign RData = (MemDst[1]) ? {ram[tmp+3], ram[tmp+2], ram[tmp+1], ram[tmp]} : (MemDst[0] ? out1 : out2);
	 //assign RData=(MemDst[1])?{ram[Addr+3],ram[Addr+2],ram[Addr+1],ram[Addr]}:(MemDst[0]?out1:out2);//ulw
endmodule
