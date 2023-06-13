import MathFunctions;

// Exercise 4:
// Complete the module below to calculate the mathematical function
// ((abs(in)/3)+10)*7) by calling functions from MathFunction.ms.

module PipelineMath;
  // Pipeline registers (to pass partial results from one stage to the next)
  Reg#(Maybe#(Bit#(16))) stage1(Invalid);
  Reg#(Maybe#(Bit#(16))) stage2(Invalid);
  Reg#(Maybe#(Bit#(16))) result(Invalid);

  input Maybe#(Bit#(16))
    in default = Invalid;

  rule pipeline;
    stage1 <= (isValid(in)) ? Valid(abs(fromMaybe(?, in))) : Invalid;
    stage2 <= (isValid(stage1)) ? Valid(divide3(fromMaybe(?, stage1))) : Invalid;
    result <= (isValid(stage2)) ? Valid(multiply7(add10(fromMaybe(?, stage2)))) : Invalid;
  endrule

  method Maybe#(Bit#(16)) out = result; // Do not change this line
endmodule
