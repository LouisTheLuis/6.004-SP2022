import CacheTypes;
import CacheHelpers;
import MainMemory;

// ReqStatus (defined in CacheTypes.ms) is used to keep track of the state of the current request
//typedef enum {
//    Ready,         // The cache is ready for a new request
//    Lookup,        // Issued a lookup to tag/data arrays
//    Writeback,     // In main memory access for dirty writeback
//    Fill           // In main memory access for requested data
//} ReqStatus;
//
// Possible flows:
//   HIT: Ready -> Lookup -> Ready
//   MISS, line is clean: Ready -> Lookup -> Fill
//   MISS, line is dirty: Ready -> Lookup -> Writeback -> Fill

// Cache SRAM Synonyms (defined in CacheTypes.ms)
// You may find the following type synonyms helpful to access the tag/data/status arrays
// typedef SRAMReq#(logCacheSets, CacheTag) TagReq;
// typedef SRAMReq#(logCacheSets, Line) DataReq;
// typedef SRAMReq#(logCacheSets, CacheStatus) StatusReq;

// TODO: Complete the implementation of TwoWayCache
// NOTE: Implementing this module requires about 20 new lines of code from DirectMappedCache
module TwoWayCache(MainMemory mainMem);
    // SRAM arrays, one element per way (e.g., dataArrays[0] is the data array of way 0).
    Vector#(2, SRAM#(logCacheSets, Line)) dataArrays;
    Vector#(2, SRAM#(logCacheSets, CacheTag)) tagArrays;
    Vector#(2, SRAM#(logCacheSets, CacheStatus)) statusArrays;

    // LRU bits, one per set. We implement it as registers instead of an SRAM
    // array, because with small caches this is just a few bits (e.g., 64), and
    // SRAMs make sense only for larger memories. This also makes the code
    // simpler, and will make the cache easier to pipeline in the future.
    Vector#(cacheSets, RegU#(Bit#(1))) lru;

    // Registers for holding the current state of the cache and how far along
    // it is in processing a request.
    RegU#(MemReq) curReq;
    Reg#(ReqStatus) state(Ready);
 
    // Hit/miss counters
    Reg#(Word) hits(0);
    Reg#(Word) misses(0);
    
    input Maybe#(MemReq) req default = Invalid;
    
    // TODO return True if the cache can accept a new request
    method Bool reqEnabled = (state == Ready) ? True : False;

    // TODO return True if the cache is in lookup and it is a hit in this way.
    function Bool isHit(Integer way);
	return ((state == Lookup) && (fromMaybe(?, tagArrays[way].data) == getTag(curReq.addr)) && (fromMaybe(?, statusArrays[way].data) != NotValid)) ? True : False;
    endfunction

    rule tick;
        if (state == Ready && isValid(req)) begin
            let r = fromMaybe(?, req);
	    for (Integer i = 0; i < 2; i = i + 1) begin
		dataArrays[i].req = Valid(DataReq{addr: getIndex(r.addr), write: False, data: ?});
                tagArrays[i].req = Valid(TagReq{addr: getIndex(r.addr), write: False, data: ?});
                statusArrays[i].req = Valid(StatusReq{addr: getIndex(r.addr), write: False, data: ?});
	    end
            curReq <= r;
            state <= Lookup;
        end else if (state == Lookup) begin
	    Bit#(1) hitBit = 0;
	    Bit#(1) dirtyBit = 0;
	    Bool hitted = False;
	    Bool dirty = False;

	    for (Integer i = 0; i < 2; i = i + 1) begin 
            	let rdata = fromMaybe(?, dataArrays[i].data);
            	let rtag = fromMaybe(?, tagArrays[i].data);
            	let rstatus = fromMaybe(?, statusArrays[i].data);
            	if (rtag == getTag(curReq.addr) && rstatus != NotValid) begin
			hitted = True;
                	hitBit = (i == 0) ? 0 : 1;
            	end else if (rstatus == Dirty) begin
			dirtyBit = (i == 0) ? 0 : 1;
			if (lru[getIndex(curReq.addr)] == dirtyBit) begin 
                	    dirty = True;
			end
            	end
	    end

	    if (hitted) begin
		hits <= hits + 1;
		state <= Ready;
                if (curReq.op == St) begin
		    let rdata = fromMaybe(?, dataArrays[hitBit].data);
                    rdata[getWordOffset(curReq.addr)] = curReq.data;
                    dataArrays[hitBit].req = Valid(DataReq{addr: getIndex(curReq.addr), write: True, data: rdata});
                    statusArrays[hitBit].req = Valid(StatusReq{addr: getIndex(curReq.addr), write: True, data: Dirty});
		end
		lru[getIndex(curReq.addr)] <= ~hitBit;
	    end else begin
		if (dirty) begin
		    let rdata = fromMaybe(?, dataArrays[lru[getIndex(curReq.addr)]].data);
		    let rtag = fromMaybe(?, tagArrays[lru[getIndex(curReq.addr)]].data);
		    mainMem.req = Valid(LineReq{lineAddr: getLineAddr({rtag, curReq.addr[1 + logWordsPerLine + logCacheSets : 0]}), op: St, data: rdata});
		    misses <= misses + 1;
		    state <= Writeback;
		end else begin
		    mainMem.req = Valid(LineReq{lineAddr: getLineAddr(curReq.addr), op: Ld, data: ?});
		    misses <= misses + 1;
		    state <= Fill;
		end
	    end

        end else if (state == Writeback && mainMem.reqEnabled) begin
            mainMem.req = Valid(LineReq{lineAddr: getLineAddr(curReq.addr), op: Ld, data: ?});
            state <= Fill;
        end else if (state == Fill && isValid(mainMem.data)) begin
            let rMemdata = fromMaybe(?, mainMem.data);
            state <= Ready;
            if (curReq.op == St) begin
              rMemdata[getWordOffset(curReq.addr)] = curReq.data;
              dataArrays[lru[getIndex(curReq.addr)]].req = Valid(DataReq{addr: getIndex(curReq.addr), write: True, data: rMemdata});
              statusArrays[lru[getIndex(curReq.addr)]].req = Valid(StatusReq{addr: getIndex(curReq.addr), write: True, data: Dirty});
              tagArrays[lru[getIndex(curReq.addr)]].req = Valid(TagReq{addr: getIndex(curReq.addr), write: True, data: getTag(curReq.addr)});
	      lru[getIndex(curReq.addr)] <= ~lru[getIndex(curReq.addr)];
            end else begin
              dataArrays[lru[getIndex(curReq.addr)]].req = Valid(DataReq{addr: getIndex(curReq.addr), write: True, data: rMemdata});
              statusArrays[lru[getIndex(curReq.addr)]].req = Valid(StatusReq{addr: getIndex(curReq.addr), write: True, data: Clean});
              tagArrays[lru[getIndex(curReq.addr)]].req = Valid(TagReq{addr: getIndex(curReq.addr), write: True, data: getTag(curReq.addr)});
	      lru[getIndex(curReq.addr)] <= ~lru[getIndex(curReq.addr)];
           end
        end
    endrule

    method Maybe#(Word) data;
        // This method should return a Valid output in only two cases:
        // 1. On a load hit (it is a hit, and curReq.op == Ld).
        // 2. On a fill for a load request (we're in the Fill state,
        //    mainMem.data is valid, and curReq.op == Ld).
        // In all other cases, the output should be Invalid
        //
        // NOTE: You should be checking the above conditions explicitly in
        //    THIS method so you can return data as soon as possible.
        //    DO NOT place your output into a register in the rule and then
        //    simply return that register here.

        // This function should take about 4-8 lines of code to implement.
        if (curReq.op == Ld && (isHit(0) || isHit(1))) begin
	    Bit#(1) index = (isHit(0)) ? 0 : 1;
            let rdata = fromMaybe(?, dataArrays[index].data);
            return Valid(rdata[getWordOffset(curReq.addr)]);
        end else if (state == Fill && isValid(mainMem.data) && curReq.op == Ld) begin
            let rMemdata = fromMaybe(?, mainMem.data);
            return Valid(rMemdata[getWordOffset(curReq.addr)]);
        end else begin
            return Invalid;
        end
    endmethod

    method Bit#(32) getHits = hits;
    method Bit#(32) getMisses = misses;
endmodule
