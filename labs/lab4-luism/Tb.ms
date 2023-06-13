/*
Copyright (C) 2018

Shuotao Xu <shuotao@csail.mit.edu>

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

bsvimport Vector;
import ALU;
bsvimport PopCount;

// Random number generation
bsvimport LFSR;
bsvimport FeedLFSR;

Bool doRandSeq = True;

module PairTestCaseGenerator;
    Reg#(Bit#(32)) cycle(0);
    FeedLFSR#(Bit#(32)) val0(32'h80000057);
    FeedLFSR#(Bit#(32)) val1(32'h80000057);

    input Bool advance default = False;
    Vector#(128, Tuple2#(Bit#(32), Bit#(32))) tests=unpack(0);
    tests[0]=tuple2(0,  0);
    tests[1]=tuple2(0,  1);
    tests[2]=tuple2(0,  2);
    tests[3]=tuple2(0,  3);
    tests[4]=tuple2(0, -1);
    tests[5]=tuple2(0, -2);
    tests[6]=tuple2(0, -3);
    tests[7]=tuple2(1,  0);
    tests[8]=tuple2(1,  1);
    tests[9]=tuple2(1,  2);
    tests[10]=tuple2(1,  3);
    tests[11]=tuple2(1, -1);
    tests[12]=tuple2(1, -2);
    tests[13]=tuple2(1, -3);
    tests[14]=tuple2(2,  0);
    tests[15]=tuple2(2,  1);
    tests[16]=tuple2(2,  2);
    tests[17]=tuple2(2,  3);
    tests[18]=tuple2(2, -1);
    tests[19]=tuple2(2, -2);
    tests[20]=tuple2(2, -3);
    tests[21]=tuple2(3,  0);
    tests[22]=tuple2(3,  1);
    tests[23]=tuple2(3,  2);
    tests[24]=tuple2(3,  3);
    tests[25]=tuple2(3, -1);
    tests[26]=tuple2(3, -2);
    tests[27]=tuple2(3, -3);
    tests[28]=tuple2(-1,  0);
    tests[29]=tuple2(-1,  1);
    tests[30]=tuple2(-1,  2);
    tests[31]=tuple2(-1,  3);
    tests[32]=tuple2(-1, -1);
    tests[33]=tuple2(-1, -2);
    tests[34]=tuple2(-1, -3);
    tests[35]=tuple2(-2,  0);
    tests[36]=tuple2(-2,  1);
    tests[37]=tuple2(-2,  2);
    tests[38]=tuple2(-2,  3);
    tests[39]=tuple2(-2, -1);
    tests[40]=tuple2(-2, -2);
    tests[41]=tuple2(-2, -3);
    tests[42]=tuple2(-3,  0);
    tests[43]=tuple2(-3,  1);
    tests[44]=tuple2(-3,  2);
    tests[45]=tuple2(-3,  3);
    tests[46]=tuple2(-3, -1);
    tests[47]=tuple2(-3, -2);
    tests[48]=tuple2(-3, -3);
    tests[49]=tuple2(4, -3);
    tests[50]=tuple2(4,  3);
    tests[51]=tuple2(4, -4);
    tests[52]=tuple2(4,  4);
    tests[53]=tuple2(4, -5);
    tests[54]=tuple2(4,  5);
    tests[55]=tuple2(-5, -4);
    tests[56]=tuple2(-5,  4);
    tests[57]=tuple2(-5, -5);
    tests[58]=tuple2(-5,  5);
    tests[59]=tuple2(-5, -6);
    tests[60]=tuple2(-5,  6);
    tests[61]=tuple2(1 << 2, 1);
    tests[62]=tuple2(1 << 3, 1);
    tests[63]=tuple2(1 << 4, 1);
    tests[64]=tuple2(1 << 5, 1);
    tests[65]=tuple2(1 << 6, 1);
    tests[66]=tuple2(1 << 7, 1);
    tests[67]=tuple2(1 << 8, 1);
    tests[68]=tuple2(1 << 9, 1);
    tests[69]=tuple2(1 << 10, 1);
    tests[70]=tuple2(1 << 11, 1);
    tests[71]=tuple2(1 << 12, 1);
    tests[72]=tuple2(1 << 13, 1);
    tests[73]=tuple2(1 << 14, 1);
    tests[74]=tuple2(1 << 15, 1);
    tests[75]=tuple2(1 << 16, 1);
    tests[76]=tuple2(1 << 17, 1);
    tests[77]=tuple2(1 << 18, 1);
    tests[78]=tuple2(1 << 19, 1);
    tests[79]=tuple2(1 << 20, 1);
    tests[80]=tuple2(1 << 21, 1);
    tests[81]=tuple2(1 << 22, 1);
    tests[82]=tuple2(1 << 23, 1);
    tests[83]=tuple2(1 << 24, 1);
    tests[84]=tuple2(1 << 25, 1);
    tests[85]=tuple2(1 << 26, 1);
    tests[86]=tuple2(1 << 27, 1);
    tests[87]=tuple2(1 << 28, 1);
    tests[88]=tuple2(1 << 29, 1);
    tests[89]=tuple2(1 << 30, 1);
    tests[90]=tuple2(1 << 31, 1);
    tests[91]=tuple2('haaaaaaaa, 0);
    tests[92]=tuple2('haaaaaaaa, 1);
    tests[93]=tuple2('haaaaaaaa, 2);
    tests[94]=tuple2('haaaaaaaa, 3);
    tests[95]=tuple2('haaaaaaaa, -1);
    tests[96]=tuple2('haaaaaaaa, -2);
    tests[97]=tuple2('haaaaaaaa, -3);
    tests[98]=tuple2('h7fffffff, 'h7fffffff);
    tests[99]=tuple2('h7fffffff, 'h80000000);
    tests[100]=tuple2('h7fffffff, 'h80000001);
    tests[101]=tuple2('h80000000, 'h7fffffff);
    tests[102]=tuple2('h80000000, 'h80000000);
    tests[103]=tuple2('h80000000, 'h80000001);
    tests[104]=tuple2('h80000001, 'h7fffffff);
    tests[105]=tuple2('h80000001, 'h80000000);
    tests[106]=tuple2('h80000001, 'h80000001);
    tests[107]=tuple2('h80000056, 'h80000056);
    tests[108]=tuple2('h80000056, 'h80000057);
    tests[109]=tuple2('h80000056, 'h80000058);
    tests[110]=tuple2('h80000057, 'h80000056);
    tests[111]=tuple2('h80000057, 'h80000057);
    tests[112]=tuple2('h80000057, 'h80000058);
    tests[113]=tuple2('h80000058, 'h80000056);
    tests[114]=tuple2('h80000058, 'h80000057);
    tests[115]=tuple2('h80000058, 'h80000058);
    tests[116]=tuple2('h0f0f0f0f, 'hf0f0f0f1);
    tests[117]=tuple2('h11111111, 'h12345678);
    tests[118]=tuple2('h12345678, 'h11111111);
    tests[119]=tuple2('h12345678, 'h23456789);
    tests[120]=tuple2('h20000000, 'h30000000);
    tests[121]=tuple2('h37c0ffee, 'h23accede);
    tests[122]=tuple2('h4abcdef8, 'hcafebabe);
    tests[123]=tuple2('h5a6b7c8d, 'h5a6b7c8d);
    tests[124]=tuple2('hacdcacdc, 'h90019001);
    tests[125]=tuple2('hdeadbeef, 'hfacade00);
    tests[126]=tuple2('hdefaced0, 'h5a5b5c5d);
    tests[127]=tuple2('hf0f0f0f0, 'h0f0f0f0f);
    method Bit#(32) value0;
        if (cycle < 128) begin
            return tpl_1(tests[cycle]);
        end else begin
            return val0.value;
        end
    endmethod

    method Bit#(32) value1;
        if (cycle < 128) begin
            return tpl_2(tests[cycle]);
        end else begin
            return val1.value;
        end
    endmethod

    method Bool doneWithFixed;
        return cycle == 128;
    endmethod

    rule run;

        if (advance) begin
            if (cycle == 0) begin
                val0.seed(32'hdeadbeef);
                val1.seed(32'hf0f0f0f0);
            end else if (cycle >= 128) begin
                val0.next;
                val1.next;
            end
            cycle <= cycle + 1;
        end
    endrule
endmodule

module PairAndExtraTestCaseGenerator#(Integer extraMax);
    PairTestCaseGenerator gen;
    Reg#(Bit#(log2(extraMax - 1) + 1)) extraReg(0);
    input Bool advance default = False;

    method Bit#(32) value0 = gen.value0;
    method Bit#(32) value1 = gen.value1;
    method Bit#(log2(extraMax - 1) + 1) extra = extraReg;

    method Bool doneWithFixed;
        return gen.doneWithFixed && extraReg == 0;
    endmethod

    rule run;
        if (advance) begin
            if (extraReg >= extraMax - 1) begin
                extraReg <= 0;
                gen.advance = True;
            end else begin
                extraReg <= extraReg + 1;
            end
        end
    endrule
endmodule

module Tb_fullAdder;
    Reg#(Bit#(32)) cycle(0);
    Reg#(Bit#(3)) vals(0);

    rule test;
        if ( cycle == 8) begin
            $display("Lab4.FullAdder: PASSED\n");
            $finish;
        end
        else begin
            if ( cycle == 0 ) begin
                $display("Lab4.FullAdder: Starting Test ...");
            end
            let test = fullAdder(vals[0], vals[1], vals[2]);
            Bit#(2) realAns = (case(vals)
                                 3'h0: 0;
                                 3'h1: 1;
                                 3'h2: 1;
                                 3'h3: 2;
                                 3'h4: 1;
                                 3'h5: 2;
                                 3'h6: 2;
                                 3'h7: 3;
                               endcase);

            if ( test != realAns ) begin
                $display("Lab4.FullAdder: FAILED fullAdder(0x%h, 0x%h, 0x%h) gave 0x%h, instead of 0x%h\n", vals[0], vals[1], vals[2], test, realAns);
                $finish;
            end

            // Update input values
            vals <= vals + 1;
        end
        cycle <= cycle + 1;
    endrule
endmodule


module Tb_rca32;
    Reg#(Bit#(32)) cycle(0);
    Reg#(Bit#(4)) in_a(0);
    Reg#(Bit#(4)) in_b(0);
    Reg#(Bit#(1)) in_cin(0);

    PairAndExtraTestCaseGenerator#(2) gen;

    rule test;
        if (cycle == 2048) begin
            $display("Lab4.RCA_Adder: PASSED\n");
            $finish;
        end
        else begin
            if (cycle < 512) begin
                if (cycle == 0) begin
                    $display("Lab4.RCA_Adder: Starting Tests ...");
                    $display("Lab4.RCA_Adder: Running exhaustive tests for 4 bits inputs ...");
                end

                let test_four_bits = rca#(4)(in_a, in_b, in_cin);
                let exp_four_bits = in_a + in_b + zeroExtend(in_cin);
                if ( test_four_bits != exp_four_bits ) begin
                    $display("Lab4.RCA_Adder: FAILED rca#(4)(0x%h, 0x%h, 0x%h) gave 0x%h, instead of 0x%h\n", in_a, in_b, in_cin, test_four_bits, exp_four_bits);
                    $finish;
                end

                // Updates input values
                if (cycle % 32 == 31) in_a <= in_a + 1;
                if (cycle % 2 == 1) in_b <= in_b + 1;
                in_cin <= ~in_cin;

            end
            else begin
                if (cycle == 512) begin
                    $display("Lab4.RCA_Adder: 4-bits input tests pass");
                    $display("Lab4.RCA_Adder: Running fixed testing with 32-bit inputs...");
                end
                else if (gen.doneWithFixed) begin
                    $display("Lab4.RCA_Adder: Fixed 32-bit inputs pass");
                    $display("Lab4.RCA_Adder: Running random testing with 32-bit inputs...");
                end

                Bit#(32) a = gen.value0;
                Bit#(32) b = gen.value1;
                Bit#(1) carry = gen.extra;

                let test = rca#(32)(a, b, carry);
                let realAns = a + b + zeroExtend(carry);
                if (test != realAns) begin
                    $display("Lab4.RCA_Adder: FAILED rca#(32)(0x%h, 0x%h, 0x%h) gave 0x%h, instead of 0x%h\n", a, b, carry, test, realAns);
                    $finish;
                end

                gen.advance = True;
            end
        end
        cycle <= cycle + 1;
    endrule
endmodule

module Tb_addSub32;
    Reg#(Bit#(32)) cycle(0);
    Reg#(Bit#(4)) in_a(0);
    Reg#(Bit#(4)) in_b(0);
    Reg#(Bit#(1)) in_op(0);

    PairAndExtraTestCaseGenerator#(2) gen;

    rule test;
        if (cycle == 2048) begin
            $display("Lab4.AdderSubtractor: PASSED\n");
            $finish;
        end
        else begin
            if (cycle < 512) begin
                if (cycle == 0) begin
                    $display("Lab4.AdderSubtractor : Starting Tests ...");
                    $display("Lab4.AdderSubtractor: Running exhaustive tests for 4 bits inputs ...");
                end

                let test_four_bits = addSub#(4)(in_a, in_b, in_op);
                let exp_four_bits = in_op == 0 ? in_a + in_b : in_a - in_b;
                if ( test_four_bits != exp_four_bits ) begin
                    $display("Lab4.AdderSubtractor: FAILED addSub#(4)(0x%h, 0x%h, 0x%h) gave 0x%h, instead of 0x%h\n", in_a, in_b, in_op, test_four_bits, exp_four_bits);
                    $finish;
                end

                // Updates input values
                if (cycle % 32 == 31) in_a <= in_a + 1;
                if (cycle % 2 == 1) in_b <= in_b + 1;
                in_op <= ~in_op;

            end
            else begin
                if (cycle == 512) begin
                    $display("Lab4.AdderSubtractor: 4-bits input tests pass");
                    $display("Lab4.AdderSubtractor: Running fixed testing with 32-bit inputs...");
                end
                else if (gen.doneWithFixed) begin
                    $display("Lab4.AdderSubtractor: Fixed 32-bit inputs pass");
                    $display("Lab4.AdderSubtractor: Running random testing with 32-bit inputs...");
                end

                Bit#(32) a = gen.value0;
                Bit#(32) b = gen.value1;
                Bit#(1) isSub = gen.extra;

                let test = addSub#(32)(a, b, isSub);
                let realAns = isSub == 0 ? a + b : a - b;
                if (test != realAns) begin
                    $display("Lab4.AdderSubtractor: FAILED addSub#(32)(0x%h, 0x%h, 0x%h) gave 0x%h, instead of 0x%h\n", a, b, isSub, test, realAns);
                    $finish;
                end

                gen.advance = True;
            end
        end
        cycle <= cycle + 1;
    endrule
endmodule


module Tb_fastAdd32;
    Reg#(Bit#(32)) cycle(0);
    Reg#(Bit#(4)) in_a(0);
    Reg#(Bit#(4)) in_b(0);
    Reg#(Bit#(1)) in_cin(0);

    PairAndExtraTestCaseGenerator#(2) gen;

    rule test;
        if (cycle == 2048) begin
            $display("Lab4.FASTADD32: PASSED\n");
            $finish;
        end
        else begin
            if (cycle < 512) begin
                if (cycle == 0) begin
                    $display("Lab4.FASTADD32: Starting Tests ...");
                    $display("Lab4.FASTADD32: Running exhaustive tests for inputs < 16 ...");
                end

                let test_four_bits = fastAdd#(4)(in_a, in_b, in_cin);
                let exp_four_bits = in_a + in_b + zeroExtend(in_cin);
                if ( test_four_bits != exp_four_bits ) begin
                    $display("Lab4.FASTADD32: FAILED fastAdd32(0x%h, 0x%h, 0x%h) gave 0x%h, instead of 0x%h\n", in_a, in_b, in_cin, test_four_bits, exp_four_bits);
                    $finish;
                end

                // Updates input values
                if (cycle % 32 == 31) in_a <= in_a + 1;
                if (cycle % 2 == 1) in_b <= in_b + 1;
                in_cin <= ~in_cin;

            end
            else begin
                if (cycle == 512) begin
                    $display("Lab4.FASTADD32: Input values < 16 pass");
                    $display("Lab4.FASTADD32: Running fixed testing with 32-bit inputs...");
                end
                else if (gen.doneWithFixed) begin
                    $display("Lab4.FASTADD32: Fixed 32-bit inputs pass");
                    $display("Lab4.FASTADD32: Running random testing with 32-bit inputs...");
                end

                Bit#(32) a = gen.value0;
                Bit#(32) b = gen.value1;
                Bit#(1) carry = gen.extra;

                let test = fastAdd#(32)(a, b, carry);
                let realAns = a + b + zeroExtend(carry);
                if (test != realAns) begin
                    $display("Lab4.FASTADD32: FAILED fastAdd32(0x%h, 0x%h, 0x%h) gave 0x%h, instead of 0x%h\n", a, b, carry, test, realAns);
                    $finish;
                end

                gen.advance = True;
            end
        end
        cycle <= cycle + 1;
    endrule
endmodule

module Tb_cmp;
    Reg#(Bit#(32)) cycle(0);
    Reg#(Bit#(4)) vals(0);

    rule test;
        if ( cycle == 12) begin
            // Stop at 12 so we don't test cases where eq and lt are both 1
            $display("Lab4.Comparator: PASSED\n");
            $finish;
        end
        else begin
            if ( cycle == 0 ) begin
                if(doRandSeq ) begin
                    //rand_seed();
                end
                $display("Lab4.Comparator: Starting Test ...");
            end
            let test = cmp(vals[0], vals[1], vals[2], vals[3]);
            Bit#(2) realAns = (case(vals)
                               4'h0: 0;
                               4'h1: 0;
                               4'h2: 0;
                               4'h3: 0;
                               4'h4: 2;
                               4'h5: 0;
                               4'h6: 1;
                               4'h7: 2;
                               4'h8: 1;
                               4'h9: 1;
                               4'ha: 1;
                               4'hb: 1;
			       4'hc, 4'hd, 4'he, 4'hf: 0;  //Illegal inputs, DO NOT TEST
                               endcase);

            if ( test != realAns ) begin
                $display("Lab4.Comparator: FAILED cmp(0x%h, 0x%h, 0x%h, 0x%h) gave 0x%h, instead of 0x%h\n", vals[0], vals[1], vals[2], vals[3], test, realAns);
                $finish;
            end

            // Update input values
            vals <= vals + 1;
        end
        cycle <= cycle + 1;
    endrule
endmodule


module Tb_ltu32;
    Reg#(Bit#(32)) cycle(0);
    Reg#(Bit#(4)) in_a(0);
    Reg#(Bit#(4)) in_b(0);

    PairTestCaseGenerator gen;

    rule test;
        if (cycle == 2048) begin
            $display("Lab4.LTu_Comparator: PASSED\n");
            $finish;
        end
        else begin
            if (cycle < 256) begin
                if (cycle == 0) begin
                    $display("Lab4.LTu_Comparator: Starting Tests ...");
                    $display("Lab4.LTu_Comparator: Running exhaustive tests for 4 bits inputs ...");
                end

                let test_four_bits = ltu32(zeroExtend(in_a), zeroExtend(in_b));
                let exp_four_bits = pack(in_a < in_b);
                if ( test_four_bits != exp_four_bits ) begin
                    $display("Lab4.LTu_Comparator: FAILED ltu32(0x%h, 0x%h) gave 0x%h, instead of 0x%h\n", in_a, in_b, test_four_bits, exp_four_bits);
                    $finish;
                end

                // Updates input values
                if (cycle % 16 == 15) in_a <= in_a + 1;
                in_b <= in_b + 1;
            end
            else begin
                if (cycle == 256) begin
                    $display("Lab4.LTu_Comparator: 4-bits input tests pass");
                    $display("Lab4.LTu_Comparator: Running fixed testing with 32-bit inputs...");
                end
                else if (gen.doneWithFixed) begin
                    $display("Lab4.LTu_Comparator: Fixed 32-bit inputs pass");
                    $display("Lab4.LTu_Comparator: Running random testing with 32-bit inputs...");
                end

                Bit#(32) a = gen.value0;
                Bit#(32) b = gen.value1;

                let test = ltu32(a, b);
                Bit#(1) realAns = pack(a < b);
                if (test != realAns) begin
                    $display("Lab4.LTu_Comparator: FAILED ltu32(0x%h, 0x%h) gave 0x%h, instead of 0x%h\n", a, b, test, realAns);
                    $finish;
                end

                gen.advance = True;
            end
        end
        cycle <= cycle + 1;
    endrule
endmodule


module Tb_lt32;
    Reg#(Bit#(32)) cycle(0);
    Reg#(Bit#(4)) in_a(0);
    Reg#(Bit#(4)) in_b(0);
    Reg#(Bit#(1)) in_sign(0);

    PairAndExtraTestCaseGenerator#(2) gen;

    rule test;
        if (cycle == 2048) begin
            $display("Lab4.LT_Comparator: PASSED\n");
            $finish;
        end
        else begin
            if (cycle < 512) begin
                if (cycle == 0) begin
                    $display("Lab4.LT_Comparator: Starting Tests ...");
                    $display("Lab4.LT_Comparator: Running exhaustive tests for 4 bits inputs ...");
                end

                let test_four_bits = lt32(signExtend(in_a), signExtend(in_b), in_sign);
                let exp_four_bits = in_sign == 0 ? pack(in_a < in_b) : pack(signedLT(in_a, in_b));
                if ( test_four_bits != exp_four_bits ) begin
                    $display("Lab4.LT_Comparator: FAILED lt4(0x%h, 0x%h, 0x%h) gave 0x%h, instead of 0x%h\n", in_a, in_b, in_sign, test_four_bits, exp_four_bits);
                    $finish;
                end

                // Updates input values
                if (cycle % 32 == 31) in_a <= in_a + 1;
                if (cycle % 2 == 1) in_b <= in_b + 1;
                in_sign <= ~in_sign;
            end
            else begin
                if (cycle == 512) begin
                    $display("Lab4.LT_Comparator: 4-bits input tests pass");
                    $display("Lab4.LT_Comparator: Running fixed testing with 32-bit inputs...");
                end
                else if (gen.doneWithFixed) begin
                    $display("Lab4.LT_Comparator: Fixed 32-bit inputs passed");
                    $display("Lab4.LT_Comparator: Running random testing with 32-bit inputs...");
                end

                Bit#(32) a = gen.value0;
                Bit#(32) b = gen.value1;
                Bit#(1) isSigned = gen.extra;

                let test = lt32(a, b, isSigned);
                Bit#(1) realAns = isSigned==0? pack(a < b) : pack(signedLT(a, b));
                if (test != realAns) begin
                    $display("Lab4.FASTADD32: FAILED fastAdd32(0x%h, 0x%h, 0x%h) gave 0x%h, instead of 0x%h\n", a, b, isSigned, test, realAns);
                    $finish;
                end

                gen.advance = True;
            end
        end
        cycle <= cycle + 1;
    endrule
endmodule

module Tb_sr32;
    Reg#(Bit#(32)) cycle(0);
    Reg#(Bit#(32)) shift_one_bit(32'h80000000);

    PairAndExtraTestCaseGenerator#(2) gen;

    rule test;
        if (cycle == 2048) begin
            $display("Lab4.Right_Shifter: PASSED\n");
            $finish;
        end
        else begin
            if ( cycle < 31) begin
                if (cycle == 0) begin
                    $display("Lab4.Right_Shifter: Starting Tests ...");
                    $display("Lab4.Single_bit_Shift : Shifting 0x80000000 one bit at a time ...");
                    $display("Lab4.Logical_Single_Bit_Shift : Computing Logical Right Shifts ...");
                end
                let test_one_bit = sr32(shift_one_bit, 1, 0);
                Bit#(32) realAns = shift_one_bit >> 1;
                if ( test_one_bit != realAns ) begin
                    $display("Lab4.Right_Shifter: FAILED sr32(0x%h, 0x%h, 0x%h) gave 0x%h, instead of 0x%h\n", shift_one_bit, 1, 0, test_one_bit, realAns);
                    $finish;
                end

                // Update input values
                shift_one_bit <= (cycle < 30) ? test_one_bit : 32'h80000000;
            end

            else if (cycle < 62) begin
                if (cycle == 31) begin
                    $display("Lab4.Logical_Single_Bit_Shift : pass");
                    $display("Lab4.Arithmetic_Single_Bit_Shift : Computing Arithmetic Right Shifts ...");
                end
                let test_one_bit = sr32(shift_one_bit, 1, 1);
                Bit#(32) realAns = signedShiftRight(shift_one_bit, 1);
                if ( test_one_bit != realAns ) begin
                    $display("Lab4.Right_Shifter: FAILED sr32(0x%h, 0x%h, 0x%h) gave 0x%h, instead of 0x%h\n", shift_one_bit, 1, 1, test_one_bit, realAns);
                    $finish;
                end

                // Update input values
                shift_one_bit <= test_one_bit;
            end

            else begin
                if (cycle == 62) begin
                    $display("Lab4.Arithmetic_Single_Bit_Shift : pass");
                    $display("Lab4.Single_Bit_Shift : pass");
                    $display("Lab4.Right_Shifter: Running testing with 32-bit inputs...");
                end else if (gen.doneWithFixed) begin
                    $display("Lab4.Right_Shifter: Fixed 32-bit inputs pass");
                    $display("Lab4.Right_Shifter: Running testing with random 32-bit inputs...");
                end

                Bit#(32) a = gen.value0;
                Bit#(5) b = gen.value1[4:0];
                Bit#(1) isSigned = gen.extra;

                let test = sr32(a, b, isSigned);
                Bit#(32) realAns = isSigned==0?a >> b:signedShiftRight(a,b);

                if ( test != realAns ) begin
                    $display("Lab4.Right_Shifter: FAILED sr32(0x%h, 0x%h, 0x%h) gave 0x%h, instead of 0x%h\n", a, b, isSigned, test, realAns);
                    $finish;
                end

                gen.advance = True;
            end
        end
        cycle <= cycle + 1;
    endrule
endmodule


module Tb_sll32;
    Reg#(Bit#(32)) cycle(0);
    Reg#(Bit#(32)) shift_one_bit(32'd1);

    PairTestCaseGenerator gen;

    rule test;
        if (cycle == 2048) begin
            $display("Lab4.SLL_Shifter: PASSED\n");
            $finish;
        end
        else begin
            if ( cycle < 31) begin
                if (cycle == 0) begin
                    $display("Lab4.SLL_Shifter: Starting Tests ...");
                    $display("Lab4.Single_Bit_Shift : Shifting 0x00000001 one bit at a time ...");
                end
                let test_one_bit = sll32(shift_one_bit, 1);
                Bit#(32) realAns = shift_one_bit <<  1;
                if ( test_one_bit != realAns ) begin
                    $display("Lab4.SLL_Shifter: FAILED sll32(0x%h, 0x%h) gave 0x%h, instead of 0x%h\n", shift_one_bit, 1, test_one_bit, realAns);
                    $finish;
                end

                // Update input values
                shift_one_bit <= test_one_bit;
            end
            else begin
                if (cycle == 31) begin
                    $display("Lab4.Single_Bit_Shift : pass");
                    $display("Lab4.SLL_Shifter: Running random testing with 32-bit inputs...");
                end

                Bit#(32) a = gen.value0;
                Bit#(5) b = gen.value1[4:0];

                let test = sll32(a, b);
                Bit#(32) realAns = a << b;
                if (test != realAns) begin
                    $display("Lab4.SLL_Shifter: FAILED sll32(0x%h, 0x%h) gave 0x%h, instead of 0x%h\n", a, b, test, realAns);
                    $finish;
                end

                gen.advance = True;
            end
        end
        cycle <= cycle + 1;
    endrule
endmodule


function ShiftType shiftTypeGen#(Integer i);
   return case (i)
             0: LogicalRightShift;
             1: ArithmeticRightShift;
             2: LeftShift;
          endcase;
endfunction


module Tb_sft32;
    Reg#(Bit#(32)) cycle(0);
    Vector#(3, ShiftType) shiftTypes = newVector;
    for (Integer i = 0; i < 3; i = i+1 ) shiftTypes[i] = shiftTypeGen#(i);

    PairAndExtraTestCaseGenerator#(3) gen;

    rule test;
        if ( cycle == 1024 ) begin
            $display("Lab4.FULL_Shifter: PASSED\n");
            $finish;
        end
        else begin
            let a = gen.value0;
            let b = gen.value1[4:0];
            let shiftType = shiftTypes[gen.extra];

            let test = sft32(a, b, shiftType);
            Bit#(32) realAns = 0;
            if ( shiftType == LeftShift) begin
                realAns = a << b;
            end
            else if ( shiftType == ArithmeticRightShift) begin
                realAns = signedShiftRight(a, b);
            end
            else begin
                realAns = a >> b;
            end

            if (test != realAns) begin
                $display("Lab4.FULL_Shifter: FAILED sft32(0x%h, 0x%h, ", a, b, fshow(shiftType),") gave 0x%h, instead of 0x%h\n", test, realAns);
                $finish;
            end

        end
        gen.advance = True;
        cycle <= cycle + 1;
    endrule
endmodule

function Bit#(32) alu_gold(Bit#(32) a, Bit#(32) b, AluFunc func);
    Bit#(32) res = case (func)
                     Add:    (a + b);
                     Sub:    (a - b);
                     And:    (a & b);
                     Or:     (a | b);
                     Xor:    (a ^ b);
                     Slt:    (signedLT(a, b) ? 1 : 0);
                     Sltu:   ((a < b) ? 1 : 0);
                     Sll:    (a << b[4:0]);
                     Srl:    (a >> b[4:0]);
                     Sra:    signedShiftRight(a, b[4:0]);
                  endcase;
   return res;
endfunction

function AluFunc alufuncGen#(Integer i);
    return case (i)
             0: Add;
             1: Sub;
             2: And;
             3: Or;
             4: Xor;
             5: Slt;
             6: Sltu;
             7: Sll;
             8: Srl;
             9: Sra;
          endcase;
endfunction


module Tb_alu;
    Reg#(Bit#(32)) cycle(0);
    Vector#(10, AluFunc) testV = newVector;
    for (Integer i = 0; i < 10; i = i + 1) testV[i] = alufuncGen#(i);

    PairAndExtraTestCaseGenerator#(10) gen;

    rule test;
        if (cycle == 4096) begin
            $display("Lab4.ALU: PASSED\n");
            $finish;
        end
        else begin
            // Update cycle after a round of tests

            // Testing
            if (cycle == 0) $display("Lab4.ALU: Starting Test ...");

            let a = gen.value0;
            let b = gen.value1;
            AluFunc f = testV[gen.extra];

            let test = alu(a, b, f);
            let realAns = alu_gold(a, b, f);
            if (test != realAns) begin
                $display("Lab4.ALU: FAILED alu(0x%h, 0x%h, ", a, b, fshow(f), ") gave 0x%h, instead of 0x%h\n", test, realAns);
                $finish;
            end

            gen.advance = True;
            cycle <= cycle + 1;
        end
   endrule
endmodule
