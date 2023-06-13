// Two inputs to an n-bit multiplier.
typedef struct {
    Bit#(n) a;
    Bit#(n) b; 
} MultiplierInput#( Integer n ); 

// Reference functions that use the '*' operator
function Bit#(2*n) multiply_unsigned#(Integer n)(Bit#(n) a, Bit#(n) b);
    return zeroExtend(a) * zeroExtend(b);
endfunction

function Bit#(2*n) multiply_signed#(Integer n)(Bit#(n) a, Bit#(n) b);
    Int#(n) a_int = unpack(a);
    Int#(n) b_int = unpack(b);
    Int#(2*n) product_int = signExtend(a_int) * signExtend(b_int);
    return pack(product_int);
endfunction

// Multiplication by repeated addition
function Bit#(2*n) multiply_by_adding#(Integer n)(Bit#(n) a, Bit#(n) b);
    Bit#(2*n) tp = 0;
    for (Integer i = 0; i < n; i = i + 1) begin
	Bit#(n) mi = (a[i] == 0) ? 0 : b;
        Bit#(n+1) tpi = zeroExtend(mi) + tp[i+n:i];
	tp = (i == 0) ? zeroExtend(tpi) : {zeroExtend(tpi), tp[i-1:0]}; 
    end
    return tp;
endfunction

// Folded multiplier by repeated addition
module FoldedMultiplier#(Integer n);
    RegU#(Bit#(n)) a;
    RegU#(Bit#(n)) b;
    RegU#(Bit#(n)) prod;
    Reg#(Maybe#(Bit#(log2(n)+1))) counter(Invalid);

    // When there is a new pair of numbers to multiply, they
    // will be passed in as a valid MultiplierInput.
    input Maybe#(MultiplierInput#(n))
        in default = Invalid;

    rule mulStep;
	if (isValid(in)) begin
	   let args = fromMaybe(?, in);
	   a <= args.a;
	   b <= args.b;
	   prod <= 0;
	   counter <= Valid(n);
	end else if (isValid(counter) && fromMaybe(?, counter) > 0) begin
	   Bit#(n+1) tp = {1'b0, prod} + (a[0] == 1 ? zeroExtend(b) : 0);
	   prod <= tp[n:1];
           a <= {tp[0], a[n-1:1]};
           counter <= Valid(fromMaybe(?, counter) - 1);
	end
    endrule

    // getResult should return the most recent multiplication result,
    // or Invalid if the multiplier is calculating the next result.
    // If no input has been given yet, the result should be Invalid.
    method Maybe#(Bit#(2*n)) getResult = 
	(isValid(counter) && fromMaybe(?, counter) == 0) ? Valid({prod, a}) : Invalid;
endmodule

// Fast folded multiplier by repeated addition
module FastFoldedMultiplier#( Integer n );
    RegU#(Bit#(n)) a;
    RegU#(Bit#(n)) b;
    RegU#(Bit#(n)) prod;
    Reg#(Maybe#(Bit#(log2(n)+1))) counter(Invalid); // This is a Maybe type

    // When there is a new pair of numbers to multiply, they
    // will be passed in as a valid MultiplierInput.
    input Maybe#(MultiplierInput#(n))
        in default = Invalid;

    rule mulStep;
        if (isValid(in)) begin
           let args = fromMaybe(?, in);
           a <= args.a;
           b <= args.b;
           prod <= 0;
           counter <= Valid(n);
        end else if (isValid(counter) && fromMaybe(?, counter) > 0) begin
           Bit#(n+1) tp = {1'b0, prod} + (a[0] == 1 ? zeroExtend(b) : 0);
           prod <= tp[n:1];
           a <= {tp[0], a[n-1:1]};
           counter <= Valid(fromMaybe(?, counter) - 1);
        end
    endrule

    // getResult should return the most recent multiplication result,
    // or Invalid if the multiplier is calculating the next result.
    // If no input has been given yet, the result should be Invalid.
    method Maybe#(Bit#(2*n)) getResult =
	(isValid(counter) && fromMaybe(?, counter) == 0) ? Valid({prod, a}) : Invalid;
endmodule
