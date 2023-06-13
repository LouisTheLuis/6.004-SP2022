import TBTemplatesMultiplier;
import Multipliers;

Bool verbose_on = False;

//  Tests for multiply_by_adding function
module MultiplyByAddingTest;
    TbMulFunction#(8) tbMultiplyByAdding8(False, verbose_on);
endmodule

module MultiplySignedTest;
    TbMulFunction#(8) tbMultiplyByAdding8(True, verbose_on);
endmodule

// Tests for FoldedMultiplier module
module FoldedMultiplierTest;
    TbMulModule#(FoldedMultiplier, 8) tbFoldedMultiplier8(False, verbose_on);
endmodule

module FoldedMultiplierCustomTest#(Bit#(8) a, Bit#(8) b);
    TbMulModuleSingleTest#(FoldedMultiplier, 8) tbFoldedMultiplier8(a, b);
endmodule

module FastFoldedMultiplierTest;
    TbMulModule#(FastFoldedMultiplier, 32) tbFastFoldedMultiplier32(False, verbose_on);
endmodule
