import CacheTypes;
import SRAM;
bsvimport Assert;

// Ideal 1-cycle line memory, used internally by main memory
module LineMem;
    Integer bytesPerLine = 4 * wordsPerLine;
    Integer memBytes = 1 << 24; // 16 MB
    Integer memLines = memBytes / bytesPerLine;
    Integer addrBits = log2(memLines);
    SRAM#(addrBits, Line) ram;

    input Maybe#(LineReq) req default = Invalid;
    method Maybe#(Line) data = ram.data;

    rule tick;
        if (isValid(req)) begin
            let r = fromMaybe(?, req);
            ram.req = Valid(SRAMReq#(addrBits, Line){
                addr: truncate(r.lineAddr), write: r.op == St, data: r.data
            });
        end
    endrule
endmodule

// To emulate DRAM technology, MainMemory uses a line-based memory and adds a 50-cycle delay
module MainMemory;
    LineMem lineMem;
    Integer latency = 50;

    Reg#(Bit#(log2(latency) + 1)) cyclesLeft(0);
    RegU#(LineReq) curReq;

    method Bool reqEnabled = (cyclesLeft == 0);
    input Maybe#(LineReq) req default = Invalid;

    method Maybe#(Line) data = lineMem.data;

    rule tick;
        dynamicAssert(!((cyclesLeft != 0) && isValid(req)), "MainMemory received request while not ready!\n\n");
        if (cyclesLeft != 0) cyclesLeft <= cyclesLeft - 1;
        if (cyclesLeft == 0 && isValid(req)) begin
            cyclesLeft <= latency;
            curReq <= fromMaybe(?, req);
        end
        if (cyclesLeft == 1) lineMem.req = Valid(curReq);
        //$display("DRAM: cyclesLeft = %d curReq ", cyclesLeft, fshow(curReq));
        //if (isValid(lineMem.data)) $display("DRAM: Data ", fshow(lineMem.data));
    endrule
endmodule

// Single-cycle word memory, used as ideal memory by the tests
module WordMem;
    Integer memBytes = 1 << 24;  // 16 MB
    Integer memWords = memBytes / 4;
    Integer addrBits = log2(memWords);
    SRAM#(addrBits, Word) ram;

    input Maybe#(MemReq) req default = Invalid;
    method Maybe#(Word) data = ram.data;

    rule tick;
        if (isValid(req)) begin
            let r = fromMaybe(?, req);
            ram.req = Valid(SRAMReq#(addrBits, Word){
                addr: truncate(r.addr >> 2), write: r.op == St, data: r.data
            });
        end
    endrule
endmodule
