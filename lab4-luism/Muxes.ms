function Bit#(2) mux2_sop(Bit#(1) sel, Bit#(2) a, Bit#(2) b);
    Bit#(2) sel2 = {sel, sel};
    return (sel2 & a) | (~sel2 & b);
endfunction

function Bit#(2) mux2_select(Bit#(1) sel, Bit#(2) a, Bit#(2) b);
    return (sel == 1)? a : b;
endfunction

function Bit#(2) mux2_if(Bit#(1) sel, Bit#(2) a, Bit#(2) b);
    Bit#(2) ret = 0;
    if (sel == 1) begin
        ret = a;
    end else begin
        ret = b;
    end
    return ret;
endfunction

function Bit#(2) mux2_case(Bit#(1) sel, Bit#(2) a, Bit#(2) b);
    Bit#(2) ret = 0;
    case (sel)
        1:  ret = a;
        0:  ret = b;
    endcase
    return ret;
endfunction


function Bit#(n) mux#(Integer n)(Bit#(1) sel, Bit#(n) a, Bit#(n) b);
    return (sel == 1)? a : b;
endfunction
