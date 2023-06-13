// Thin wrapper for a RegFileFullLoad with a Minispec-compatible interface.
// Do not edit or the magic will disappear!

import RegFile::*;

typedef struct {
    Bit#(14) idx;
    Bit#(32) data;
} ArrayWriteReq deriving (Bits, Eq, FShow);

interface MagicMemoryArray;
    method Bit#(32) sub(Bit#(14) idx);
    method Action upd___input(ArrayWriteReq req);
endinterface

module mkMagicMemoryArray#(String memfile) (MagicMemoryArray);
    RegFile#(Bit#(14), Bit#(32)) arr <- mkRegFileFullLoad(memfile);

    method Bit#(32) sub(Bit#(14) idx) = arr.sub(idx);

    method Action upd___input(ArrayWriteReq req);
        arr.upd(req.idx, req.data);
    endmethod
endmodule
