// Don't change signature of existing functions. You may write additional helper functions if you want.
// Description: 32-bit right barrel shifter
// Arguments: in (value to be shifted); sftSz (shift size); sft_in (the bit shifted in)
// Return: {sft_in's, in[31:sftSz]}
function Bit#(32) barrelRShift(Bit#(32) in, Bit#(5) sftSz, Bit#(1) sft_in);
    Bit#(16) s4 = signExtend(sft_in);
    Bit#(32) r4 = (sftSz[4] == 0) ? in : {s4, in[31:16]};
    Bit#(8) s3 = signExtend(sft_in);
    Bit#(32) r3 = (sftSz[3] == 0) ? r4 : {s3, r4[31:8]};
    Bit#(4) s2 = signExtend(sft_in);
    Bit#(32) r2 = (sftSz[2] == 0) ? r3 : {s2, r3[31:4]};
    Bit#(2) s1 = signExtend(sft_in);
    Bit#(32) r1 = (sftSz[1] == 0) ? r2 : {s1, r2[31:2]};
    Bit#(32) ret = (sftSz[0] == 0) ? r1 : {sft_in, r1[31:1]};
    return ret;
endfunction

// Description: 32-bit arithmetic/logic right shifter
// Arguments: in (value to be shifted); sftSz (shift size); arith (1 = arithmetic, 0 = logic)
// Return: in >> sftSz
function Bit#(32) sr32(Bit#(32) in, Bit#(5) sftSz, Bit#(1) arith);
    Bit#(1) sft_in = (arith == 1) ? in[31] : 1'b0;
    Bit#(32) ret = barrelRShift(in, sftSz, sft_in);
    return ret;
endfunction
// Description: 32-bit logic left shifter
// Arguments: in (values to be shifted); sftSz (shift size)
// Return: a << b
function Bit#(32) sll32(Bit#(32) in, Bit#(5) sftSz);
    Bit#(32) value = reverseBits(in);
    Bit#(32) shifted = barrelRShift(value, sftSz, 1'b0);
    Bit#(32) ret = reverseBits(shifted);
    return ret;
endfunction


// Description: 32-bit FULL shifter
// Arguments: in (value to be shifted); sftSz (shift size);
// ShiftTypes:
// LogicalRightShift
// ArithmeticRightShift
// LeftShift
//
// Return: in >> sftSz when right shift; in << sftSz otherwise
typedef enum {LogicalRightShift, ArithmeticRightShift, LeftShift} ShiftType;

function Bit#(32) sft32(Bit#(32) in, Bit#(5) sftSz, ShiftType shiftType);
    Bit#(32) word = (shiftType == LeftShift) ? reverseBits(in) : in;
    Bit#(1) sft_in = (shiftType == ArithmeticRightShift) ? word[31] : 1'b0;
    Bit#(32) result = barrelRShift(word, sftSz, sft_in);
    Bit#(32) ret = (shiftType == LeftShift) ? reverseBits(result) : result;
    return ret;
endfunction
// Description: one-bit less-than comparator
// Arguments: a, b (1-bit values), eq, lt (eq and lt from previous comparator)
// Return: {eq_i, lt_i}
function Bit#(2) cmp(Bit#(1) a, Bit#(1) b, Bit#(1) eq, Bit#(1) lt);
    Bit#(1) eq_i = (a & b & eq) | (~a & ~b & eq);
    Bit#(1) lt_i = (~a & b & eq) | lt;
    Bit#(2) ret = {eq_i, lt_i};
    return ret;
endfunction
// Description: unsigned 32-bit less-than comparator
// Arguments: a, b unsigned 32-bit values
// Return: 1 if a < b
function Bit#(1) ltu32(Bit#(32) a, Bit#(32) b);
    Bit#(33) eq_N = {1, 32'b0};
    Bit#(33) lt_N = 0;
    for (Integer i = 31; i >= 0; i = i - 1) begin
        let x = cmp(a[i], b[i], eq_N[i+1], lt_N[i+1]);
        eq_N[i] = x[1];
        lt_N[i] = x[0];
    end
    Bit#(1) ret = lt_N[0];
    return ret;
endfunction

// Description: Signed/Unsigned 32-bit less-than comparator
// Arguments: a b (32-bit values); isSigned (signed comparator when 1, unsigned otherwise)
// Return: 1 if a < b
function Bit#(1) lt32(Bit#(32) a, Bit#(32) b, Bit#(1) isSigned);
    Bit#(32) a_real = (isSigned == 1) ? {~a[31], a[30:0]} : a;
    Bit#(32) b_real = (isSigned == 1) ? {~b[31], b[30:0]} : b;
    Bit#(1) ret = ltu32(a_real, b_real);
    return ret;
endfunction

// Description: one-bit full adder
// Arguments: a, b, carry in
// Return: {carry out, sum}
function Bit#(2) fullAdder(Bit#(1) a, Bit#(1) b, Bit#(1) carryIn);
    Bit#(1) s = a ^ b ^ carryIn;
    Bit#(1) carryOut = (a & b) | (a & carryIn) | (b & carryIn);
    Bit#(2) ret = {carryOut, s};
    return ret;
endfunction

// Description: n-bit ripple-carry adder with a carry-in
// Arguments: a, b, carryIn
// Return: sum of a, b, and carryIn
function Bit#(n) rca#(Integer n)(Bit#(n) a, Bit#(n) b, Bit#(1) carryIn);
    Bit#(n+1) ret = rcaplus1#(n)(a, b, carryIn);
    return ret[n-1:0];
endfunction

// n-bit ripple-carry adder returning n+1 value
function Bit#(n+1) rcaplus1#(Integer n)(Bit#(n) a, Bit#(n) b, Bit#(1) carryIn);
    Bit#(n) lower = rcaplus1#(n-1)(a[n-2:0], b[n-2:0], carryIn);
    Bit#(2) upper = fullAdder(a[n-1], b[n-1], lower[n-1]);
    return {upper, lower[n-2:0]};
endfunction

// Base case
function Bit#(2) rcaplus1#(1)(Bit#(1) a, Bit#(1) b, Bit#(1) carryIn);
    return fullAdder(a, b, carryIn);
endfunction

// Description: n-bit ripple-carry adder/subractor
// Arguments: a, b (n-bit operands); isSub (1 => subtract, 0 => add)
// Return: isSub == 0 ? a + b : a - b
function Bit#(n) addSub#(Integer n)(Bit#(n) a, Bit#(n) b, Bit#(1) isSub);
    Bit#(n) b_real = (isSub == 1) ? ~b : b;
    Bit#(n) ret = rca#(n)(a, b_real, isSub);
    return ret;
endfunction


// Alu Functions:
// Add: 32-bit Addition         (a + b)
// Sub: 32-bit Subtraction      (a - b)
// And: 32-bit Bitwise And      (a & b)
// Or: 32-bit Bitwise Or        (a | b)
// Xor: 32-bit Bitwise Xor      (a ^ b)
// Slt: Set less than           (a <u b ? 1 : 0)
// Sltu: Set less than unsigned (a <s b ? 1:0)
// Sll: Left logic shfit        (a << b)
// Srl: Right logic shift       (a >>u b)
// Sra: Right arithmetic shift  (a >>s b)
typedef enum {Add, Sub, And, Or, Xor, Slt, Sltu, Sll, Srl, Sra} AluFunc;

// Description: Arithmetic Logic Unit (ALU)
// Arguments: a, operand a; b, operand b; func, ALU operation
// Return: output of ALU
function Bit#(32) alu(Bit#(32) a, Bit#(32) b, AluFunc func);
    Bit#(1) cin = case (func)
       Add : 0;
       Sub : 1;
       default : 0;
    endcase;
    Bit#(1) isSigned = case (func)
       Slt : 1;
       Sltu : 0;
       default : 0;
    endcase;
    ShiftType shiftType = case (func)
       Sll : LeftShift;
       Srl : LogicalRightShift;
       Sra : ArithmeticRightShift;
       default : LeftShift;
    endcase;

    Bit#(32) ret_0 = (func == Add || func == Sub) ? addSub#(32)(a, b, cin) : 0;
    Bit#(32) ret_1 = case(func)
       And : a & b;
       Or : a | b;
       Xor : a ^ b;
       default : ret_0;
    endcase;
    Bit#(32) ret_2 = (func == Slt || func == Sltu) ? zeroExtend(lt32(a, b, isSigned)) : ret_1;
    Bit#(32) ret = (func == Sll || func == Srl || func == Sra) ? sft32(a, b[4:0], shiftType) : ret_2;

    return ret;
endfunction


// Description: Alternative shifter implementation (Discussion Question)
function Bit#(32) sft32_alt(Bit#(32) in, Bit#(5) sftSz, ShiftType shiftType);
    return (shiftType == LeftShift) ? sft32(in, sftSz, LeftShift) : ((shiftType == ArithmeticRightShift)? sft32(in, sftSz, ArithmeticRightShift) : sft32(in, sftSz, LogicalRightShift));
endfunction


// Description: N-bit fast adder with a carry-in (Design Exercise)
// Arguments: a, b, carryIn
// Return: sum of a, b, and carryIn
function Bit#(n) fastAdd#(Integer n)(Bit#(n) a, Bit#(n) b, Bit#(1) carryIn);
    return fastAdder#(n)(a, b, carryIn)[n-1:0];
endfunction

function Bit#(n+1) fastAdder#(Integer n)(Bit#(n) a, Bit#(n) b, Bit#(1) carryIn);
    Bit#(n/2+1) lower = fastAdder#(n/2)(a[n/2-1:0], b[n/2-1:0], carryIn);
    Bit#(n/2+1) upper_0 = fastAdder#(n/2)(a[n-1:n/2], b[n-1:n/2], 1'b0);
    Bit#(n/2+1) upper_1 = fastAdder#(n/2)(a[n-1:n/2], b[n-1:n/2], 1'b1);
    Bit#(n+1) ret = (lower[n/2] == 1) ? {upper_1, lower[n/2-1:0]} : {upper_0, lower[n/2-1:0]}; 
    return ret;
endfunction

function Bit#(2) fastAdder#(1)(Bit#(1) a, Bit#(1) b, Bit#(1) carryIn);
    return fullAdder(a, b, carryIn);
endfunction
