bsvimport Magic;
import ProcTypes;

module MagicMemory;
    // 64 KB magic memory array
    MagicMemoryArray magicMem("mem.vmh");

    method Word read(Word addr) = magicMem.sub(truncate(addr >> 2));

    input Maybe#(MemWriteReq) write default = Invalid;

    rule doWrite;
        if (isValid(write)) begin
            MemWriteReq req = fromMaybe(?, write);
            if (req.addr == 'h4000_0000) begin
                // Write character to stdout
                $write("%c", req.data[7:0]);
            end else if (req.addr == 'h4000_0004) begin
                // Write integer to stdout
                $write("%0d", req.data);
            end else if (req.addr == 'h4000_1000) begin
                // Exit simulation
                if (req.data == 0) begin
                    $display("PASSED");
                end else begin
                    $display("FAILED %0d", req.data);
                end
                $finish;
            end else begin
                // Write memory array
                magicMem.upd = ArrayWriteReq{idx: truncate(req.addr >> 2), data: req.data};
            end
        end
    endrule
endmodule
