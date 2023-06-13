import Common;

// bit_scan_reverse
// TODO: how many of each kind of gates did you use?
// # and1 = 2
// # or1 = 2
// # xor1 = 0
// # not1 = 2
// # multiplexer1 = 0

function Bit#(2) bit_scan_reverse(Bit#(4) a);
    Bit#(1) first = or1(a[3], a[2]);
    Bit#(1) second = or1(a[3], and1(not1(a[3]), and1(not1(a[2]), a[1])));
    Bit#(2) ret = {first, second};
    return ret;
endfunction


// is_power_of_2
// TODO: how many of each kind of gates did you use?
// # and1 = 12
// # or1 = 3
// # xor1 = 0
// # not1 = 12
// # multiplexer1 = 0

function Bit#(1) is_power_of_2(Bit#(4) a);
    Bit#(1) first = and1(and1(a[3], not1(a[2])), and1(not1(a[1]), not1(a[0])));
    Bit#(1) second = and1(and1(not1(a[3]), a[2]), and1(not1(a[1]), not1(a[0])));
    Bit#(1) third = and1(and1(not1(a[3]), not1(a[2])), and1(a[1], not1(a[0])));
    Bit#(1) fourth = and1(and1(not1(a[3]), not1(a[2])), and1(not1(a[1]), a[0]));
    Bit#(1) ret = or1(or1(first, second), or1(third, fourth));
    return ret;
endfunction


// log_of_power_of_2
// TODO: how many of each kind of gates did you use?
// # and1 = 14
// # or1 = 5
// # xor1 = 0
// # not1 = 14
// # multiplexer1 = 2

function Bit#(2) log_of_power_of_2(Bit#(4) a);
    Bit#(2) log = bit_scan_reverse(a);
    Bit#(2) zeroes = 2'b00;
    Bit#(1) power = is_power_of_2(a);
    Bit#(2) ret = {multiplexer1(power, zeroes[1], log[1]), multiplexer1(power, zeroes[0], log[0])};
    return ret;
endfunction


function Bit#(1) equal(Bit#(8) a, Bit#(8) b);
    Bit#(1) one = not1(xor1(a[7], b[7]));
    Bit#(1) two = not1(xor1(a[6], b[6]));
    Bit#(1) three = not1(xor1(a[5], b[5]));
    Bit#(1) four = not1(xor1(a[4], b[4]));
    Bit#(1) five = not1(xor1(a[3], b[3]));
    Bit#(1) six = not1(xor1(a[2], b[2]));
    Bit#(1) seven = not1(xor1(a[1], b[1]));
    Bit#(1) eight = not1(xor1(a[0], b[0]));

    Bit#(1) ret = and1(and1(and1(one, two), and1(three, four)), and1(and1(five, six), and1(seven, eight)));
    return ret;
endfunction


function Bit#(4) vector_equal(Bit#(32) a, Bit#(32) b);
    Bit#(4) ret = {equal(a[31:24], b[31:24]), equal(a[23:16], b[23:16]), equal(a[15:8], b[15:8]), equal(a[7:0], b[7:0])};
    return ret;
endfunction


function Bit#(7) seven_segment_decoder(Bit#(4) input_binary_number);
    Bit#(7) ret = case(input_binary_number)
        4'b0000 : 7'b1111110;
	4'b0001 : 7'b0110000;
        4'b0010 : 7'b1101101;
        4'b0011 : 7'b1111001;
        4'b0100 : 7'b0110011;
        4'b0101 : 7'b1011011;
        4'b0110 : 7'b1011111;
        4'b0111 : 7'b1110000;
        4'b1000 : 7'b1111111;
        4'b1001 : 7'b1111011;
        default : 7'b1001111;       // value for "E"
    endcase;
    return ret;
endfunction


// THESE TWO FUNCTIONS BELOW BELONG TO THE FULL ADDER
// **************************************************
function Bit#(2) fullAdder(Bit#(1) a, Bit#(1) b, Bit#(1) cin);
    Bit#(1) s = xor1(xor1(a, b), cin);
    Bit#(1) cout = or1(or1(and1(a, b), and1(a, cin)), and1(b, cin));
    return {cout, s};
endfunction

function Bit#(3) rca2(Bit#(2) a, Bit#(2) b, Bit#(1) cin);
    Bit#(2) lower = fullAdder(a[0], b[0], cin);
    Bit#(2) upper = fullAdder(a[1], b[1], lower[1]);
    return {upper, lower[0]};
endfunction
//***************************************************
//***************************************************


function Bit#(3) population_count(Bit#(4) in);
    Bit#(1) first = 1'b0;
    Bit#(2) second = fullAdder(in[3], first, 1'b0);
    Bit#(2) third = fullAdder(in[2], second[0], second[1]);
    Bit#(3) fourth = rca2({1'b0, in[1]}, third, 1'b0);
    Bit#(3) ret = rca2({1'b0, in[0]}, fourth[1:0], fourth[2]);
    return ret;
endfunction


function Bit#(1) is_geq_one(Bit#(1) a, Bit#(1) b);
    Bit#(1) ret = or1(a, and1(not1(a), not1(b)));
    return ret;
endfunction

function Bit#(1) is_geq_two(Bit#(2) a, Bit#(2) b);
    Bit#(1) first = is_geq_one(a[1], b[1]);                                       
    Bit#(1) some = not1(xor1(a[1], b[1]));                                         
    Bit#(1) ret = multiplexer1(first, 1'b0, multiplexer1(some, first, is_geq_one(a[0], b[0])));     
    return ret;
endfunction

function Bit#(1) is_eq(Bit#(2) a, Bit#(2) b);
    Bit#(1) first = not1(xor1(a[0], b[0]));
    Bit#(1) second = not1(xor1(a[1], b[1]));
    Bit#(1) ret = and1(first, second);
    return ret;
endfunction

function Bit#(1) is_geq(Bit#(4) a, Bit#(4) b);
    Bit#(1) first = is_geq_two(a[3:2], b[3:2]);
    Bit#(1) second = is_geq_two(a[1:0], b[1:0]);
    Bit#(1) ret = multiplexer1(is_eq(a[3:2], b[3:2]), first, second); 
    return ret;
endfunction

// Demo code below here. Do not modify
function Bit#(1) parity4(Bit#(4) n);
    return xor1(xor1(xor1(n[0], n[1]), n[2]), n[3]);
endfunction
