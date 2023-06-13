import PipelineMath;

Integer numTests  = 10;
Bit#(4) testDelay = 3;

function Bit#(16) testFunction(Bit#(16) test);
  if (test[15] == 1'b1) begin
    test = -test;
  end
  
  test = test / 3 + 10;
  return test * 7;
endfunction

module PipelineMathTest;
  PipelineMath pipeline;

  RegU#(Bit#(16)) currentTest;
  Reg#(Bit#(32))  cycle(0);
  Reg#(Bit#(4))   testCount(0);
  Reg#(Bit#(4))   delayCount(0);
  Reg#(Bit#(32))  finishedCount(0);
  Reg#(Bit#(32))  testCycleCount(0);

  Bool pipelineTestDone = isValid(pipeline.out);

  rule genInput;
    Maybe#(Bit#(16)) pipelineIn = Invalid;

    Bit#(32) nextCycleCount = testCycleCount + 1;

    if (testCount == 0 || (testCount < numTests && testCycleCount > 2 + zeroExtend(testDelay))) begin
      nextCycleCount = 1;

      Bit#(16) in = case(testCount) 
        0: 30;
        1: -30;
        2: 213;
        3: -60;
        4: 80;
        5: 421;
        6: 7;
        7: -9;
        8: -300;
        9: -62;
        default: 0;
      endcase;

      pipelineIn      = Valid(in); 
      testCount       <= testCount + 1;
      currentTest     <= in;
    end

    pipeline.in = pipelineIn;
    testCycleCount <= nextCycleCount;
  endrule

  rule testOutput;
    if (pipelineTestDone && delayCount == 0) begin
      Bit#(16) out = fromMaybe(?, pipeline.out); 
      Bit#(16) expected = testFunction(currentTest);

      if (out != expected) begin
        Int#(16) inputSigned = unpack(currentTest);

        $display("FAILED incorrect result");
        $display("(|%0d| / 3 + 10) * 7 gave %0d instead of %0d",
          inputSigned, out, expected);
        $finish;
      end else if (testCycleCount > 3) begin
        $display("FAILED due to cycle count");
        $display("Took %d cycles > 3", testCycleCount);
        $finish;
      end
    end
  endrule

  rule listenValidOutput;
    if (delayCount == 0 && pipelineTestDone) begin
      delayCount <= 1;
    end else if (delayCount > 0 && delayCount < testDelay) begin
      if (isValid(pipeline.out)) begin
        Bit#(16) out = fromMaybe(?, pipeline.out); 

        $display("FAILED due to invalid pipelining");
        $display("Your pipeline should respond with INVALID when given an invalid input");
        $display("Make sure you are also passing INVALID signals on your pipeline");
        $finish;
      end 

      delayCount <= delayCount + 1;
    end else if (delayCount == testDelay) begin
      finishedCount <= finishedCount + 1;
      delayCount    <= 0;
    end
  endrule

  rule monitorFinish;
    if (finishedCount == numTests) begin
      $display("PASSED");
      $finish;
    end

    if (cycle == numTests * 9) begin
      $display("FAILED due to timeout");
      $display("You only completed %d out of 10 tests", finishedCount);
      $display("Make sure that your code responds with a valid output within three cycles");
      $finish;
    end
  endrule

  rule incrementCycles;
    cycle <= cycle + 1;
  endrule
endmodule
