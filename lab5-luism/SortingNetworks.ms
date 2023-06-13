// All sorting networks sort unsigned 32-bit words
typedef Bit#(32) Word;

/* Combinational n-element Bitonic Sorting Network
 *
 * The following functions use four built-in functions on vectors:
 * 1.- take() takes elements starting from the front of the vector.
 *     For example, if v is a Vector#(8, Word),
 *        Vector#(2, Word) f = take(v);
 *     will make f have the first two elements of v (v[0] and v[1]).
 * 2.- takeTail() takes element from the back (i.e., tail) of the vector.
 *     For example, if v is a Vector#(8, Word),
 *        Vector#(2, Word) b = takeTail(v);
 *     will make b have the last two elements of v (v[6] and v[7]).
 * 3.- reverse() reverses the elements of a vector.
 *     For example, if v is a Vector#(4, Word),
 *        Vector#(4, Word) r = reverse(v);
 *     will make r have r[0] = v[3], r[1] = v[2], r[2] = v[1], and r[3] = v[0].
 * 4.- append() concatenates two vectors, creating a single vector
 *     with the sum of their lengths.  
 */ 
function Vector#(n, Word) bitonicSort#(Integer n)(Vector#(n, Word) in);
    if (n <= 1) begin
        return in;
    end else begin
    	Vector#(n/2, Word) lower = take(in); // lower = first n/2 elements of in
    	Vector#(n-n/2, Word) upper = takeTail(in); // upper = last n-n/2 elements of in

    	// Sort lower and upper
    	let lower_sorted = bitonicSort#(n/2)(lower);
        let upper_sorted = bitonicSort#(n-n/2)(upper);

        // Reverse the sorted upper half
        let upper_sorted_reversed = reverse(upper_sorted);

        let vector_to_merge = append(lower_sorted, upper_sorted_reversed);
        return bitonicMerge#(n)(vector_to_merge);
    end
endfunction

function Vector#(n, Word) bitonicMerge#(Integer n)(Vector#(n, Word) x);
    if (n <= 1) begin
        return x;
    end else begin
        let s = x;
        for (Integer i = 0; i < n/2; i = i + 1) begin
            Integer j = i + n/2;
            if (x[i] > x[j]) begin
                s[i] = x[j];
                s[j] = x[i];
            end
        end

        Vector#(n/2, Word) lower = take(s); // lower = first n/2 elements of s
    	Vector#(n-n/2, Word) upper = takeTail(s); // upper = last n-n/2 elements of s

    	// Merge lower and upper, then return their concatenation
        let lower_merged = bitonicMerge#(n/2)(lower);
        let upper_merged = bitonicMerge#(n-n/2)(upper);
        return append(lower_merged, upper_merged);
    end
endfunction


// Description: Pipelined 8-element Word sorting network
// TODO: Implement this module in Exercise 4
// NOTE: Depending on which implementation strategy you choose (see
// hints in handout), implementing this module and its submodules
// requires about 40-70 lines of code. Much of this code directly
// corresponds to code in the combinational sorting network.
module BitonicSorter8;
    // Instantiate your submodules here
    BitonicSorter#(8) result;

    // When there is a new vector of elements to sort, they
    // will be passed in as a valid vector.
    input Maybe#(Vector#(8, Word)) in default = Invalid;

    // If 6 cycles ago (the number of pipeline stages) the module had
    // a valid input, getOutput should return a valid vector with
    // those input elements in sorted (ascending) order. If 6 cycles
    // ago the input was Invalid, getOutput should return Invalid.
    method Maybe#(Vector#(8, Word)) getOutput;
	return result.getOutput;
    endmethod

    rule tick;
        result.in = in;
    endrule
endmodule

module BitonicSorter#(Integer n);
    BitonicSorter#(n/2) lower;
    BitonicSorter#(n/2) upper;
    BitonicMerger#(n) total;

    input Maybe#(Vector#(n, Word)) in default = Invalid; 

    method Maybe#(Vector#(n, Word)) getOutput = total.getOutput;

    rule tick;
	lower.in = (isValid(in)) ? Valid(take(fromMaybe(?, in))) : Invalid;
	upper.in = (isValid(in)) ? Valid(takeTail(fromMaybe(?, in))) : Invalid;
        let temp = (isValid(upper.getOutput)) ? Valid(reverse(fromMaybe(?, upper.getOutput))) : Invalid;
        total.in = (isValid(lower.getOutput) && isValid(upper.getOutput)) ? Valid(append(fromMaybe(?, lower.getOutput), fromMaybe(?, temp))) : Invalid;
    endrule
endmodule

module BitonicMerger#(Integer n);
    Reg#(Maybe#(Vector#(n, Word))) result(Invalid);    

    BitonicMerger#(n/2) lower;
    BitonicMerger#(n/2) upper;

    input Maybe#(Vector#(n, Word)) in default = Invalid;

    method Maybe#(Vector#(n, Word)) getOutput = 
	(isValid(lower.getOutput) && isValid(upper.getOutput)) ? 
	Valid(append(fromMaybe(?, lower.getOutput), fromMaybe(?, upper.getOutput))) : Invalid;

    rule tick;
	let s = fromMaybe(?, in);
	let x = fromMaybe(?, in);
	if (isValid(in)) begin
           for (Integer i = 0; i < n/2; i = i + 1) begin
               Integer j = i + n/2;
               if (x[i] > x[j]) begin
                   s[i] = x[j];
                   s[j] = x[i];
               end
           end
	end
	result <= (isValid(in)) ? Valid(s) : Invalid;
        lower.in = (isValid(result)) ? Valid(take(fromMaybe(?, result))) : Invalid;
        upper.in = (isValid(result)) ? Valid(takeTail(fromMaybe(?, result))) : Invalid;
    endrule
endmodule

module BitonicSorter#(2);
    Reg#(Maybe#(Vector#(2, Word))) result(Invalid);

    input Maybe#(Vector#(2, Word)) in default = Invalid;

    method Maybe#(Vector#(2, Word)) getOutput =
        (isValid(result)) ? Valid(fromMaybe(?, result)) : Invalid;

    rule tick;
        let temp = fromMaybe(?, in);
        if (isValid(in)) begin
            result <= (temp[0] > temp[1]) ? Valid(reverse(fromMaybe(?, in))) : Valid(fromMaybe(?, in));
        end else begin
	    result <= Invalid;
        end
    endrule   
endmodule

module BitonicMerger#(2);
    Reg#(Maybe#(Vector#(2, Word))) result(Invalid);

    input Maybe#(Vector#(2, Word)) in default = Invalid;

    method Maybe#(Vector#(2, Word)) getOutput = 
	(isValid(result)) ? Valid(fromMaybe(?, result)) : Invalid;

    rule tick;
        let temp = fromMaybe(?, in);
    	if (isValid(in)) begin
	    result <= (temp[0] > temp[1]) ? Valid(reverse(fromMaybe(?, in))) : Valid(fromMaybe(?, in));
	end else begin
	    result <= Invalid;
        end
    endrule
endmodule
