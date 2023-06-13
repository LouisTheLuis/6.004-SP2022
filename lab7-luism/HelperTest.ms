bsvimport GenericRandomizer;
import CacheHelpers;

typedef struct {
    CacheTag tag;
    CacheIndex index;
    WordOffset wordOffset;
    Bit#(2) byteOffset;
} AddrStruct;

module HelperTest;
    GenericRandomizerWrapped#(Word) randomAddr;
    Reg#(Bit#(32)) testsLeft(0);
    
    rule doTest;
        if (testsLeft == 0) begin
            // Initialize
            randomAddr.init;
            testsLeft <= 256;
        end else begin
            AddrStruct addr = unpack(randomAddr.next);
            Word word = {addr.tag, addr.index, addr.wordOffset, addr.byteOffset};
            //Results
            WordOffset wordOffset = getWordOffset(word);
            CacheIndex index = getIndex(word);
            CacheTag tag = getTag(word);
            LineAddr lineAddr = getLineAddr(word);

            if (wordOffset != addr.wordOffset) begin
                $display("FAILED: getWordOffset for address 0x%x", word,
                    ", expected offset 0x%x", addr.wordOffset, ", got 0x%x", wordOffset);
                $finish;
            end else if (index != addr.index) begin
                $display("FAILED: getIndex for address 0x%x", word,
                    ", expected index 0x%x", addr.index, ", got 0x%x", index);
                $finish;
            end else if (tag != addr.tag) begin
                $display("FAILED: getTag for address 0x%x", word,
                    ", expected tag 0x%x", addr.tag, ", got 0x%x", tag);
                $finish;
            end else if (lineAddr != {addr.tag, addr.index}) begin
                $display("FAILED: getLineAddr for address 0x%x", word,
                    ", expected lineAddr 0x%x", {addr.tag, addr.index}, ", got 0x%x", lineAddr);
                $finish;
            end

            testsLeft <= testsLeft - 1;
            if (testsLeft == 1) begin
                $display("PASSED");
                $finish;
            end
        end
    endrule
endmodule
