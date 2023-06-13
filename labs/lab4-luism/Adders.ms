import ALU;

function Bit#(4) add4_rca(Bit#(4) a, Bit#(4) b);
    return rca#(4)(a, b, 0);
endfunction

function Bit#(4) add4_addSub(Bit#(4) a, Bit#(4) b);
    return addSub#(4)(a, b, 0);
endfunction
