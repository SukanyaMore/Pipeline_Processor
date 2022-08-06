`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2022 14:58:45
// Design Name: 
// Module Name: pipeline_mips32
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



module pipeline_mips32(
input clk, enable_ex,
output reg [31:0]  PC, NPC,IR1, // PC, NEXT PC, INSTRUCTION IN FETCH-DECODE REGISTER
output reg [31:0]  IR2,Ex_NPC,aluin1, aluin2,imm, //INSTRUCTION IN DECODE-EXECUTE REGISTER
output reg [2:0]   ALUop,MEMop, WBop, // OPCODE CONVERTED INTO OPSELECT FOR ALU, MEMORY, WRITEBACK 
output reg [2:0]   operation_out,  // FUNCTION
output reg [31:0]  IR3, aluout,memin, //INSTRUCTION IN EXECUTE-MEMORY REGISTER, OUTPUT OF ALU/MEMORY OPERATION
output reg         EX_MEM_COND,  //condition to write in memory
output reg [31:0]  IR4,WB_aluout,MEM_WB_LMD //INSTRUCTION IN EXECUTE-MEMORY REGISTER, output that will be written on register
);


//reg branch_taken;

//decaration of registers and memory
reg [31:0] REG[0:31];
reg [31:0] MEM[0:1023]; 

// Defining the values of variable
//ALUop
`define LOAD = 3'b000 
`define STORE = 3'b001
`define R-TYPE = 3'b011
`define IMM = 3'b101
//Operation_out
`define ADD = 3'b010
`define SUB = 3'b110
`define AND = 3'b000
`define OR  = 3'b001
`define SLT = 3'b111

//--------Instruction fetch----------
always @(posedge clk)
if(enable_ex)
    begin
    IR1 <= MEM[PC];
    NPC <= PC+1;
    PC <= PC+1;
    end
//--------Instruction decode---------
// aluin1, operation_out, opselect_out,aluin2 
always @(posedge clk)
begin 
case(IR1[31:26])
6'b100011:begin //LOAD
          ALUop <= 3'b000;
          operation_out <= 3'b010; //ADD
          end
6'b101011:begin //STORE
          ALUop <= 3'b001;
          operation_out <= 3'b010; //ADD
          end
6'b001000:begin //IMM
          ALUop <= 3'b101;
          operation_out <= 3'b010; //ADD
          end
6'b000000:begin //R-TYPE
          ALUop <= 3'b011;
          case(IR1[5:0])
            6'b100000: operation_out <= 3'b010; //ADD
            6'b100010: operation_out <= 3'b110; //SUB
            6'b100100: operation_out <= 3'b000; //AND
            6'b100101: operation_out <= 3'b001; //OR
            6'b101010: operation_out <= 3'b111; //SLT
          endcase
          end
                         
endcase

if (enable_ex)
    begin
    IR2 <=IR1; //forwading instruction into next stage
    Ex_NPC <= NPC;
    imm <= {{16{IR1[15]}}, {IR1[15:0]}};
    
    aluin1 <= REG[IR1[25:21]];
    aluin2 <= REG[IR1[20:16]];
    end

end




//-----Instruction Execution-------

always @(posedge clk)
begin
if(enable_ex)
begin
MEMop <= ALUop;
IR3 <=IR2;
case(ALUop)
3'b000:  begin //LOAD
        if(operation_out<=3'b010)
        begin
        aluout <= aluin1 + imm;
        memin <= aluin2;
        end
        end
3'b001:  begin //STORE
        if(operation_out<=3'b010)
        begin
        aluout <= aluin1 + imm;
        memin <= aluin2;
        end
        end
3'b011:  begin//RTYPE
        case(operation_out)
        3'b010: aluout<= aluin1 + aluin2;
        3'b110: aluout<= aluin1 - aluin2;
        3'b010: aluout<= aluin1 & aluin2;
        3'b010: aluout<= aluin1 | aluin2;
        3'b010: aluout<= aluin1 < aluin2;
        default: aluout <= 32'hxxxx_xxxx;    
        endcase
        end
3'b101:  begin//IMM
        if(operation_out<=3'b010)
        begin
        aluout <= aluin1 + imm;
        end
        end

endcase        
end
end

// MEMORY STAGE
always @(posedge clk)
begin
if(enable_ex)
begin
WBop <= MEMop;
IR4<=IR3;
case(MEMop)
3'b011, 3'b101: WB_aluout <= aluout; //R-TYPE AND IMM
3'b000: MEM_WB_LMD <= MEM[aluout]; //LOAD
3'b001: MEM[aluout] <= memin;
endcase
end
end

// WRITE BACK 
always @(posedge clk)
begin
case(WBop)
3'b011: REG[IR4[15:11]] <= WB_aluout; //rd
3'b101: REG[IR4[20:16]] <= WB_aluout; //rt
3'b000: REG[IR4[20:16]] <= MEM_WB_LMD; //rt
endcase
end


