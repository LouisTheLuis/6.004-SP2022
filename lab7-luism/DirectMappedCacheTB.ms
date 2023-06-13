import DirectMappedCache;
import Microtests;
import Beveren;

module DirectMappedMicrotest;
    //type of cache, number of ways, verbose = True;
    Microtest#(DirectMappedCache, 1) bt(True);
endmodule

module DirectMappedBeveren;
    //type of cache, number of ways, verbose = True
    Beveren#(DirectMappedCache, 1) bt(True);
endmodule

//For autograding

module DirectMappedMicrotestAutograde;
    //type of cache, number of ways, verbose = False;
    Microtest#(DirectMappedCache, 1) bt(False);
endmodule

module DirectMappedBeverenAutograde;
    //type of cache, number of ways, verbose = False
    Beveren#(DirectMappedCache, 1) bt(False);
endmodule
