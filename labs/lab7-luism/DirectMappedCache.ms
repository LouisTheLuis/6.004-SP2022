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
//typedef SRAMReq#(logCacheSets, CacheTag) TagReq;
//typedef SRAMReq#(logCacheSets, Line) DataReq;
//typedef SRAMReq#(logCacheSets, CacheStatus) StatusReq;

// TODO: Complete the implementation of DirectMappedCache
// NOTE: Implementing this module requires about 50 lines of additional code
// (~40 lines in rule tick, ~5-10 lines in method data, 1 line in method reqEnabled, 1 line in function isHit)
module DirectMappedCache(MainMemory mainMem);
    // SRAM arrays. Note that, for a direct-mapped cache,
    // number of cache sets == number of cache lines
    SRAM#(logCacheSets, Line) dataArray;
    SRAM#(logCacheSets, CacheTag) tagArray;
    SRAM#(logCacheSets, CacheStatus) statusArray;
    
    // Registers for holding the current state of the cache and how far along
    // it is in processing a request.
    RegU#(MemReq) curReq;
    Reg#(ReqStatus) state(Ready);
    
    // Hit/miss counters
    Reg#(Word) hits(0);
    Reg#(Word) misses(0);

    input Maybe#(MemReq) req default = Invalid;
    
    method Bool reqEnabled = (state == Ready) ? True : False;

    function Bool isHit;
        return ((state == Lookup) && (fromMaybe(?, tagArray.data) == getTag(curReq.addr)) && (fromMaybe(?, statusArray.data) != NotValid)) ? True : False;
    endfunction

    rule tick;
        if (state == Ready && isValid(req)) begin
	    let r = fromMaybe(?, req);
	    dataArray.req = Valid(DataReq{addr: getIndex(r.addr), write: False, data: ?});
	    tagArray.req = Valid(TagReq{addr: getIndex(r.addr), write: False, data: ?});
	    statusArray.req = Valid(StatusReq{addr: getIndex(r.addr), write: False, data: ?});
            curReq <= r; 	    
	    state <= Lookup;
        end else if (state == Lookup) begin
	    let rdata = fromMaybe(?, dataArray.data);
	    let rtag = fromMaybe(?, tagArray.data);
	    let rstatus = fromMaybe(?, statusArray.data);
	    if (rtag == getTag(curReq.addr) && rstatus != NotValid) begin
		hits <= hits + 1;
 		state <= Ready;
		if (curReq.op == St) begin
		    rdata[getWordOffset(curReq.addr)] = curReq.data;
		    dataArray.req = Valid(DataReq{addr: getIndex(curReq.addr), write: True, data: rdata});  
		    statusArray.req = Valid(StatusReq{addr: getIndex(curReq.addr), write: True, data: Dirty});
		end 
	    end else if (rstatus == Clean || rstatus == NotValid) begin
		mainMem.req = Valid(LineReq{lineAddr: getLineAddr(curReq.addr), op: Ld, data: ?});
		misses <= misses + 1;
		state <= Fill;
	    end else begin
		mainMem.req = Valid(LineReq{lineAddr: getLineAddr({rtag, curReq.addr[1 + logWordsPerLine + logCacheSets : 0]}), op: St, data: rdata});
		misses <= misses + 1;
		state <= Writeback;
	    end
        end else if (state == Writeback && mainMem.reqEnabled) begin
	    mainMem.req = Valid(LineReq{lineAddr: getLineAddr(curReq.addr), op: Ld, data: ?});
	    state <= Fill;
        end else if (state == Fill && isValid(mainMem.data)) begin
	    let rMemdata = fromMaybe(?, mainMem.data);
	    state <= Ready;
	    if (curReq.op == St) begin
	      rMemdata[getWordOffset(curReq.addr)] = curReq.data;
	      dataArray.req = Valid(DataReq{addr: getIndex(curReq.addr), write: True, data: rMemdata});
	      statusArray.req = Valid(StatusReq{addr: getIndex(curReq.addr), write: True, data: Dirty});
              tagArray.req = Valid(TagReq{addr: getIndex(curReq.addr), write: True, data: getTag(curReq.addr)});
	    end else begin
	      dataArray.req = Valid(DataReq{addr: getIndex(curReq.addr), write: True, data: rMemdata});
              statusArray.req = Valid(StatusReq{addr: getIndex(curReq.addr), write: True, data: Clean});
              tagArray.req = Valid(TagReq{addr: getIndex(curReq.addr), write: True, data: getTag(curReq.addr)});
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
	if (curReq.op == Ld && isHit) begin
	    let rdata = fromMaybe(?, dataArray.data);
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
