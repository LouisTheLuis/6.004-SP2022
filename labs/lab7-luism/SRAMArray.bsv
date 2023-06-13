// BSV glue code for single-ported, non-loaded BRAM memory
import BRAMCore::*;

typedef BRAM_PORT#(Bit#(addrSz), dataT) SRAMArray#(numeric type addrSz, type dataT);

module mkSRAMArray(SRAMArray#(addrSz, dataT) ) provisos (Bits#(dataT, dataSz));
    Integer memSz = valueOf(TExp#(addrSz));
    Bool hasOutputRegister = False;
    BRAM_PORT#(Bit#(addrSz), dataT) bram <- mkBRAMCore1(memSz, hasOutputRegister);
    return bram;
endmodule
