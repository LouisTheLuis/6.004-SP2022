import SortingTests;
import SortingNetworks;

// Custom vector formatting (in decimal rather than fshow's hex)
function Fmt fshowMV8(Maybe#(Vector#(8, Word)) vec);
    if (isValid(vec)) begin
        let d = fromMaybe(?,vec);
        return $format("Valid([%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d])",
            d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7]);
    end else return $format("Invalid");
endfunction

module BitonicSorter8Test;
    TbBitonicSorter#(1) bt;
endmodule

module BitonicSorter8DebugTest;
    TbBitonicSorter#(2) bt;
endmodule

module BitonicSorterTest;
    // For the autograder
    TbBitonicSorter#(0) bt;
endmodule 

module TbBitonicSorter#(Integer verbose); // 0 = off, 1 = normal, 2 = very verbose (debug)
    BitonicSorter8 sorter;
    SortingTests tests;

    Reg#(Bit#(5)) cycle(0);
    Reg#(Bit#(4)) numTestsOK(0);
    Reg#(Bit#(1)) didFail(0);

    Integer numTests = 12;
    Integer pipeDelay = 6;

    rule tick;
        // run tests
        if (cycle == numTests + pipeDelay + 5) begin
            if (didFail == 0) begin
                if (verbose > 0) $display("PASSED %0d test cases", numTestsOK);
                else $display("PASSED");
            end else $display("FAILED");
            $finish;
        end
        else begin
            cycle <= cycle + 1;
            let test = tests.getTest(cycle);
            sorter.in = test;
            if (verbose == 2) begin
                $display("[cycle %d] SENDING: ", cycle, fshowMV8(test));
            end
        end

        // check tests
        let received = sorter.getOutput;
        let expected = tests.getRes(cycle - pipeDelay);

        if (verbose == 2) begin
            $display("[cycle %d] RECEIVED: ", cycle, fshowMV8(received));
            $display("[cycle %d] EXPECTED: ", cycle, fshowMV8(expected));
        end

        if (cycle >= pipeDelay && cycle < numTests + pipeDelay) begin
            if (received == expected) begin
                numTestsOK <= numTestsOK + 1;
                if (verbose > 0) $display("Lab5.BitonicSorter_Test%0d: PASSED", cycle - pipeDelay);
            end else begin
                didFail <= 1;
                if (verbose > 0) $display("Lab5.BitonicSorter_Test%0d: FAILED incorrect result", cycle - pipeDelay);
                if (verbose == 1) begin
                    $display("CYCLE: ", cycle);
                    $display("RECEIVED: ", fshowMV8(received));
                    $display("EXPECTED: ", fshowMV8(expected));
                end
            end
        end else begin
            if (isValid(received)) begin
                didFail <= 1;
                if (verbose > 0) begin
                    $display("Lab5.BitonicSorter_Test%0d: FAILED invalid answer given", cycle - pipeDelay);
                    $display("sorter presented a Valid result on cycle %0d, expected Invalid", cycle);
                end
            end
        end
    endrule
endmodule
