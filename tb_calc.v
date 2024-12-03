`timescale 1ns / 1ps

module calculator_tb;

    // Inputs
    reg clk = 0;
    reg btnc = 0;
    reg btnl = 0;
    reg btnu = 0;
    reg btnr = 0;
    reg btnd = 0;
    reg [15:0] sw = 0;

    // Outputs
    wire [15:0] led;
`include "alu.v"
`include "calc_enc.v"

module calc(
  input clk,
  input btnc,
  input btnl,
  input btnu,
  input btnr,
  input btnd,
  input [15:0] sw,
  output reg [15:0] led
);
  
  reg [15:0] accumulator;
  wire [31:0] result;
  wire zero;
  wire [3:0] alu_op;
  
  wire signed [31:0] op1, op2;
       
  alu alu_instance (
        .op1(op1),
        .op2(op2),
        .alu_op(alu_op),
        .zero(zero), 
        .result(result)
  );

  calc_enc encoder (
        .btnc(btnc),
        .btnr(btnr),
        .btnl(btnl),
        .alu_op(alu_op)
  );
  
  assign op1 = {{16{accumulator[15]}}, accumulator};
  assign op2 = {{16{sw[15]}}, sw};
  
  always @(posedge clk) begin
    if (btnu) begin
      accumulator <= 16'b0; 
    end
    if (btnd) begin
      accumulator <= result[15:0];
  	end
  end

  always @(*) begin
      led = accumulator;
  end
  
endmodule

  
    // Instantiate the Unit Under Test (UUT)
    calc uut (
        .clk(clk), 
        .btnc(btnc), 
        .btnl(btnl), 
        .btnu(btnu), 
        .btnr(btnr), 
        .btnd(btnd), 
        .sw(sw), 
        .led(led)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd"); 
      	$dumpvars; 

        // Reset the calculator
        btnu = 1; 
        #10;
        btnu = 0;

        // 1. ADD operation
      	{btnl, btnc, btnr} = 3'b010;
        sw = 16'h354a;
        #10;
        btnd = 1;
        #10;
        btnd = 0;
      	$display("Expected: 0x354a, Got: 0x%h", led);
        
        // 2. SUB operation
      	{btnl, btnc, btnr} = 3'b011;
        sw = 16'h1234;
        #10;
        btnd = 1; 
        #10;
        btnd = 0;
        $display("Expected: 0x2316, Got: 0x%h", led);
        
        // 3. OR operation
        {btnl, btnc, btnr} = 3'b001; 
        sw = 16'h1001; 
        #10;
        btnd = 1; 
        #10;
        btnd = 0;
        $display("Expected: 0x3317, Got: 0x%h", led);
        
        // 4. AND operation
        {btnl, btnc, btnr} = 3'b000; 
        sw = 16'hf0f0; 
        #10;
        btnd = 1; 
        #10;
        btnd = 0;
        $display("Expected: 0x3010, Got: 0x%h", led);
        
        // 5. XOR operation
        {btnl, btnc, btnr} = 3'b111;
        sw = 16'h1fa2; 
        #10;
        btnd = 1; 
        #10;
        btnd = 0;
      	$display("Expected: 0x2fb2, Got: 0x%h", led);
      
      	// 6. ADD operation
      	{btnl, btnc, btnr} = 3'b010; 
        sw = 16'h6aa2; 
        #10;
        btnd = 1; 
        #10;
        btnd = 0;
     	$display("Expected: 0x9a54, Got: 0x%h", led);
        
        // 7. Logical Shift Left operation
        {btnl, btnc, btnr} = 3'b101; 
        sw = 16'h0004; 
        #10;
        btnd = 1; 
        #10;
        btnd = 0;
      	$display("Expected: 0xa540, Got: 0x%h", led);
        
        // 8. Arithmetic Shift Right operation
        {btnl, btnc, btnr} = 3'b110; 
        sw = 16'h0001; 
        #10;
        btnd = 1; 
        #10;
        btnd = 0;
      	$display("Expected: 0xd2a0, Got: 0x%h", led);
        
        // 9. Less Than operation
      	{btnl, btnc, btnr} = 3'b100;
        sw = 16'h46ff; 
        #10;
        btnd = 1; 
        #10;
        btnd = 0;
        $display("Expected: 0x0001, Got: 0x%h", led);
        
        // Finish the simulation
        #10;
        $finish;
    end
endmodule