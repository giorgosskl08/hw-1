`include "alu.v"
`include "regfile.v"

module datapath #(
    parameter [31:0] INITIAL_PC = 32'h00400000
)
(
    input wire clk, 
    input wire rst, 
    input wire [31:0] instr, 
    input wire PCSrc, 
    input wire ALUSrc, 
    input wire RegWrite, 
    input wire MemToReg, 
    input wire [3:0] ALUCtrl,
    input wire loadPC,
    output wire [31:0] PC, 
    output wire Zero,
  	output reg [31:0] dAddress, 
    output reg [31:0] dWriteData, 
    input wire [31:0] dReadData, 
    output reg [31:0] WriteBackData
);

  localparam [6:0] IMMEDIATE = 7'b0010011;
  localparam [6:0] NON_IMMEDIATE = 7'b0110011;
  localparam [6:0] LW = 7'b0000011;
  localparam [6:0] SW = 7'b0100011;
  localparam [6:0] BEQ = 7'b1100011;
  
  reg [31:0] PC_inter = INITIAL_PC; 
  reg [31:0] op2;
  wire [31:0] result_inter;
  
  //Immediate Generation
  reg [11:0] immediate;
  wire [31:0] sign_extended = {{20{instr[31]}}, instr[31:20]};
  wire [31:0] immediate_I = sign_extended;  
  wire [31:0] immediate_S = {{20{instr[31]}}, instr[31:25], instr[11:7]};  
  wire [31:0] immediate_B = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};  
  wire [31:0] complete_sign_extended_immediate = {sign_extended[31:12], immediate[11:0]};
  
  assign PC = PC_inter;
    wire [31:0] readData1, readData2;
  
  regfile registers(
    .clk(clk), 
    .write(RegWrite), 
    .readReg1(instr[19:15]), 
    .readReg2(instr[24:20]), 
    .writeReg(instr[11:7]), 
    .writeData(WriteBackData), 
    .readData1(readData1), 
    .readData2(readData2)
);
  
  alu alu_instance(
        .op1(readData1), 
        .op2(op2), 
        .alu_op(ALUCtrl), 
        .zero(Zero), 
        .result(result_inter)
    );
  
  always @(*) begin
    if ( instr[6:0] == SW )
        immediate = immediate_S;
    else if ( instr[6:0] == BEQ )
        immediate = immediate_B << 1;
    else if ( instr[6:0] == IMMEDIATE || instr[6:0] == LW )
        immediate =  immediate_I;
end
  
  //Programm Counter
  always @(posedge clk or posedge rst) begin
      if (rst) begin
            PC_inter <= INITIAL_PC; 
      end
      else if (loadPC) begin
        if (PCSrc)
              PC_inter <= PC_inter + immediate;
    	else
              PC_inter <= PC_inter + 4;
      end
  end
                             
  always @(*) begin
    //ALU
    if ( ALUSrc == 1 ) begin
      op2 = complete_sign_extended_immediate;
    end
      else if ( ALUSrc == 0 ) begin
          op2 = readData2;
      end

    dWriteData = readData2;
    dAddress = result_inter;
    
    if ( MemToReg == 1 ) begin  
      WriteBackData = dReadData;
    end
    else if ( MemToReg == 0 ) begin
      WriteBackData = result_inter;
    end
  end

endmodule