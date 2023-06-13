// Description: Returns the absolute value of a
// 16-bit two's complement number
function Bit#(16) abs(Bit#(16) in);
  if (in[15] == 1'b1) begin
    return -in;
  end else begin
    return in;
  end
endfunction

// Description: Adds 10 to a value
function Bit#(16) add10(Bit#(16) a);
  return a + 10;
endfunction

// Description: Divides an input by 3
function Bit#(16) divide3(Bit#(16) a);
  return a / 3;
endfunction

// Description: Multiplies the input by 7
function Bit#(16) multiply7(Bit#(16) a);
  return a * 7;
endfunction
