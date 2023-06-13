import Randomizable::*;

interface RandomizeWrapped#(type t);
    method t next;
    method Action init;
endinterface

typedef RandomizeWrapped#(t) GenericRandomizerWrapped#(type t);

module mkGenericRandomizerWrapped(RandomizeWrapped#(t))
    provisos(Bounded#(t), Bits#(t, a__));
    Randomize#(t) randomizer <- mkGenericRandomizer;
    Wire#(t) nextOut <- mkDWire(?); 

    rule internal;
        let nextOut_val <- randomizer.next();
        nextOut <= nextOut_val;
    endrule

    method t next;
        return nextOut;
    endmethod

    method Action init;
        randomizer.cntrl.init;
    endmethod
endmodule