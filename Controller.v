`timescale 1ns / 1ns

module Controller(
	input [31:0]	cmd,
	output 			Jump,
	output [2:0]	RegSrc,
	output 			MemWrite,
	output 			Branch,
	output [1:0]	ALUSrc,
	output [1:0]	RegDst,
	output 			RegWrite,
	output [1:0]	ExtOp,
	output [4:0]	ALUCtrl,
	output 			loen,
	output 			hien
);
    //{ext,RegWrite,[1:0]RegDst,[1:0]ALUSrc,Branch,MemWrite,[2:0]RegSrc,Jump,[4:0]ALUCtrl,hilo,}
	 reg [19:0]  temp;
	 always @(cmd) begin
	    if(cmd == 0) begin
			temp = 0;//nop
		end
	    else case(cmd[31:26])
		    0 : begin
				case( cmd[5 : 0])
				    0 : begin 
						temp = 20'b00_1_01_10_00_000_0_01010_00; //sll
					end
					2 : begin 
						temp = 20'b00_1_01_10_00_000_0_01000_00; //srl
					end
					3 : begin 
						temp = 20'b00_1_01_10_00_000_0_01001_00; //sra
					end
					4 : begin
					 	temp = 20'b00_1_01_00_00_000_0_01010_00; //sllv
					end
					6 : begin 
						temp = 20'b00_1_01_00_00_000_0_01000_00; //srlv
					end
					7 : begin
						temp = 20'b00_1_01_00_00_000_0_01001_00;//srav
					end
					8 : begin 
						temp = 20'b00_0_00_00_00_000_1_00000_00;//jr
					end
					9 : begin 
						temp = 20'b00_1_01_00_00_010_1_00000_00;//jalr
					end
					// 还需要完善的指令 涉及乘除法
					/*16:temp='b00_1_01_00_00_100_0_00000_00;//mfhi 010000 mdsel=Intsr[1]
					17:temp='b00_0_00_00_00_000_0_00000_01;//mthi 010001 isunsigned=Instr[0]
					18:temp='b00_1_01_00_00_011_0_00000_00;//mflo 010010
					19:temp='b00_0_00_00_00_000_0_00000_10;//mtlo 010011
					24:temp='b00_0_01_00_00_000_0_00000_11;//mult 011000
					25:temp='b00_0_01_00_00_000_0_00000_11;//multu 011001
					26:temp='b00_0_01_00_00_000_0_00000_11;//div  011010
					27:temp='b00_0_01_00_00_000_0_00000_11;//divu 011011*/

					32 : begin 
						temp = 20'b00_1_01_00_00_000_0_00010_00; //add
					end
					33 : begin 
						temp = 20'b00_1_01_00_00_000_0_00010_00; //addu
					end
					34 : begin 
						temp = 20'b00_1_01_00_00_000_0_00011_00; //sub
					end
					35 : begin 
						temp = 20'b00_1_01_00_00_000_0_00011_00; //subu
					end
					36 : begin 
						temp = 20'b00_1_01_00_00_000_0_00100_00; //and
					end
					37 : begin 
						temp = 20'b00_1_01_00_00_000_0_00101_00; //or
					end
					38 : begin 
						temp = 20'b00_1_01_00_00_000_0_00110_00; //xor
					end
					39 : begin 
						temp = 20'b00_1_01_00_00_000_0_00111_00;//nor
					end
					42 : begin 
						temp = 20'b00_1_01_00_00_000_0_01100_00;//slt
					end
					43 : begin 
						temp = 20'b00_1_01_00_00_000_0_01101_00;//sltu
					end
				endcase
			  end
				1 : begin
					case(cmd[20:16])
						0 : begin 
							temp = 20'b11_0_00_00_10_000_0_00100_00;//bltz
						end
						1 : begin
							temp = 20'b11_0_00_00_10_000_0_00101_00;//bgez
						end
						17 : begin
							temp = 20'b11_1_10_00_10_010_0_00101_00;//bgezal
						end
					endcase
				end
				//{[1:0]ext,RegWrite,[1:0]RegDst,[1:0]ALUSrc,Branch,MemWrite,[2:0]RegSrc,Jump,[3:0]ALUCtrl}
				2 : begin
					temp = 20'b00_0_00_01_00_000_1_00000_00; //j
				end
				3 : begin 
					temp = 20'b00_1_10_01_00_010_1_00000_00; //jal
				end
				4 : begin 
					temp = 20'b11_0_01_00_10_000_0_00000_00; //beq
				end
				5 : begin 
					temp = 20'b11_0_01_00_10_000_0_00001_00; //bne
				end
				6 : begin 
					temp = 20'b11_0_00_00_10_000_0_00010_00; //blez
				end
				7 : begin
					temp = 20'b11_0_00_00_10_000_0_00011_00; //bgtz
				end
				8 : begin 
					temp = 20'b00_1_00_01_00_000_0_00010_00;//addi
				end
				9 : begin 
					temp = 20'b00_1_00_01_00_000_0_00010_00;//addiu
				end
				10 : begin 
					temp = 20'b00_1_00_01_00_000_0_01100_00;//slti
				end
				11 : begin 
					temp = 20'b00_1_00_01_00_000_0_01101_00;//sltiu
				end
				12 : begin 
					temp = 20'b01_1_00_01_00_000_0_00100_00;//andi
				end
				13 : begin 
					temp = 20'b01_1_00_01_00_000_0_00101_00;//ori
				end
				14 : begin 
					temp = 20'b01_1_00_01_00_000_0_00110_00;//xori
				end
				15 : begin 
					temp = 20'b10_1_00_01_00_000_0_00101_00;//lui
				end
				//16:
				//28:temp='b00_0_01_00_00_000_0_0000_11;//madd(u) attention:MUL Instr[1] stall()
				32 : begin 
					temp = 20'b00_1_00_01_00_001_0_00010_00;//lb
				end
				33 : begin 
					temp = 20'b00_1_00_01_00_001_0_00010_00;//lh
				end
				34 : begin 
					temp = 20'b00_1_00_01_00_001_0_00010_00;//lwl
				end
				35 : begin 
					temp = 20'b00_1_00_01_00_001_0_00010_00;//lw
				end
				36 : begin
					temp = 20'b00_1_00_01_00_001_0_00010_00;//lbu
				end
				37 : begin 
					temp = 20'b00_1_00_01_00_001_0_00010_00;//lhu
				end
				38 : begin 
					temp = 20'b00_1_00_01_00_001_0_00010_00;//lwr
				end
				40 : begin 
					temp = 20'b00_0_00_01_01_000_0_00010_00;//sb
				end
				41 : begin 
					temp='b00_0_00_01_01_000_0_00010_00;//sh
				end
				42 : begin
					temp = 20'b00_0_00_01_01_000_0_00010_00;//swl
				end
				43 : begin 
					temp = 20'b00_0_00_01_01_000_0_00010_00;//sw
				end
				46 : begin
					temp = 20'b00_0_00_01_01_000_0_00010_00;//swr
				end
		endcase
	end
	 assign {ExtOp, RegWrite, RegDst, ALUSrc, Branch, MemWrite, RegSrc, Jump, ALUCtrl, loen, hien } = temp;
endmodule
