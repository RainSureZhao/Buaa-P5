`timescale 1ns / 1ns

module mips(
	input clk,
	input reset
);
    parameter delay_slot = 1'b1;
	parameter condition = 1'b1; //bxxal
	 
	wire stall;  // 暂停信号
	wire [1:0]	ForwardrsD;
	wire [1:0]	ForwardrtD;
	wire [1:0]	ForwardrsE;
	wire [1:0]	ForwardrtE;
	wire 		ForwardrtM;
	 
    wire [31:0]	nextPC;  
	wire [31:0]	IAddrF;  // 取指阶段的指令的地址
	wire [31:0]	IAddrD;  // 译码阶段的指令的地址
	wire [31:0]	IAddrE;  // 指令阶段的指令的地址
	wire [31:0]	IAddrM;  // 存储阶段的指令的地址
	wire [31:0]	IAddrW;  // 回写阶段的指令的地址
	 
	wire [31:0]	InstrF;
	wire [31:0]	InstrD;
	wire [31:0]	InstrE;
	wire [31:0]	InstrM;
	wire [31:0]	InstrW;
	wire [31:0]	PC4D;

	// 四个中间部分
	// D阶段的控制信号
	wire 		JumpD;  // 
    wire [2:0] 	RegSrcD;
	wire		MemWriteD;
	wire		BranchD;
	wire [1:0] 	ALUSrcD;
	wire [1:0]	RegDstD;
	wire		RegWriteD;
	wire [1:0]	ExtOpD;
	wire [4:0]	ALUCtrlD;
	wire		loenD;
	wire		hienD;

	// E阶段的控制信号 
	wire 		JumpE;  
    wire [2:0]	RegSrcE;
	wire		MemWriteE;
	wire		BranchE;
	wire [1:0]	ALUSrcE;
	wire [1:0]	RegDstE;
	wire		RegWriteE;
	wire [1:0]	ExtOpE;
	wire [4:0]	ALUCtrlE;
	wire		loenE;
	wire		hienE;
	
	// M阶段的控制信号
	wire 		JumpM;  // 跳到存储阶段
    wire [2:0]	RegSrcM;
	wire		MemWriteM;
	wire		BranchM;
	wire [1:0]	ALUSrcM;
	wire [1:0]	RegDstM;
	wire		RegWriteM;
	wire [1:0]	ExtOpM;
	wire [4:0]	ALUCtrlM;
	wire		loenM;
	wire		hienM;
	
	// W阶段的控制信号
	wire 		JumpW;  
    wire [2:0]  RegSrcW;
	wire		MemWriteW;
	wire		BranchW;
	wire [1:0]	ALUSrcW;
	wire [1:0]	RegDstW;
	wire		RegWriteW;
	wire [1:0]	ExtOpW;
	wire [4:0]	ALUCtrlW;
	wire		loenW;
	wire		hienW;
	 
	wire PCSrc;
	 //fetch   取指部分
	PC pc(.clk(clk), .en(~stall), .reset(reset), .next(nextPC), .IAddr(IAddrF));
	Instr_Memory im(.RAddr(IAddrF[13:2] - 12'hc00), .RData(InstrF));
	 
	preg32 InstrFD(.clk(clk), .en(~stall), .reset((~delay_slot & PCSrc & ~stall) | reset), .in(InstrF), .out(InstrD));
	preg32 PC4FD(.clk(clk), .en(~stall), .reset((~delay_slot & PCSrc & ~stall) | reset), .in(IAddrF + 4), .out(PC4D));
	preg32 IAddrFD(.clk(clk), .en(~stall), .reset((~delay_slot & PCSrc & ~stall) | reset), .in(IAddrF), .out(IAddrD));
	//decode  译码部分 
	Controller ctrlD(.cmd(InstrD), .Jump(JumpD), .RegSrc(RegSrcD), .MemWrite(MemWriteD), .Branch(BranchD), .ALUSrc(ALUSrcD), .RegDst(RegDstD), .RegWrite(RegWriteD), .ExtOp(ExtOpD), .ALUCtrl(ALUCtrlD), .loen(loenD), .hien(hienD));
	wire [31:0]		RegWDataM;
	wire [31:0]		RegWDataW;
	wire [4:0]		WriteRegM;
	wire [4:0]		WriteRegW;
	wire 			trueW;
	wire [4:0]		rsD;
	wire [4:0]		rtD;
	wire [4:0]		rdD;
	wire [31:0]		RegRData1D;
	wire [31:0]		RegRData2D;
	wire [31:0]		ImmD;
	wire [31:0]		PC4E;
	assign rsD = InstrD[25 : 21];
	assign rtD = InstrD[20 : 16];
	assign rdD = InstrD[15 : 11];
	GRF rf(clk, BranchW && condition ? RegWriteW && trueW : RegWriteW, reset, rsD, rtD, WriteRegW, RegWDataW, IAddrW, RegRData1D, RegRData2D);
	ext immext(InstrD[15:0], ExtOpD, ImmD);
	wire [31:0]		cmp1; 	// 比较运算数1
	wire [31:0]		cmp2;   // 比较运算数2
	wire 			true;
	assign PCSrc = BranchD && true;
	wire [31:0]		jumpto;
	assign cmp1 = ForwardrsD == 3 ? PC4E : ForwardrsD == 2 ? RegWDataM : ForwardrsD == 1 ? RegWDataW : RegRData1D;
	assign cmp2 = ForwardrtD == 3 ? PC4E : ForwardrtD == 2 ? RegWDataM : ForwardrtD == 1 ? RegWDataW : RegRData2D;
	compare cmp(cmp1, cmp2, ALUCtrlD[2 : 0], true);
	assign jumpto = ALUSrcD[0] ? {IAddrF[31 : 28], InstrD[25 : 0], 2'b00} : cmp1;
	assign nextPC = JumpD ? jumpto : PCSrc ? PC4D + ImmD : IAddrF + 4;  
	 
	wire [31:0]		RegRData1E;
	wire [31:0]		RegRData2E;
	wire [4:0]		rsE;
	wire [4:0]		rtE;
	wire [4:0]		rdE;
	wire [31:0]		ImmE;
	wire 			trueE;

	preg32 InstrDE(clk, 1'b1, stall | reset, InstrD, InstrE);
	preg32 PC4DE(clk, 1'b1, stall | reset, (delay_slot ? PC4D + 4 : PC4D), PC4E); // 如果延迟 则将pc + 4付给PC4E
	preg32 IAddrDE(clk, 1'b1, stall | reset, IAddrD, IAddrE);
	preg32 RD1DE(clk, 1'b1, stall | reset, cmp1, RegRData1E);
	preg32 RD2DE(clk, 1'b1, stall | reset, cmp2, RegRData2E);
	preg5 rsDE(clk, 1'b1, stall | reset, rsD, rsE);
	preg5 rtDE(clk, 1'b1, stall | reset, rtD, rtE);
	preg5 rdDE(clk, 1'b1, stall | reset, rdD, rdE);
	preg32 immDE(clk, 1'b1, stall | reset, ImmD, ImmE);
	preg1 trueDE(clk, 1'b1, stall | reset, true, trueE);

	//execute  执行部分
	Controller ctrlE(InstrE, JumpE, RegSrcE, MemWriteE, BranchE, ALUSrcE, RegDstE, RegWriteE, ExtOpE, ALUCtrlE, loenE, hienE);
	wire [4:0]		WriteRegE;
	assign WriteRegE = RegDstE == 2 ? 31 : RegDstE == 1 ? rdE : rtE;
	wire [31:0]		regAE;
	wire [31:0]		regBE;
	wire [31:0]		SrcAE;
	wire [31:0]		SrcBE;
	wire [31:0]		ALUOutE;
	 //wire [31:0]hiE;
	 //wire [31:0]loE;
	 //wire busy;
	assign regAE = ForwardrsE == 2 ? RegWDataM : ForwardrsE == 1 ? RegWDataW : RegRData1E;
	assign regBE = ForwardrtE == 2 ? RegWDataM : ForwardrtE == 1 ? RegWDataW : RegRData2E;
	assign SrcAE = ALUSrcE[1] ? {27'b0, InstrE[10:6]} : regAE;
	assign SrcBE = ALUSrcE[0] ? ImmE : regBE;
	ALU a(SrcAE, SrcBE, ALUCtrlE, ALUOutE);
	 //muldiv hilo(clk,loenE,hienE,reset,InstrE[1],InstrE[0],InstrE[30]&&~InstrE[1],regAE,regBE,busy,loE,hiE);
	wire [31:0]		MemWDataE;
	assign MemWDataE = regBE;
	
	wire [31:0]		MemWDataM;
	wire [31:0]		WData;
	wire [31:0]		ALUOutM;
	wire [31:0]		PC4M;
	wire [4:0]		rtM;
	//wire [31:0]loM;
	//wire [31:0]hiM;
	wire 			trueM;
	assign RegWDataM = RegSrcM == 2 ? PC4M : ALUOutM;  // E -> M
	assign WData = ForwardrtM ? RegWDataW : MemWDataM;
	preg32 InstrEM(clk, 1'b1, reset, InstrE, InstrM);
	preg32 ALUOutEM(clk, 1'b1, reset, ALUOutE, ALUOutM);
	preg32 MemWDataEM(clk, 1'b1, reset, MemWDataE, MemWDataM);
	preg32 PC4EM(clk, 1'b1, reset, PC4E, PC4M);
	preg32 IAddrEM(clk, 1'b1, reset, IAddrE, IAddrM);
	 //preg32 hiEM(clk,1'b1,reset,hiE,hiM);
	 //preg32 loEM(clk,1'b1,reset,loE,loM);
	preg5 WriteRegEM(clk, 1'b1, reset, WriteRegE, WriteRegM);
	preg5 rtEM(clk, 1'b1, reset, rtE, rtM);
	preg1 trueEM(clk, 1'b1, reset, trueE, trueM);

	//memory  存储阶段
	wire [31:0]		MemRDataM;
	Controller ctrlM(InstrM, JumpM, RegSrcM, MemWriteM, BranchM, ALUSrcM, RegDstM, RegWriteM, ExtOpM, ALUCtrlM, loenM, hienM);
	DM_8bit dm(clk, MemWriteM, reset, InstrM[28], InstrM[27:26], ALUOutM[13:0], WData, IAddrM, MemRDataM);
	 
	wire [4:0]		tmpM;
	//wire [4:0]tmpW;
	assign tmpM = {ALUOutM[1:0], 3'b000};
	//assign tmpW={ALUOutW[1:0],3'b00};
	wire [31:0]		readdata;
	//assign readdata=InstrM[31:26]!=38||tmpM==0?MemRDataM:(((WData>>(5'b0-tmpM))<<(5'b0-tmpM))|(MemRDataM>>tmpM)); //lwr
	assign readdata = InstrM[31:26] != 34 || tmpM == 24 ? MemRDataM : (((WData << (5'b1000 + tmpM )) >> (5'b1000 + tmpM )) | ( MemRDataM << (5'b11000 - tmpM))); //lwl
	
	wire [31:0]		ALUOutW;
	wire [31:0]		PC4W;
	wire [31:0]		MemRDataW;
	//wire [31:0]hiW;
	//wire [31:0]loW;
	preg32 InstrMW(clk, 1'b1, reset, InstrM, InstrW);  // M -> W
	preg32 ALUOutMW(clk, 1'b1, reset, ALUOutM, ALUOutW);
	preg32 PC4MW(clk, 1'b1, reset, PC4M, PC4W);
	preg32 IAddrMW(clk, 1'b1, reset, IAddrM, IAddrW);
	preg32 MemRDataMW(clk, 1'b1, reset, readdata, MemRDataW);
	//preg32 hiMW(clk,1'b1,reset,hiM,hiW);
	//preg32 loMW(clk,1'b1,reset,loM,loW);
	preg5 WriteRegMW(clk, 1'b1, reset, WriteRegM, WriteRegW);
	preg1 trueMW(clk, 1'b1, reset, trueM, trueW);
	// W阶段
	Controller ctrlW(InstrW, JumpW, RegSrcW, MemWriteW, BranchW, ALUSrcW, RegDstW, RegWriteW, ExtOpW, ALUCtrlW, loenW, hienW);
	assign RegWDataW = RegSrcW == 2 ? PC4W : RegSrcW == 1 ? MemRDataW : ALUOutW;
	 
	conflict hazard  
	(WriteRegE, WriteRegM, (BranchE && condition) ? (RegWriteE && trueE) : RegWriteE,
	(BranchM && condition) ? (RegWriteM && trueM) : RegWriteM, RegSrcE, RegSrcM, BranchD, JumpD, JumpE, RegDstD,
	rsD, rtD, rsE, rtE, WriteRegW,
	(BranchW && condition) ? (RegWriteW && trueW) : RegWriteW, rtM, stall,
	ForwardrsD, ForwardrtD, ForwardrsE, ForwardrtE, ForwardrtM);
endmodule
