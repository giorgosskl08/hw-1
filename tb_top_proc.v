`include "ram.v"
`include "rom.v"
`timescale 1ns / 1ps

module riscv_core_testbench;

// Clock and reset signals
reg clk; 
reg rst;
wire [31:0] instr; 
wire [31:0] PC;
wire [31:0] dAddress; 
wire [31:0] dWriteData;
wire MemRead;
wire MemWrite;
wire [31:0] dReadData; 
wire [31:0] WriteBackData;

// Instantiate the RISC-V core
DATA_MEMORY ram(.we(MemWrite),.dout(dReadData),.din(dWriteData),.addr(dAddress[8:0]),.clk(clk));  
  
  
procedures core(
    .clk(clk),
    .rst(rst),
    .instr(instr),
    .PC(PC),
  	.dAddress(dAddress),
    .dWriteData(dWriteData),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .dReadData(dReadData),
    .WriteBackData(WriteBackData)
);

INSTRUCTION_MEMORY rom(
    .clk(clk),
    .addr(PC[8:0]),
    .dout(instr)
);

always begin
  clk = 0;  
  #5 clk <= ~clk; 
end

initial begin
    $dumpfile("final.vcd");
    $dumpvars(0, riscv_core_testbench);  
    rst = 0;
    #15 rst = 1;
    #1000 $finish;
end

endmodule