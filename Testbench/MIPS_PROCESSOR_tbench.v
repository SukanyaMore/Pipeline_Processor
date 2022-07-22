`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.07.2022 13:17:59
// Design Name: 
// Module Name: MIPS_PROCESSOR_tbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MIPS_PROCESSOR_tbench();
reg clk, enable_ex;
wire [31:0] PC, NPC, IR1;

wire [31:0]  IR2,Ex_NPC,aluin1, aluin2,imm;
wire [2:0]   ALUop,MEMop, WBop;
wire [2:0]   operation_out;
wire [31:0]   IR3,aluout,memin;


wire [31:0]  IR4,WB_aluout,MEM_WB_LMD;
wire         EX_MEM_COND;


integer i;

pipeline_mips32 mips(.clk(clk),.enable_ex(enable_ex),.PC(PC), .NPC(NPC),
.IR1(IR1), .IR2(IR2), .IR3(IR3), .IR4(IR4),
 .Ex_NPC(Ex_NPC), .imm(imm), .aluin1(aluin1), .aluin2(aluin2), .operation_out(operation_out),
.ALUop(ALUop), .MEMop(MEMop), .WBop(WBop), .aluout(aluout), .memin(memin), .EX_MEM_COND(EX_MEM_COND),
.MEM_WB_LMD(MEM_WB_LMD),.WB_aluout(WB_aluout));

initial begin
clk =0;

#10;
enable_ex =1;

for(i=0; i<32; i = i+1)
    mips.REG[i]=i;
    
//-------------LOAD|STORE INSATRUCTIONS-------------    
mips.MEM[0] = 32'h20010078;   //ADDI R1, R0, 120
mips.MEM[1] = 32'h00631800;   //OR R3, R3, R3 ------dummy instr
mips.MEM[2] = 32'h00631800;   //OR R3, R3, R3 ------dummy instr
mips.MEM[3] = 32'h00631800;   //OR R3, R3, R3 ------dummy instr
mips.MEM[4] = 32'h8c220000;   //LW R2,0(R1)
mips.MEM[5] = 32'h00631800;   //OR R3, R3, R3 ------dummy instr
mips.MEM[6] = 32'h00631800;   //OR R3, R3, R3 ------dummy instr
mips.MEM[7] = 32'h00631800;   //OR R3, R3, R3 ------dummy instr
mips.MEM[8] = 32'h2042002d;   //ADDI R2, R2, 45
mips.MEM[9] = 32'h00631800;   //OR R3, R3, R3 ------dummy instr
mips.MEM[10] = 32'h00631800;   //OR R3, R3, R3 ------dummy instr
mips.MEM[11] = 32'h00631800;   //OR R3, R3, R3 ------dummy instr
mips.MEM[12] = 32'hac220001;   //SW R2,1(R1)


mips.MEM[120] =85;

//-------------R-TYPE INSATRUCTIONS-------------   

//mips.MEM[0] = 32'h2001000a;  //ADDI R1,R0,10
//mips.MEM[1] = 32'h20020014;  //ADDI R2, R0, 20
//mips.MEM[2] = 32'h20030019;  //ADDI R3, R0, 25
//mips.MEM[3] = 32'h00e73800;  //OR R7, R7, R7
//mips.MEM[4] = 32'h00e73800;  //OR R7, R7, R7
//mips.MEM[5] = 32'h00222000;  //ADD R4, R1, R2
//mips.MEM[6] = 32'h00e73800;  //OR R7, R7, R7
//mips.MEM[7] = 32'h00e73800;  //OR R7, R7, R7
//mips.MEM[8] = 32'h00e73800;  //OR R7, R7, R7
//mips.MEM[9] = 32'h00832800;  //ADD R5, R4, R3

mips.PC =0;

end
always #5 clk =~clk;
endmodule
