import ProcTypes;
import Execute;
import ALU;

/*typedef struct {
    Bit#(32) word;
    IType iType;
    Maybe#(AluFunc) aluFunc;
    Maybe#(BrFunc) brFunc;
    Maybe#(Maybe#(RIndx)) dst;
    Maybe#(RIndx) src1;
    Maybe#(RIndx) src2;
    Maybe#(Word) imm;
} DecodedInstSpec;*/
typedef struct{
    DecodedInst dInst;
    Bit#(32) rVal1;
    Bit#(32) rVal2;
    Bit#(32) pc;
    ExecInst eInst;
    Bool checkData;
    Bool checkAddr;
} ExecInstSpec;
/*
Vector#(10, DecodedInstSpec) tests = {
endfunction
};
*/

function Maybe#(RIndx) vDst(Bit#(5) index) = Valid(index);

Maybe#(Maybe#(RIndx)) noDst = Valid(Invalid);


module ExecuteTB;
    Reg#(Bit#(9)) cycle(0);
    Reg#(IType) lastIType(LUI);
    Reg#(Bit#(9)) iTypeCount(0);
    rule test;
        Vector #(75, ExecInstSpec ) tests;

        tests[0]=ExecInstSpec{
            dInst:DecodedInst{iType: LUI, aluFunc:?, brFunc:?, dst: vDst(1),src1:?,src2:? , imm: 'h00001000},
            rVal1: ?,
            rVal2: ?,
            pc: 'h44,
            eInst: ExecInst{iType: LUI, dst: vDst(1), data: 'h000001000, addr: ?, nextPc: 'h48},
            checkData: True,
            checkAddr: False
        };
        tests[1]=ExecInstSpec{
            dInst:DecodedInst{iType: LUI, aluFunc:?, brFunc:?, dst: vDst(12),src1:?,src2:? , imm: 'hDEADB000},
            rVal1: ?,
            rVal2: ?,
            pc: 'hFC,
            eInst: ExecInst{iType: LUI, dst: vDst(12), data: 'hDEADB000, addr: ?, nextPc: 'h100},
            checkData: True,
            checkAddr: False
        };
        tests[2]=ExecInstSpec{
            dInst:DecodedInst{iType: LUI, aluFunc:?, brFunc:?, dst: vDst(23),src1:?,src2:? , imm: 'hBDEAD000},
            rVal1: ?,
            rVal2: ?,
            pc: 'h1234,
            eInst: ExecInst{iType: LUI, dst: vDst(23), data: 'hBDEAD000, addr: ?, nextPc: 'h1238},
            checkData: True,
            checkAddr: False
        };
        tests[3]=ExecInstSpec{
            dInst:DecodedInst{iType: LUI, aluFunc:?, brFunc:?, dst: vDst(0),src1:?,src2:? , imm: 'hBDEAD000},
            rVal1: ?,
            rVal2: ?,
            pc: 'h1234,
            eInst: ExecInst{iType: LUI, dst: vDst(0), data: 'hBDEAD000, addr: ?, nextPc: 'h1238},
            checkData: True,
            checkAddr: False
        };
        tests[4]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Add, brFunc:?, dst: vDst(1),src1:?,src2:? , imm: 'h03},
            rVal1: 'h10,
            rVal2: ?,
            pc: 'h124,
            eInst: ExecInst{iType: OPIMM, dst: vDst(1), data: 'h13, addr: ?, nextPc: 'h128},
            checkData: True,
            checkAddr: False
        };
        tests[5]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Add, brFunc:?, dst: vDst(10),src1:?,src2:? , imm: -2},
            rVal1: 'h205,
            rVal2: ?,
            pc: 'h320,
            eInst: ExecInst{iType: OPIMM, dst: vDst(10), data: 'h203, addr: ?, nextPc: 'h324},
            checkData: True,
            checkAddr: False
        };
        tests[6]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Add, brFunc:?, dst: vDst(27),src1:?,src2:? , imm: 'h281},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h348,
            eInst: ExecInst{iType: OPIMM, dst: vDst(27), data: 'h47E3, addr: ?, nextPc: 'h34C},
            checkData: True,
            checkAddr: False
        };
        tests[7]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:And, brFunc:?, dst: vDst(10),src1:?,src2:? , imm: 'h281},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h348,
            eInst: ExecInst{iType: OPIMM, dst: vDst(10), data: 'h0, addr: ?, nextPc: 'h34C},
            checkData: True,
            checkAddr: False
        };
        tests[8]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:And, brFunc:?, dst: vDst(5),src1:?,src2:? , imm: 'hDEADBEEF},
            rVal1: 'hFFFF,
            rVal2: ?,
            pc: 'h14,
            eInst: ExecInst{iType: OPIMM, dst: vDst(5), data: 'hBEEF, addr: ?, nextPc: 'h18},
            checkData: True,
            checkAddr: False
        };
        tests[9]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Or, brFunc:?, dst: vDst(10),src1:?,src2:? , imm: 'h253},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h348,
            eInst: ExecInst{iType: OPIMM, dst: vDst(10), data: 'h4773, addr: ?, nextPc: 'h34C},
            checkData: True,
            checkAddr: False
        };
        tests[10]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Or, brFunc:?, dst: vDst(5),src1:?,src2:? , imm: 'hDEADBEEF},
            rVal1: 'hFFFF,
            rVal2: ?,
            pc: 'h14,
            eInst: ExecInst{iType: OPIMM, dst: vDst(5), data: 'hDEADFFFF, addr: ?, nextPc: 'h18},
            checkData: True,
            checkAddr: False
        };
        tests[11]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Xor, brFunc:?, dst: vDst(17),src1:?,src2:? , imm: 'h253},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h348,
            eInst: ExecInst{iType: OPIMM, dst: vDst(17), data: 'h4731, addr: ?, nextPc: 'h34C},
            checkData: True,
            checkAddr: False
        };
        tests[12]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Xor, brFunc:?, dst: vDst(5),src1:?,src2:? , imm: 'hDEADBEEF},
            rVal1: 'hFFFF,
            rVal2: ?,
            pc: 'h14,
            eInst: ExecInst{iType: OPIMM, dst: vDst(5), data: 'hDEAD4110, addr: ?, nextPc: 'h18},
            checkData: True,
            checkAddr: False
        };
        tests[13]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Sll, brFunc:?, dst: vDst(17),src1:?,src2:? , imm: 'h1},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h348,
            eInst: ExecInst{iType: OPIMM, dst: vDst(17), data: 'h8AC4, addr: ?, nextPc: 'h34C},
            checkData: True,
            checkAddr: False
        };
        tests[14]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Sll, brFunc:?, dst: vDst(5),src1:?,src2:? , imm: 'h3},
            rVal1: 'hFFFF,
            rVal2: ?,
            pc: 'h14,
            eInst: ExecInst{iType: OPIMM, dst: vDst(5), data: 'h7FFF8, addr: ?, nextPc: 'h18},
            checkData: True,
            checkAddr: False
        };
        tests[15]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Sra, brFunc:?, dst: vDst(12),src1:?,src2:? , imm: 'h1},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h844,
            eInst: ExecInst{iType: OPIMM, dst: vDst(12), data: 'h22B1, addr: ?, nextPc: 'h848},
            checkData: True,
            checkAddr: False
        };
        tests[16]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Sra, brFunc:?, dst: vDst(23),src1:?,src2:? , imm: 'h2},
            rVal1: 'hFFFFFF00,
            rVal2: ?,
            pc: 'h0,
            eInst: ExecInst{iType: OPIMM, dst: vDst(23), data: 'hFFFFFFC0, addr: ?, nextPc: 'h4},
            checkData: True,
            checkAddr: False
        };
        tests[17]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Srl, brFunc:?, dst: vDst(12),src1:?,src2:? , imm: 'h1},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h844,
            eInst: ExecInst{iType: OPIMM, dst: vDst(12), data: 'h22B1, addr: ?, nextPc: 'h848},
            checkData: True,
            checkAddr: False
        };
        tests[18]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Srl, brFunc:?, dst: vDst(23),src1:?,src2:? , imm: 'h2},
            rVal1: 'hFFFFFF00,
            rVal2: ?,
            pc: 'h0,
            eInst: ExecInst{iType: OPIMM, dst: vDst(23), data: 'h3FFFFFC0, addr: ?, nextPc: 'h4},
            checkData: True,
            checkAddr: False
        };
        tests[19]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Slt, brFunc:?, dst: vDst(12),src1:?,src2:? , imm: 'h1},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h844,
            eInst: ExecInst{iType: OPIMM, dst: vDst(12), data: 'h0, addr: ?, nextPc: 'h848},
            checkData: True,
            checkAddr: False
        };
        tests[20]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Slt, brFunc:?, dst: vDst(23),src1:?,src2:? , imm: 'h2},
            rVal1: 'hFFFFFF00,
            rVal2: ?,
            pc: 'h0,
            eInst: ExecInst{iType: OPIMM, dst: vDst(23), data: 'h1, addr: ?, nextPc: 'h4},
            checkData: True,
            checkAddr: False
        };
        tests[19]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Sltu, brFunc:?, dst: vDst(12),src1:?,src2:? , imm: 'h1},
            rVal1: 'h4562,
            rVal2: ?,
            pc: 'h844,
            eInst: ExecInst{iType: OPIMM, dst: vDst(12), data: 'h0, addr: ?, nextPc: 'h848},
            checkData: True,
            checkAddr: False
        };
        tests[20]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Sltu, brFunc:?, dst: vDst(23),src1:?,src2:? , imm: 'h2},
            rVal1: 'hFFFFFF00,
            rVal2: ?,
            pc: 'h0,
            eInst: ExecInst{iType: OPIMM, dst: vDst(23), data: 'h0, addr: ?, nextPc: 'h4},
            checkData: True,
            checkAddr: False
        };        
        tests[21]=ExecInstSpec{
            dInst:DecodedInst{iType: OPIMM, aluFunc:Sltu, brFunc:?, dst: vDst(23),src1:?,src2:? , imm: 'hFFFFFFFF},
            rVal1: 'hFFFFFF00,
            rVal2: ?,
            pc: 'h0,
            eInst: ExecInst{iType: OPIMM, dst: vDst(23), data: 'h1, addr: ?, nextPc: 'h4},
            checkData: True,
            checkAddr: False
        };
        tests[22]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Add, brFunc:?, dst: vDst(1),src1:?,src2:? , imm: ?},
            rVal1: 'h10,
            rVal2: 'h03,
            pc: 'h124,
            eInst: ExecInst{iType: OP, dst: vDst(1), data: 'h13, addr: ?, nextPc: 'h128},
            checkData: True,
            checkAddr: False
        };
        tests[23]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Sub, brFunc:?, dst: vDst(10),src1:?,src2:? , imm: ?},
            rVal1: 'h205,
            rVal2: 'h2,
            pc: 'h320,
            eInst: ExecInst{iType: OP, dst: vDst(10), data: 'h203, addr: ?, nextPc: 'h324},
            checkData: True,
            checkAddr: False
        };
        tests[24]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Add, brFunc:?, dst: vDst(27),src1:?,src2:? , imm: ?},
            rVal1: 'h4562,
            rVal2: 'h281,
            pc: 'h348,
            eInst: ExecInst{iType: OP, dst: vDst(27), data: 'h47E3, addr: ?, nextPc: 'h34C},
            checkData: True,
            checkAddr: False
        };
        tests[25]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:And, brFunc:?, dst: vDst(10),src1:?,src2:? , imm: ?},
            rVal1: 'h4562,
            rVal2: 'h281,
            pc: 'h348,
            eInst: ExecInst{iType: OP, dst: vDst(10), data: 'h0, addr: ?, nextPc: 'h34C},
            checkData: True,
            checkAddr: False
        };
        tests[26]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:And, brFunc:?, dst: vDst(5),src1:?,src2:? , imm: ?},
            rVal1: 'hFFFF,
            rVal2: 'hDEADBEEF,
            pc: 'h14,
            eInst: ExecInst{iType: OP, dst: vDst(5), data: 'hBEEF, addr: ?, nextPc: 'h18},
            checkData: True,
            checkAddr: False
        };
        tests[27]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Or, brFunc:?, dst: vDst(10),src1:?,src2:? , imm: ?},
            rVal1: 'h4562,
            rVal2: 'h253,
            pc: 'h348,
            eInst: ExecInst{iType: OP, dst: vDst(10), data: 'h4773, addr: ?, nextPc: 'h34C},
            checkData: True,
            checkAddr: False
        };
        tests[28]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Or, brFunc:?, dst: vDst(5),src1:?,src2:? , imm: ?},
            rVal1: 'hFFFF,
            rVal2: 'hDEADBEEF,
            pc: 'h14,
            eInst: ExecInst{iType: OP, dst: vDst(5), data: 'hDEADFFFF, addr: ?, nextPc: 'h18},
            checkData: True,
            checkAddr: False
        };
        tests[29]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Xor, brFunc:?, dst: vDst(17),src1:?,src2:? , imm: ?},
            rVal1: 'h4562,
            rVal2: 'h253,
            pc: 'h348,
            eInst: ExecInst{iType: OP, dst: vDst(17), data: 'h4731, addr: ?, nextPc: 'h34C},
            checkData: True,
            checkAddr: False
        };
        tests[30]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Xor, brFunc:?, dst: vDst(5),src1:?,src2:? , imm: ?},
            rVal1: 'hFFFF,
            rVal2: 'hDEADBEEF,
            pc: 'h14,
            eInst: ExecInst{iType: OP, dst: vDst(5), data: 'hDEAD4110, addr: ?, nextPc: 'h18},
            checkData: True,
            checkAddr: False
        };
        tests[31]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Sll, brFunc:?, dst: vDst(17),src1:?,src2:? , imm: ?},
            rVal1: 'h4562,
            rVal2: 'h1001,
            pc: 'h348,
            eInst: ExecInst{iType: OP, dst: vDst(17), data: 'h8AC4, addr: ?, nextPc: 'h34C},
            checkData: True,
            checkAddr: False
        };
        tests[32]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Sll, brFunc:?, dst: vDst(5),src1:?,src2:? , imm: ?},
            rVal1: 'hFFFF,
            rVal2: 'h3,
            pc: 'h14,
            eInst: ExecInst{iType: OP, dst: vDst(5), data: 'h7FFF8, addr: ?, nextPc: 'h18},
            checkData: True,
            checkAddr: False
        };
        tests[33]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Sra, brFunc:?, dst: vDst(12),src1:?,src2:? , imm: ?},
            rVal1: 'h4562,
            rVal2: 'h1,
            pc: 'h844,
            eInst: ExecInst{iType: OP, dst: vDst(12), data: 'h22B1, addr: ?, nextPc: 'h848},
            checkData: True,
            checkAddr: False
        };
        tests[34]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Sra, brFunc:?, dst: vDst(23),src1:?,src2:? , imm: ?},
            rVal1: 'hFFFFFF00,
            rVal2: 'hDEADB002,
            pc: 'h0,
            eInst: ExecInst{iType: OP, dst: vDst(23), data: 'hFFFFFFC0, addr: ?, nextPc: 'h4},
            checkData: True,
            checkAddr: False
        };
        tests[35]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Srl, brFunc:?, dst: vDst(12),src1:?,src2:? , imm: ?},
            rVal1: 'h4562,
            rVal2: 'h1,
            pc: 'h844,
            eInst: ExecInst{iType: OP, dst: vDst(12), data: 'h22B1, addr: ?, nextPc: 'h848},
            checkData: True,
            checkAddr: False
        };
        tests[36]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Srl, brFunc:?, dst: vDst(23),src1:?,src2:? , imm: ?},
            rVal1: 'hFFFFFF00,
            rVal2: 'h2,
            pc: 'h0,
            eInst: ExecInst{iType: OP, dst: vDst(23), data: 'h3FFFFFC0, addr: ?, nextPc: 'h4},
            checkData: True,
            checkAddr: False
        };
        tests[37]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Slt, brFunc:?, dst: vDst(12),src1:?,src2:? , imm: ?},
            rVal1: 'h4562,
            rVal2: 'h1,
            pc: 'h844,
            eInst: ExecInst{iType: OP, dst: vDst(12), data: 'h0, addr: ?, nextPc: 'h848},
            checkData: True,
            checkAddr: False
        };
        tests[38]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Slt, brFunc:?, dst: vDst(23),src1:?,src2:? , imm: ?},
            rVal1: 'hFFFFFF00,
            rVal2: 'h2,
            pc: 'h0,
            eInst: ExecInst{iType: OP, dst: vDst(23), data: 'h1, addr: ?, nextPc: 'h4},
            checkData: True,
            checkAddr: False
        };
        tests[39]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Sltu, brFunc:?, dst: vDst(12),src1:?,src2:? , imm: ?},
            rVal1: 'h4562,
            rVal2: 'h1,
            pc: 'h844,
            eInst: ExecInst{iType: OP, dst: vDst(12), data: 'h0, addr: ?, nextPc: 'h848},
            checkData: True,
            checkAddr: False
        };
        tests[40]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Sltu, brFunc:?, dst: vDst(23),src1:?,src2:? , imm: ?},
            rVal1: 'hFFFFFF00,
            rVal2: 'h2,
            pc: 'h0,
            eInst: ExecInst{iType: OP, dst: vDst(23), data: 'h0, addr: ?, nextPc: 'h4},
            checkData: True,
            checkAddr: False
        };        
        tests[41]=ExecInstSpec{
            dInst:DecodedInst{iType: OP, aluFunc:Sltu, brFunc:?, dst: vDst(23),src1:?,src2:? , imm: ?},
            rVal1: 'hFFFFFF00,
            rVal2: 'hFFFFFFFF,
            pc: 'h0,
            eInst: ExecInst{iType: OP, dst: vDst(23), data: 'h1, addr: ?, nextPc: 'h4},
            checkData: True,
            checkAddr: False
        };
        tests[42]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Eq, dst:Invalid,src1:?,src2:? , imm: 'hEC},
            rVal1: 'hFFFFFF00,
            rVal2: 'hFFFFFFFF,
            pc: 'h0,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h4},
            checkData: False,
            checkAddr: False
        };
        tests[43]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Eq, dst:Invalid,src1:?,src2:? , imm: 'hEC},
            rVal1: 'h428374,
            rVal2: 'h428374,
            pc: 'h1208,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h12F4},
            checkData: False,
            checkAddr: False
        };
        tests[44]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Eq, dst:Invalid,src1:?,src2:? , imm: -20},
            rVal1: 'h428374,
            rVal2: 'h428374,
            pc: 'h44,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h30},
            checkData: False,
            checkAddr: False
        };
        tests[45]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Neq, dst:Invalid,src1:?,src2:? , imm: 'hEC},
            rVal1: 'hFFFFFF00,
            rVal2: 'hFFFFFF00,
            pc: 'h0,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h4},
            checkData: False,
            checkAddr: False
        };
        tests[46]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Neq, dst:Invalid,src1:?,src2:? , imm: 'hEC},
            rVal1: 'h428374,
            rVal2: 'h428374,
            pc: 'h1208,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h120C},
            checkData: False,
            checkAddr: False
        };
        tests[47]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Neq, dst:Invalid,src1:?,src2:? , imm: -20},
            rVal1: 'h428374,
            rVal2: 'h428371,
            pc: 'h44,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h30},
            checkData: False,
            checkAddr: False
        };
        tests[48]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Lt, dst:Invalid,src1:?,src2:? , imm: 'hEC},
            rVal1: 'h7FFFFF00,
            rVal2: 'hFFFFFFFF,
            pc: 'h0,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h4},
            checkData: False,
            checkAddr: False
        };
        tests[49]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Lt, dst:Invalid,src1:?,src2:? , imm: 'hEC},
            rVal1: 'h428374,
            rVal2: 'h428374,
            pc: 'h1208,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h120C},
            checkData: False,
            checkAddr: False
        };
        tests[50]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Lt, dst:Invalid,src1:?,src2:? , imm: -20},
            rVal1: 'h428370,
            rVal2: 'h428374,
            pc: 'h44,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h30},
            checkData: False,
            checkAddr: False
        };
        tests[51]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Ge, dst:Invalid,src1:?,src2:? , imm: 'hEC},
            rVal1: 'h7FFFFF00,
            rVal2: 'hFFFFFFFF,
            pc: 'h0,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'hEC},
            checkData: False,
            checkAddr: False
        };
        tests[52]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Ge, dst:Invalid,src1:?,src2:? , imm: 'hEC},
            rVal1: 'h428374,
            rVal2: 'h428374,
            pc: 'h1208,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h12F4},
            checkData: False,
            checkAddr: False
        };
        tests[53]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Ge, dst:Invalid,src1:?,src2:? , imm: -20},
            rVal1: 'h428370,
            rVal2: 'h428374,
            pc: 'h44,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h48},
            checkData: False,
            checkAddr: False
        };
        tests[54]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Ltu, dst:Invalid,src1:?,src2:? , imm: 'hEC},
            rVal1: 'h7FFFFF00,
            rVal2: 'hFFFFFFFF,
            pc: 'h0,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'hEC},
            checkData: False,
            checkAddr: False
        };
        tests[55]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Ltu, dst:Invalid,src1:?,src2:? , imm: 'hEC},
            rVal1: 'h428374,
            rVal2: 'h428374,
            pc: 'h1208,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h120C},
            checkData: False,
            checkAddr: False
        };
        tests[56]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Ltu, dst:Invalid,src1:?,src2:? , imm: -20},
            rVal1: 'h428370,
            rVal2: 'h428374,
            pc: 'h44,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h30},
            checkData: False,
            checkAddr: False
        };
        tests[57]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Geu, dst:Invalid,src1:?,src2:? , imm: 'hEC},
            rVal1: 'h7FFFFF00,
            rVal2: 'hFFFFFFFF,
            pc: 'h0,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h4},
            checkData: False,
            checkAddr: False
        };
        tests[58]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Geu, dst:Invalid,src1:?,src2:? , imm: 'hEC},
            rVal1: 'h428374,
            rVal2: 'h428374,
            pc: 'h1208,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h12F4},
            checkData: False,
            checkAddr: False
        };
        tests[59]=ExecInstSpec{
            dInst:DecodedInst{iType: BRANCH, aluFunc:?, brFunc:Geu, dst:Invalid,src1:?,src2:? , imm: -20},
            rVal1: 'h428370,
            rVal2: 'h428374,
            pc: 'h44,
            eInst: ExecInst{iType: BRANCH, dst: Invalid, data: ?, addr: ?, nextPc: 'h48},
            checkData: False,
            checkAddr: False
        };
        tests[60]=ExecInstSpec{
            dInst:DecodedInst{iType: JAL, aluFunc:?, brFunc:?, dst:vDst(0),src1:?,src2:? , imm: -20},
            rVal1: ?,
            rVal2: ?,
            pc: 'h44,
            eInst: ExecInst{iType: JAL, dst: vDst(0), data: 'h48, addr: ?, nextPc: 'h30},
            checkData: True,
            checkAddr: False
        };
        tests[61]=ExecInstSpec{
            dInst:DecodedInst{iType: JAL, aluFunc:?, brFunc:?, dst:vDst(1),src1:?,src2:? , imm: 20},
            rVal1: ?,
            rVal2: ?,
            pc: 'h0,
            eInst: ExecInst{iType: JAL, dst: vDst(1), data: 'h4, addr: ?, nextPc: 'h14},
            checkData: True,
            checkAddr: False
        };
        tests[62]=ExecInstSpec{
            dInst:DecodedInst{iType: JAL, aluFunc:?, brFunc:?, dst:vDst(31),src1:?,src2:? , imm: 'hFFC},
            rVal1: ?,
            rVal2: ?,
            pc: 'h1234,
            eInst: ExecInst{iType: JAL, dst: vDst(31), data: 'h1238, addr: ?, nextPc: 'h2230},
            checkData: True,
            checkAddr: False
        };
        tests[63]=ExecInstSpec{
            dInst:DecodedInst{iType: AUIPC, aluFunc:?, brFunc:?, dst:vDst(0),src1:?,src2:? , imm: 'h00001000},
            rVal1: ?,
            rVal2: ?,
            pc: 'h44,
            eInst: ExecInst{iType: AUIPC,dst: vDst(0), data: 'h1044, addr: ?, nextPc: 'h48},
            checkData: True,
            checkAddr: False
        };
        tests[64]=ExecInstSpec{
            dInst:DecodedInst{iType: AUIPC, aluFunc:?, brFunc:?, dst:vDst(1),src1:?,src2:? , imm: 'hfffff000},
            rVal1: ?,
            rVal2: ?,
            pc: 'h1000,
            eInst: ExecInst{iType: AUIPC,dst: vDst(1), data: 'h0, addr: ?, nextPc: 'h1004},
            checkData: True,
            checkAddr: False
        };
        tests[65]=ExecInstSpec{
            dInst:DecodedInst{iType: AUIPC, aluFunc:?, brFunc:?, dst:vDst(31),src1:?,src2:? , imm: 'h12345000},
            rVal1: ?,
            rVal2: ?,
            pc: 'h1234,
            eInst: ExecInst{iType: AUIPC,dst: vDst(31), data: 'h12346234, addr: ?, nextPc: 'h1238},
            checkData: True,
            checkAddr: False
        };
        tests[66]=ExecInstSpec{
            dInst:DecodedInst{iType: LOAD, aluFunc:?, brFunc:?, dst:vDst(12),src1:?,src2:? , imm: 'h234},
            rVal1: 'h1000,
            rVal2: ?,
            pc: 'h44,
            eInst: ExecInst{iType: LOAD,dst: vDst(12), data: ?, addr: 'h1234, nextPc: 'h48},
            checkData: False,
            checkAddr: True
        };
        tests[67]=ExecInstSpec{
            dInst:DecodedInst{iType: LOAD, aluFunc:?, brFunc:?, dst:vDst(0),src1:?,src2:? , imm: -20},
            rVal1: 'h2014,
            rVal2: ?,
            pc: 'h124,
            eInst: ExecInst{iType: LOAD,dst: vDst(0), data: ?, addr: 'h2000, nextPc: 'h128},
            checkData: False,
            checkAddr: True
        };
        tests[68]=ExecInstSpec{
            dInst:DecodedInst{iType: LOAD, aluFunc:?, brFunc:?, dst:vDst(18),src1:?,src2:? , imm: 'h234},
            rVal1: 'h0FAD2020,
            rVal2: ?,
            pc: 'h500,
            eInst: ExecInst{iType: LOAD,dst: vDst(18), data: ?, addr: 'h0FAD2254, nextPc: 'h504},
            checkData: False,
            checkAddr: True
        };
        tests[69]=ExecInstSpec{
            dInst:DecodedInst{iType: STORE, aluFunc:?, brFunc:?, dst:Invalid,src1:?,src2:? , imm: 'h234},
            rVal1: 'h0FAD2020,
            rVal2: 'hB001234,
            pc: 'h500,
            eInst: ExecInst{iType: STORE,dst: Invalid, data: 'hB001234, addr: 'h0FAD2254, nextPc: 'h504},
            checkData: True,
            checkAddr: True
        };
        tests[70]=ExecInstSpec{
            dInst:DecodedInst{iType: STORE, aluFunc:?, brFunc:?, dst:Invalid,src1:?,src2:? , imm: -32},
            rVal1: 'h0FAD2020,
            rVal2: 'hB001234,
            pc: 'h10C,
            eInst: ExecInst{iType: STORE,dst: Invalid, data: 'hB001234, addr: 'h0FAD2000, nextPc: 'h110},
            checkData: True,
            checkAddr: True
        };
        tests[71]=ExecInstSpec{
            dInst:DecodedInst{iType: STORE, aluFunc:?, brFunc:?, dst:Invalid,src1:?,src2:? , imm: 'h0},
            rVal1: 'h1234,
            rVal2: 'h1235,
            pc: 'h428,
            eInst: ExecInst{iType: STORE,dst: Invalid, data: 'h1235, addr: 'h1234, nextPc: 'h42C},
            checkData: True,
            checkAddr: True
        };
        tests[72]=ExecInstSpec{
            dInst:DecodedInst{iType: JALR, aluFunc:?, brFunc:?, dst:vDst(0),src1:?,src2:? , imm: -19},
            rVal1: 'h1000,
            rVal2: ?,
            pc: 'h44,
            eInst: ExecInst{iType: JALR, dst: vDst(0), data: 'h48, addr: ?, nextPc: 'hFEC},
            checkData: True,
            checkAddr: False
        };
        tests[73]=ExecInstSpec{
            dInst:DecodedInst{iType: JALR, aluFunc:?, brFunc:?, dst:vDst(1),src1:?,src2:? , imm: 'h20},
            rVal1: 'h1234,
            rVal2: ?,
            pc: 'h0,
            eInst: ExecInst{iType: JALR, dst: vDst(1), data: 'h4, addr: ?, nextPc: 'h1254},
            checkData: True,
            checkAddr: False
        };
        tests[74]=ExecInstSpec{
            dInst:DecodedInst{iType: JALR, aluFunc:?, brFunc:?, dst:vDst(31),src1:?,src2:? , imm: 'h7FC},
            rVal1: 'h1234000,
            rVal2: ?,
            pc: 'h1234,
            eInst: ExecInst{iType: JALR, dst: vDst(31), data: 'h1238, addr: ?, nextPc: 'h12347FC},
            checkData: True,
            checkAddr: False
        };
        if (cycle == 75) begin
            $display("Passed Executing %d tests of iType ", iTypeCount, fshow(lastIType));
            // Last Test
            DecodedInst dInst = unpack(0);
            dInst.iType=Unsupported;
            ExecInst resultUn = execute(dInst,1234,5678,1200);
            if(resultUn.iType==Unsupported) begin
                $display("Passed Executing   1 tests of iType ",fshow(Unsupported));
                $display("PASSED");
            end
            else begin
                $display("Failed Execute function");
                $display("Input:");
                $display("Decoded Instruction: ", fshow(dInst));
                $display("Value 1            : ", fshow(1234));
                $display("Value 2            : ", fshow(5678));
                $display("PC                 : ", fshow(1200));
                $display("Your Execute Result: ", fshow(resultUn));
                $display("FAILED: Expect iType to be Unsupported");
            end
            $finish;
            
        end

        let spec = tests[cycle];
        ExecInst result = execute(spec.dInst,spec.rVal1,spec.rVal2,spec.pc);
        ExecInst expected = spec.eInst;
        if(expected.iType!=result.iType ||
            expected.dst!=result.dst || 
            (spec.checkData && expected.data!=result.data) || 
            (spec.checkAddr && expected.addr!=result.addr) || 
            expected.nextPc!=result.nextPc) begin
            $display("Failed Execute function");
            $display("Input:");
            $display("Decoded Instruction: ", fshow(spec.dInst));
            $display("Value 1            : ", fshow(spec.rVal1));
            $display("Value 2            : ", fshow(spec.rVal2));
            $display("PC                 : ", fshow(spec.pc));
            if(!spec.checkData) begin
                $display("Ignoring Data field");
                result.data='hDEADBEEF;
                expected.data='hDEADBEEF;
            end
            if(!spec.checkAddr) begin
                $display("Ignoring Address field");
                result.addr='hDEADBEEF;
                expected.addr='hDEADBEEF;
            end
            $display("Your Execute Result: ", fshow(result));
            $display("Expected Result    : ", fshow(expected));

            $display("FAILED");
            $finish;
        end
        if (lastIType == spec.eInst.iType) begin
            iTypeCount <= iTypeCount + 1;
        end else begin
	    $display("Passed Executing %d tests of iType ",iTypeCount,fshow(lastIType));
            iTypeCount <= 1;
        end
        lastIType <= spec.eInst.iType;
        cycle <= cycle + 1;
    endrule
endmodule
