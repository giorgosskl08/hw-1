'include "alu.v"

module calc(
  input clk,
  input btnc,
  input btnl,
  input btnu,
  input btnr,
  input btnd,
  input [15:0] sw,
  output reg [15:0] led,
);
  
  reg [15:0] accumulator;
  wire [31:0] op1;
  wire [31:0] op2; 
  wire [31:0] result;
  
  always @(posedge clk) begin
    if(btnu) begin
      accumulator <= 0;
    end
    if (btnd) begin
      accumulator <= result[15:0];
  	end
  	led <= accumulator;
  end
  
  assign op1 = {{16{accumulator}}, accumulator};
  
  assign op2 = {{16{sw}}, sw};
  
endmodule

  