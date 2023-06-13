import MainMemory;
import CacheTypes;
bsvimport LFSR;
bsvimport FeedLFSR;

typedef enum { Running, Fail, Check } TermState;

module Beveren#(type CacheType, Integer wayNum)(Bool verbose);
    Bit#(65) feed = 0;
    feed[64] = 1;
    feed[46] = 1;
    feed[0] = 1;
    FeedLFSR#(Bit#(65)) randomMem(feed);

    MainMemory realMainMem;
    CacheType cache(realMainMem);
    WordMem mem;
    Reg#(Bit#(32)) cycle(0); 
    Reg#(Bit#(32)) counterIn(0); 
    Reg#(Bit#(32)) counterOut(0);
    //Manual request counters
    Reg#(Bit#(4)) manualRequestCounter(0);
    Reg#(Bool) doinit(True);
    Reg#(MemReq) curReq(MemReq{addr: 0, op: Ld, data: 0});
    Reg#(TermState) termState(Running);
    Reg#(Bool) waitingOnLoad(False);
    Reg#(Bit#(32)) loadTime(0);
 
    rule tick;
        // We delay termination to capture what happens within the last cycle
        if (termState == Fail) $finish;
        if (termState == Check) begin
            let hit = cache.getHits;
            let miss = cache.getMisses;
            if (verbose) $display("hit = %d, miss = %d, total = %d", hit, miss, hit+miss);
            if (wayNum == 1) begin
                // NOTE(dsm): In the original (BSV) Beveren, counts were 24887/75139 b/c the cache was mis-initialized
                // (we initialize all arrays to invalid, which causes no hits on the initial cache values)
                if (hit == 24886 && miss == 75139)begin
                    Bit#(32) expectedCycles= 32'd6216520;
                    Bit#(32) toleranceError= 32'd621652;//=10%
                    let cycleBound = expectedCycles + toleranceError;
                    if (cycle >= cycleBound) begin
                        if (verbose) $display("Your cache outputs the correct values but takes too many cycles. You currently take %d cycles, but to pass it must be under %d. You are probably making extra requests to main memory.", cycle, cycleBound);
                        $display("FAILED - Too many cycles");
                    end else $display("PASSED\n");
                    
                end
                else begin
                    if (verbose) $display("Your direct-mapped cache has correct responses but incorrect hit/miss count.\n{hit, miss} = {%d, %d} instead of expected {24886, 75139}\n", hit, miss, "You probably did not implement a miss-allocate cache");
                    $display("FAILED - Incorrect hit and/or miss count");
                end
            end else if (wayNum == 2) begin
                if (hit == 49646 && miss == 50379)begin
                    Bit#(32) expectedCycles= 32'd4474106;
                    Bit#(32) toleranceError= 32'd447410;//=10%
                    let cycleBound = expectedCycles + toleranceError;
                    if (cycle >= cycleBound) begin
                        if (verbose) $display("Your cache outputs the correct values but takes too many cycles. You currently take %d cycles, but to pass it must be under %d. You are probably making extra requests to main memory.", cycle, cycleBound);
                        $display("FAILED - Too many cycles");
                    end else $display("PASSED\n");
                end
                else begin
                    if (verbose) $display("Your two-way set-associative cache has correct responses but incorrect hit/miss count.\n{hit, miss} = {%d, %d} instead of expected {49646, 50379}\n", hit, miss, "You probably did not implement LRU replacement policy correctly");
		                $display("FAILED - Incorrect hit and/or miss count");
		            end
            end else $display("Microtests wayNum %d has not been defined.", wayNum);
            $finish;
        end

        let isCacheValid = isValid(cache.data);
        let readyForNewReq = (cache.reqEnabled && counterIn <= 50000 && !waitingOnLoad);
        if (doinit) begin
            randomMem.seed(signExtend(64'hdeadbeefdeadbeef));
            doinit <= False;
        end else begin
            // Normal operation
            MemReq nextReq = curReq;
            if (readyForNewReq) begin
                // loadTime reset
                loadTime <= 0;
                
                // The below should be impossible for an unpipelined cache.
                if (isCacheValid) begin
                    $display("FAILED - A Ld instruction caused the cache to return valid data for multiple cycles in a row. Check to make sure you are not putting your output into a register, and that you are only returning valid data under the appropriate conditions.");
                    $finish;
                end
                else begin
                    let newrand = randomMem.value;
                    randomMem.next;
                    MemReq newreq = unpack(newrand);
                    newreq.addr = {0, newreq.addr[13:2],2'b0};
                    
                    if (newreq.op == Ld) begin
                        waitingOnLoad <= True;
                        counterIn <= counterIn + 1;
                    end

                    cache.req = Valid(newreq);
                    nextReq = newreq;
                    if (verbose) $display("[%d] Request ", cycle, fshow(nextReq));
                end
            end
            if (isCacheValid) begin
                waitingOnLoad <= False;
                counterOut <= counterOut + 1; 
                if (verbose) $display("[%d] Got responses %d ", cycle, counterOut, fshow(curReq));
                let resp1 = fromMaybe(?, cache.data());
                if (!isValid(mem.data)) begin
                    $display("FAILED - Valid cache data but invalid mem data!");
                    $finish;
                end
                let resp2 = fromMaybe(?, mem.data);
                if (resp1 != resp2) begin
                    if (verbose) $display("The cache answered %x instead of %x\n", resp1, resp2);
                    $display("FAILED - Cache returned incorrect value\n");
                    termState <= Fail;
                end else if (counterOut == 49999) begin
                    // Do final hit/miss check and finish
                    termState <= Check;
                end
            end

            // We always reissue the same request to the memory model; that way we always have the right data without needing to latch anything
            mem.req = Valid(nextReq);
            curReq <= nextReq;
            //$display("mem out ", fshow(mem.data));
        end

        if (waitingOnLoad) begin
            loadTime <= loadTime + 1;        
            if (loadTime > 200) begin // arbitrary timeout
                $display("FAILED - Cache takes too long to return a result for a Ld instruction. You probably have a problem with your data method.");
                $finish;
            end
        end

        cycle <= cycle + 1;
    endrule
endmodule
