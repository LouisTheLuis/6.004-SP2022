import MainMemory;
import CacheTypes;

module Microtest#(type CacheType, Integer wayNum) (Bool verbose);

    MainMemory realMainMem;
    CacheType cache(realMainMem);
    WordMem mem;
    Reg#(Bit#(32)) cycle(0); 
    //Manual request counters
    Reg#(Bit#(5)) requestCounter(0);
    Reg#(MemReq) curReq(MemReq{addr: 0, op: Ld, data: 0}); 
    Reg#(Bit#(32)) loadTime(0);

    rule tick;
        MemReq nextReq = curReq;
        let hits = cache.getHits; let misses = cache.getMisses;
        Bit#(32) expectedHits = 0; Bit#(32) expectedMisses = 0; 
        if (cache.reqEnabled) begin
            // Reset loadTime counter
            loadTime <= 0;

            //manually generated test cases
            
            if (requestCounter <= 26) begin //TODO replace with the number of test cases
                //define inputs
                nextReq = case(requestCounter)
                    // (Direct map / Two-way)
                    5'b0:  MemReq{op: St, addr: {'b0,  6'b10, 4'b1111, 2'b00}, data: 'habcd};
                    5'd1:  MemReq{op: Ld, addr: {'b0,  6'b10, 4'b1111, 2'b00}, data: ?};
                    5'd2:  MemReq{op: Ld, addr: {'b1,  6'b10, 4'b0101, 2'b00}, data: ?};
                    5'd3:  MemReq{op: St, addr: {'b0,  6'b10, 4'b0001, 2'b00}, data: 'hbeefbeef};
                    5'd4:  MemReq{op: Ld, addr: {'b0,  6'b10, 4'b1111, 2'b00}, data: ?};
                    5'd5:  MemReq{op: St, addr: {'b0,  6'b10, 4'b1111, 2'b00}, data: 'hbeee};
                    5'd6:  MemReq{op: St, addr: {'b0,  6'b10, 4'b1000, 2'b00}, data: 'hcede};
                    5'd7:  MemReq{op: Ld, addr: {'b0,  6'b10, 4'b1111, 2'b00}, data: ?};
                    5'd8:  MemReq{op: St, addr: {'b11, 6'b10, 4'b0111, 2'b00}, data: 'hfeebbeef};
                    5'd9:  MemReq{op: St, addr: {'b0,  6'b10, 4'b1010, 2'b00}, data: 'h6004};
                    5'd10: MemReq{op: Ld, addr: {'b11, 6'b10, 4'b0111, 2'b00}, data: ?};
                    5'd11: MemReq{op: Ld, addr: {'b1,  6'b10, 4'b0101, 2'b00}, data: ?};
                    5'd12: MemReq{op: Ld, addr: {'b0,  6'b10, 4'b1010, 2'b00}, data: ?};
                    5'd13: MemReq{op: St, addr: {'b0,  6'b11, 4'b1111, 2'b00}, data: 'hdede};
                    5'd14: MemReq{op: Ld, addr: {'b0,  6'b11, 4'b1111, 2'b00}, data: ?};

                    // yes, aaaaa. That seems to be what the compiler defaults to.
                    5'd15: MemReq{op: Ld, addr: {'haaaaa,  6'b00, 4'b0000, 2'b00}, data: ?};

                    // explicitly test for updating lru bit on a hit
                    5'd16: MemReq{op: St, addr: {'b10,  6'b01, 4'b0100, 2'b00}, data: 'hf00d};
                    5'd17: MemReq{op: St, addr: {'b01,  6'b01, 4'b0100, 2'b00}, data: 'hbaaa};
                    5'd18: MemReq{op: Ld, addr: {'b10,  6'b01, 4'b0100, 2'b00}, data: ?};
                    5'd19: MemReq{op: Ld, addr: {'b11,  6'b01, 4'b0100, 2'b00}, data: ?};
                    5'd20: MemReq{op: Ld, addr: {'b01,  6'b01, 4'b0100, 2'b00}, data: ?};

                    // more tests toggling lru bit
                    5'd21: MemReq{op: St, addr: {'b11,  6'b01, 4'b0100, 2'b00}, data: 'hbead};
                    5'd22: MemReq{op: Ld, addr: {'b01,  6'b01, 4'b0100, 2'b01}, data: ?};
                    5'd23: MemReq{op: Ld, addr: {'b01,  6'b01, 4'b0100, 2'b10}, data: ?};
                    5'd24: MemReq{op: St, addr: {'b11,  6'b01, 4'b0100, 2'b11}, data: 'hdeed};
                    5'd25: MemReq{op: St, addr: {'b111, 6'b01, 4'b0100, 2'b00}, data: 'habcdef};
                    5'd26: MemReq{op: Ld, addr: {'b11,  6'b01, 4'b0100, 2'b00}, data: ?};
                endcase;
                requestCounter <= requestCounter +1;
            end
            //make request
            //Before setting the input to the next request, check that hit/miss count is correct so far
            let hitMissErrorMessage = "";
            if (requestCounter <= 27) begin
                if (wayNum == 1) begin
                    // Testing manual responses for Direct mapped
                    case (requestCounter)  //checks when receiving a response for the requestCounter-1
                        5'd0: begin
                            expectedHits=0;expectedMisses=0;
                            hitMissErrorMessage="Initialization error."; 
                        end //Initial state
                        5'd1: begin
                            expectedHits=0;expectedMisses=1;
                            hitMissErrorMessage="Expected a Store Miss.";
                        end
                        5'd2: begin
                            expectedHits=1;expectedMisses=1;
                            hitMissErrorMessage="Expected a Load Hit. Make sure that a previous Miss evicted the corresponding line.";
                        end
                        5'd3: begin
                            expectedHits=1;expectedMisses=2;
                            hitMissErrorMessage="Expected a Load Miss.";
                        end
                        5'd4: begin
                            expectedHits=1;expectedMisses=3;
                            hitMissErrorMessage="Expected a Clean Store Miss. Make sure that your cache goes from Lookup to Fill state and not into Writeback.";
                        end
                        5'd5: begin
                            expectedHits=2;expectedMisses=3;
                            hitMissErrorMessage="Expected a Load Hit.";
                        end
                        5'd6: begin
                            expectedHits=3;expectedMisses=3;
                            hitMissErrorMessage="Expected a Store Hit.";
                        end
                        5'd7: begin
                            expectedHits=4;expectedMisses=3;
                            hitMissErrorMessage="Expected a Store Hit.";
                        end
                        5'd8: begin
                            expectedHits=5;expectedMisses=3;
                            hitMissErrorMessage="Expected a Load Hit.";
                        end
                        5'd9: begin
                            expectedHits=5;expectedMisses=4;
                            hitMissErrorMessage="Expected a Dirty Store Miss. Make sure that your cache goes into Writeback and Fill state when the line evicted is dirty.";
                        end
                        5'd10: begin
                            expectedHits=5;expectedMisses=5;
                            hitMissErrorMessage="Expected a Dirty Store Miss. Make sure that your cache goes into Writeback and Fill state when the line evicted is dirty.";
                        end
                        5'd11: begin
                            expectedHits=5;expectedMisses=6;
                            hitMissErrorMessage="Expected a Dirty Load Miss. Make sure that your cache goes into Writeback and Fill state when the line evicted is dirty.";
                        end
                        5'd12:begin
                            expectedHits=5;expectedMisses=7;
                            hitMissErrorMessage="Expected a Clean Load Miss. Make sure that your cache goes from Lookup to Fill state and not into Writeback.";
                        end
                        5'd13:begin
                            expectedHits=5;expectedMisses=8;
                            hitMissErrorMessage="Expected a Clean Load Miss. Make sure that your cache goes from Lookup to Fill state and not into Writeback.";
                        end
                        5'd14: begin
                            expectedHits=5;expectedMisses=9;
                            hitMissErrorMessage="Expected a Store Miss. Are you sure that you are using the correct request data to index into the cache in the Ready state?";
                        end
                        5'd15: begin
                            expectedHits=6;expectedMisses=9;
                            hitMissErrorMessage="Expected a Load Hit. Make sure that a previous Miss evicted the corresponding line.";
                        end
                        5'd16: begin
                            expectedHits=6;expectedMisses=10;
                            hitMissErrorMessage="Expected a Clean Load Miss. Make sure that you are checking that the line is either Clean or Dirty";
                        end
                        5'd17:begin
                            expectedHits=6;expectedMisses=11;
                            hitMissErrorMessage="Expected a Clean Store Miss. Make sure that your cache goes from Lookup to Fill state and not into Writeback.";
                        end
                        5'd18:begin
                            expectedHits=6;expectedMisses=12;
                            hitMissErrorMessage="Expected a Dirty Store Miss. Make sure that your cache goes into Writeback and Fill state when the line evicted is dirty.";
                        end
                        5'd19:begin
                            expectedHits=6;expectedMisses=13;
                            hitMissErrorMessage="Expected a Dirty Load Miss. Make sure that your cache goes into Writeback and Fill state when the line evicted is dirty.";
                        end
                        5'd20:begin
                            expectedHits=6;expectedMisses=14;
                            hitMissErrorMessage="Expected a Clean Load Miss. Make sure that your cache goes from Lookup to Fill state and not into Writeback.";
                        end
                        5'd21:begin
                            expectedHits=6;expectedMisses=15;
                            hitMissErrorMessage="Expected a Clean Load Miss. Make sure that your cache goes from Lookup to Fill state and not into Writeback.";
                        end
                        5'd22:begin
                            expectedHits=6;expectedMisses=16;
                            hitMissErrorMessage="Expected a Clean Store Miss. Make sure that your cache goes from Lookup to Fill state and not into Writeback.";
                        end
                        5'd23:begin
                            expectedHits=6;expectedMisses=17;
                            hitMissErrorMessage="Expected a Dirty Load Miss. Make sure that your cache goes into Writeback and Fill state when the line evicted is dirty.";
                        end
                        5'd24:begin
                            expectedHits=7;expectedMisses=17;
                            hitMissErrorMessage="Expected a Load Hit.";
                        end
                        5'd25:begin
                            expectedHits=7;expectedMisses=18;
                            hitMissErrorMessage="Expected a Clean Load Miss. Make sure that your cache goes from Lookup to Fill state and not into Writeback.";
                        end
                        5'd26:begin
                            expectedHits=7;expectedMisses=19;
                            hitMissErrorMessage="Expected a Dirty Store Miss. Make sure that your cache goes into Writeback and Fill state when the line evicted is dirty.";
                        end
                        5'd27:begin
                            expectedHits=7;expectedMisses=20;
                            hitMissErrorMessage="Expected a Dirty Load Miss. Make sure that your cache goes into Writeback and Fill state when the line evicted is dirty.";
                        end
                    endcase
                end else if (wayNum == 2) begin
                    //Testing manual responses for TwoWay
                    case(requestCounter)  //checks when receiving a response for the requestCounter-1
                        5'd0:   begin
                            expectedHits = 0; expectedMisses = 0;
                            hitMissErrorMessage="Initialization error";
                        end //Initial state
                        5'd1:   begin
                            expectedHits = 0; expectedMisses = 1;
                            hitMissErrorMessage="Expected a Store Miss. Make sure that your cache goes into Writeback and Fill state when the line evicted is dirty.";
                        end
                        5'd2:   begin
                            expectedHits = 1; expectedMisses = 1;
                            hitMissErrorMessage="Expected a Load Hit.";
                        end
                        5'd3:   begin
                            expectedHits = 1; expectedMisses = 2;
                            hitMissErrorMessage="Expected a Load Miss. Make sure that your cache goes into Writeback and Fill state when the line evicted is dirty.";
                        end
                        5'd4:   begin
                            expectedHits = 2; expectedMisses = 2;
                            hitMissErrorMessage="Expected a Store Hit.";
                        end
                        5'd5:   begin
                            expectedHits = 3; expectedMisses = 2;
                            hitMissErrorMessage="Expected a Load Hit.";
                        end
                        5'd6:   begin
                            expectedHits = 4; expectedMisses = 2;
                            hitMissErrorMessage="Expected a Store Hit.";
                        end
                        5'd7:   begin
                            expectedHits = 5; expectedMisses = 2;
                            hitMissErrorMessage="Expected a Store Hit.";
                        end
                        5'd8:   begin
                            expectedHits = 6; expectedMisses = 2;
                            hitMissErrorMessage="Expected a Load Hit.";
                        end
                        5'd9:   begin
                            expectedHits = 6; expectedMisses = 3;
                            hitMissErrorMessage="Expected a Clean Store Miss. Make sure that your cache goes from Lookup to Fill state and not into Writeback.";
                        end
                        5'd10:   begin
                            expectedHits = 7; expectedMisses = 3;
                            hitMissErrorMessage="Expected a Store Hit.";
                        end
                        5'd11:   begin
                            expectedHits = 8; expectedMisses = 3;
                            hitMissErrorMessage="Expected a Load Hit.";
                        end
                        5'd12:  begin
                            expectedHits = 8; expectedMisses = 4;
                            hitMissErrorMessage="Expected a Dirty Load Miss. Make sure that your cache goes into Writeback and Fill state when the line evicted is dirty.";
                        end
                        5'd13:  begin
                            expectedHits = 8; expectedMisses = 5;
                            hitMissErrorMessage="Expected a Dirty Load Miss. Make sure that your cache goes into Writeback and Fill state when the line evicted is dirty.";
                        end
                        5'd14:  begin
                            expectedHits = 8; expectedMisses = 6;
                            hitMissErrorMessage="Expected a Store Miss. Make sure that your cache goes into Writeback and Fill state when the line evicted is dirty.";
                        end
                        5'd15:  begin
                            expectedHits = 9; expectedMisses = 6;
                            hitMissErrorMessage="Expected a Load Hit.";
                        end
                        5'd16: begin
                            expectedHits = 9; expectedMisses = 7;
                            hitMissErrorMessage="Expected a Clean Load Miss. Make sure that you are checking that the line is either Clean or Dirty";
                        end
                        5'd17:begin
                            expectedHits = 9; expectedMisses = 8;
                            hitMissErrorMessage="Expected a Clean Store Miss. Make sure that your cache goes from Lookup to Fill state and not into Writeback.";
                        end
                        5'd18:begin
                            expectedHits = 9; expectedMisses = 9;
                            hitMissErrorMessage="Expected a Dirty Store Miss. Make sure that your cache goes into Writeback and Fill state when the line evicted is dirty.";
                        end
                        5'd19:begin
                            expectedHits = 10; expectedMisses = 9;
                            hitMissErrorMessage="Expected a Load Hit.";
                        end
                        5'd20:begin
                            expectedHits = 10; expectedMisses = 10;
                            hitMissErrorMessage="Expected a Clean Load Miss. Make sure that your cache goes from Lookup to Fill state and not into Writeback.";
                        end
                        5'd21:begin
                            expectedHits = 10; expectedMisses = 11;
                            hitMissErrorMessage="Expected a Clean Load Miss. Make sure that your cache goes from Lookup to Fill state and not into Writeback. Also make sure that you update the LRU bit on a hit";
                        end
                        5'd22:begin
                            expectedHits = 11; expectedMisses = 11;
                            hitMissErrorMessage="Expected a Store Hit.";
                        end
                        5'd23:begin
                            expectedHits = 12; expectedMisses = 11;
                            hitMissErrorMessage="Expected a Load Hit.";
                        end
                        5'd24:begin
                            expectedHits = 13; expectedMisses = 11;
                            hitMissErrorMessage="Expected a Load Hit.";
                        end
                        5'd25:begin
                            expectedHits = 14; expectedMisses = 11;
                            hitMissErrorMessage="Expected a Store Hit.";
                        end
                        5'd26:begin
                            expectedHits = 14; expectedMisses = 12;
                            hitMissErrorMessage="Expected a Dirty Store Miss. Make sure that your cache goes into Writeback and Fill state when the line evicted is dirty.";
                        end
                        5'd27:begin
                            expectedHits = 15; expectedMisses = 12;
                            hitMissErrorMessage="Expected a Load Hit.";
                        end
                    endcase
                end else begin
                    $display("Microtests wayNum %d has not been defined.", wayNum);
                    $finish;
                end

                if (verbose) begin
                    $display("Got:      hit = %d, miss = %d, total = %d", hits, misses, hits+misses);
                    $display("Expected: hit = %d, miss = %d, total = %d", expectedHits, expectedMisses, expectedHits + expectedMisses); 
                end

                let hitsMatch = (hits != expectedHits) || (misses != expectedMisses);
                if(hitsMatch) begin
                    //error output and finish
                    if(verbose) begin 
                        $display(hitMissErrorMessage);
                        if (expectedHits + expectedMisses == 0) begin
                            $display("Remember to update the hits and miss count and to output them in the getHits and getMisses method");
                        end
                    end
                    $display("FAILED - Incorrect hit and/or miss count");
                    $finish;
                end
                if (requestCounter == 27) begin
                    Bit#(32) expectedCycles = 0;
                    Bit#(32) toleranceError = 0;

                    if (wayNum == 1) begin
                        expectedCycles = 32'd1531;
                        toleranceError = 32'd153; //~10%
                    end else begin //wayNum ==2
                        expectedCycles = 32'd867;
                        toleranceError = 32'd87;  //=10%
                    end
                    let cycleBound = expectedCycles + toleranceError;
                    if (cycle >= cycleBound) begin
                        //too many cycles
                        if(verbose) $display("Your cache outputs the correct values but takes too many cycles. You currently take %d cycles, but to pass it must be under %d. You are probably making extra requests to main memory.", cycle, cycleBound);
                        $display("FAILED - Too many cycles");
                    end else $display("PASSED");
                    $finish;
                end
            end

            //Send next request
            cache.req = Valid(nextReq);
            if (verbose) $display("[Cycle %d] [Request %d] ", cycle, requestCounter, fshow(nextReq));
        end
        else loadTime <= loadTime + 1;

        if (loadTime > 200) begin // arbitrary timeout of 200 cycles
            $display("FAILED - cache.reqEnabled does not return True after 200 cycles. Are you sure you implemented reqEnabled?");
            $finish;
        end

        if (isValid(cache.data)) begin
            //define valueError message
            let valueErrorMessage = "";
            if (wayNum == 1) begin
                //Testing manual responses for Direct map
                valueErrorMessage = case(requestCounter)  //checks when receiving a response for the requestCounter-1
                    5'd0: "";
                    5'd1: "";
                    5'd2: "Make sure that Store operations modify the state of the cache by making write requests to SRAM.";
                    5'd3: "Make sure that you are reading the appropriate address in Main Memory.";
                    5'd4: "";
                    5'd5: "Make sure that Store operations modify the state of the cache by making write requests to SRAM. On cache misses, are you using the correct tag/data values when issuing read/write requests to main memory?";
                    5'd6: "";
                    5'd7: "Make sure that Store operations modify the state of the cache by making write requests to SRAM. On cache misses, are you using the correct tag/data values when issuing read/write requests to main memory?";
                    5'd8: "Make sure that Store operations modify the state of the cache by making write requests to SRAM. On cache misses, are you using the correct tag/data values when issuing read/write requests to main memory? If your cache is returning the wrong value, are you sure that you are using the right data overwrite the current cache data on a store hit?";
                    5'd9: "";
                    5'd10: "";
                    5'd11:"Make sure that when a line is evicted from the cache, it is written back to main memory.";
                    5'd12:"Make sure that when a line is evicted from the cache, it is written back to main memory.";
                    5'd13:"Make sure that when a line is evicted from the cache, it is written back to main memory.";
                    5'd14: "";
                    5'd15: "Make sure that Store operations modify the state of the cache by making write requests to SRAM.";
                    5'd19: "Make sure that when a line is evicted from the cache, it is written back to main memory.";
                    5'd21: "Make sure that when a line is evicted from the cache, it is written back to main memory.";
                    5'd23: "Make sure that when a line is evicted from the cache, it is written back to main memory.";
                    5'd24: "Make sure that when a line is evicted from the cache, it is written back to main memory.";
                    5'd27: "Make sure that when a line is evicted from the cache, it is written back to main memory.";
                    default: "";
                endcase;
            end else if (wayNum == 2) begin
                //Testing manual responses for Two way map
                valueErrorMessage = case(requestCounter)  //checks when receiving a response for the requestCounter-1
                    5'd0: "";
                    5'd1: "";
                    5'd2: "Make sure that Store operations modify the state of the cache by making write requests to SRAM.";
                    5'd3: "Make sure that you are reading the appropriate address in Main Memory.";
                    5'd4: "";
                    5'd5: "Make sure that Store operations modify the state of the cache by making write requests to SRAM. On cache misses, are you using the correct tag/data values when issuing read/write requests to main memory? If your cache is returning the wrong value, are you sure that you are using the right data overwrite the current cache data on a store hit?";
                    5'd6: "";
                    5'd7: "Make sure that Store operations modify the state of the cache by making write requests to SRAM. On cache misses, are you using the correct tag/data values when issuing read/write requests to main memory?";
                    5'd8: "Make sure that Store operations modify the state of the cache by making write requests to SRAM. On cache misses, are you using the correct tag/data values when issuing read/write requests to main memory? If your cache is returning the wrong value, are you sure that you are using the right data overwrite the current cache data on a store hit?";
                    5'd9: "";
                    5'd10: "";
                    5'd11: "Make sure that Store operations modify the state of the cache by making write requests to SRAM. On cache misses, are you using the correct tag/data values when issuing read/write requests to main memory?";
                    5'd12:"Make sure that when a line is evicted from the cache, it is written back to main memory.";
                    5'd13:"Make sure that when a line is evicted from the cache, it is written back to main memory.";
                    5'd14: "";
                    5'd15: "Make sure that Store operations modify the state of the cache by making write requests to SRAM. On cache misses, are you using the correct tag/data values when issuing read/write requests to main memory?";
                    5'd19: "Make sure that Store operations modify the state of the cache by making write requests to SRAM.";
                    5'd21: "Make sure that when a line is evicted from the cache, it is written back to main memory.";
                    5'd23: "Make sure that Store operations modify the state of the cache by making write requests to SRAM.";
                    5'd24: "Make sure that Store operations modify the state of the cache by making write requests to SRAM.";
                    5'd27: "Make sure that Store operations modify the state of the cache by making write requests to SRAM.";
                    default:"";
                endcase;
            end

            if (verbose) $display("[Cycle %d] Got responses ", cycle, fshow(curReq));
            let resp1 = fromMaybe(?, cache.data());
            if (!isValid(mem.data)) begin
                $display("FAILED - Valid cache data but invalid mem data! Make sure store operations don't output valid data. Also, are you sure that you are initializing curReq correctly for a valid input?");
                $finish;
            end
            let resp2 = fromMaybe(?, mem.data);
            if (resp1 != resp2) begin
                if (verbose) begin
                    $display("The cache answered %x instead of %x\n", resp1, resp2);
                    $display(valueErrorMessage);
                end
                $display("FAILED - Cache returned incorrect value");
                $finish;
            end
        end

        // We always reissue the same request to the memory model; that way we always have the right data without needing to latch anything
        mem.req = Valid(nextReq);
        curReq <= nextReq;
        cycle <= cycle + 1;
    endrule
endmodule
