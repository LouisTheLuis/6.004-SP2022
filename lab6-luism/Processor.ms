import ProcTypes;
import RegisterFile;
import Decode;
import Execute;
import MagicMemory;

module Processor;
    Reg#(Word) pc(0);
    RegisterFile rf;
    MagicMemory iMem; // Memory for loading instructions
    MagicMemory dMem; // Memory for loading and storing data

    rule doSingleCycle;
        // Load the instruction from instruction memory (iMem)
        Word inst = iMem.read(pc); 

        // Decode the instruction
        DecodedInst dInst = decode(inst); 

        // Read the register values used by the instruction
        Word rVal1 = rf.rd1(dInst.src1); 
        Word rVal2 = rf.rd2(dInst.src2); 

        // Compute all outputs of the instruction
        ExecInst eInst = execute(dInst, rVal1, rVal2, pc); 

        if (eInst.iType == LOAD) begin
	    eInst.data = dMem.read(eInst.addr); // TODO: Load from data memory (dMem) if the instruction requires it
        end else if (eInst.iType == STORE) begin
	    dMem.write = Valid(MemWriteReq{addr: eInst.addr, data: eInst.data}); // TODO: Store to data memory (dMem) if the instruction requires it
        end

        if (isValid(eInst.dst)) begin
            rf.wr = Valid(RegWriteArgs{index: fromMaybe(?, eInst.dst), data: eInst.data});// TODO: Write to a register if the instruction requires it
        end

        pc <= eInst.nextPc; // TODO: Update pc to the next pc

        // If unsupported instruction, stops simulation and print the state of the processor
        // IMPORTANT: Do not modify this code! The microtests check for it.
        if (eInst.iType == Unsupported) begin
            $display("Reached unsupported instruction (0x%x)", inst);
            $display("Dumping the state of the processor");
            $display("pc = 0x%x", pc);
            $display(rf.fshow);
            $display("Quitting simulation.");
            $finish;
        end
    endrule

    // This method exists to make the processor synthesizable: synth removes
    // circuits without outputs, so we need some non-trivial output to avoid
    // removing the processor :)
    method Word getPc = pc;
endmodule
