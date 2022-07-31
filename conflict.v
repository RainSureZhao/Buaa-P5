`timescale 1ns / 1ns

module conflict(
	//stall  暂停处理
	// F: 取指阶段    D: 译码阶段  E:执行阶段  M:
	input [4:0]		WriteRegE,  // 执行阶段寄存器写地址
	input [4:0]		WriteRegM,  // 存储阶段寄存器写地址
	input 			RegWriteE,  // 执行阶段寄存器写使能
	input 			RegWriteM,  // 存储阶段寄存器写使能
	input [2:0]		RegSrcE,  // E阶段寄存器写选择信号
	input [2:0]		RegSrcM,  // M阶段寄存器写选择信号
	input 			BranchD,  // D阶段分支信号
	input 			JumpD,  // D跳转
	input 			JumpE,  // E跳转
	input [1:0]		RegDstD,  // 寄存器写地址选择
	input [4:0]		rsD,  // D阶段rs寄存器地址
	input [4:0]		rtD,  // D阶段rt寄存器地址

	//forward  转发处理
	input [4:0]		rsE,  
	input [4:0]		rtE,
	input [4:0]		WriteRegW,
	input 			RegWriteW,
	input [4:0]		rtM,

	//input mdbusy,
	//input usehilo,

	//stall out
	output stall,

	//forward out
	output [1:0]	ForwardrsD,
	output [1:0]	ForwardrtD,
	output [1:0]	ForwardrsE,
	output [1:0]	ForwardrtE,
	output ForwardrtM
);
	// D E M W
    //stall  暂停四种情况
	wire branchstall, jumpstall, loadstall;
	assign branchstall = BranchD && 
					((WriteRegE != 0 && RegWriteE && RegSrcE != 2 && (rsD == WriteRegE || rtD == WriteRegE ))||
							(WriteRegM != 0 && RegSrcM == 1 && ( rsD == WriteRegM || rtD == WriteRegM)));
	assign jumpstall = JumpD && 
					(WriteRegE != 0 && (RegWriteE && RegSrcE != 2 && rsD == WriteRegE) ||
							(WriteRegM != 0 && RegSrcM == 1 && rsD == WriteRegM));
	assign loadstall = RegSrcE == 1 && WriteRegE != 0 && ((RegDstD != 0 && rtD == WriteRegE)|| rsD == WriteRegE);
	//assign muldivstall=mdbusy && usehilo; 
	assign stall = branchstall || jumpstall || loadstall;
	
	//forward  转发
	assign ForwardrsD = WriteRegE != 0 && RegWriteE && WriteRegE == rsD ? 3 :
					WriteRegM != 0 && RegWriteM && WriteRegM == rsD ? 2 :
					WriteRegW !=0 && RegWriteW && WriteRegW == rsD ? 1 : 0;
	assign ForwardrtD = WriteRegE != 0 && RegWriteE && WriteRegE == rtD ? 3 :
					WriteRegM != 0 && RegWriteM && WriteRegM == rtD ? 2 :
					WriteRegW != 0 && RegWriteW && WriteRegW == rtD ? 1 : 0;
	
	assign ForwardrsE = WriteRegM != 0 && RegWriteM && WriteRegM == rsE ? 2 :
					WriteRegW != 0 && RegWriteW && WriteRegW == rsE ? 1 : 0;
	assign ForwardrtE = WriteRegM != 0 && RegWriteM && WriteRegM == rtE ? 2 :
					WriteRegW != 0 && RegWriteW && WriteRegW == rtE ? 1 : 0;
	
	assign ForwardrtM = WriteRegW != 0 && RegWriteW && WriteRegW == rtM;
	 
endmodule
