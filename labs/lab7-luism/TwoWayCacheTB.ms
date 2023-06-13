import TwoWayCache;
import Microtests;
import Beveren;

module TwoWayMicrotest;
    //type of cache, number of ways, verbose = True;
    Microtest#(TwoWayCache, 2) bt(True);
endmodule

module TwoWayBeveren;
    //type of cache, number of ways, verbose = True
    Beveren#(TwoWayCache, 2) bt(True);
endmodule

module TwoWayMicrotestAutograde;
    //type of cache, number of ways, verbose = False;
    Microtest#(TwoWayCache, 2) bt(False);
endmodule

module TwoWayBeverenAutograde;
    //type of cache, number of ways, verbose = False
    Beveren#(TwoWayCache, 2) bt(False);
endmodule
