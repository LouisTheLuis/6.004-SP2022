bsvimport GenericRandomizer;

// Reference functions that use the '*' operator
// (Ones in Multipliers.ms can be overwritten by students, so we use these ones for testing)
function Bit#(2*n) multiply_unsigned_ref#(Integer n)(Bit#(n) a, Bit#(n) b);
    return zeroExtend(a) * zeroExtend(b);
endfunction

function Bit#(2*n) multiply_signed_ref#(Integer n)(Bit#(n) a, Bit#(n) b);
    Int#(n) a_int = unpack(a);
    Int#(n) b_int = unpack(b);
    Int#(2*n) product_int = signExtend(a_int) * signExtend(b_int);
    return pack(product_int);
endfunction

// Function-Function Test Bench
module TbMulFunction#(Integer n) (
    Bool testSigned,
    Bool verbose
);
    Reg#(Bit#(32)) cycle(0);
    GenericRandomizerWrapped#(Bit#(n)) randomA;
    GenericRandomizerWrapped#(Bit#(n)) randomB;
    Bit#(n) most_neg_number = { 1'b1, 0 };

    rule step;
        cycle <= cycle + 1;
    endrule

    rule startTest;
        if (cycle == 0) begin
            randomA.init;
            randomB.init;
        end
    endrule

    rule endTest;
        if (cycle == 128) begin
            $display("PASSED");
            $finish;
        end
    endrule

    rule runTest;
        // Wait one cycle for randomizer to finish initializing
        if (cycle < 128 && cycle > 0) begin
            Bit#(n) a = randomA.next;
            Bit#(n) b = randomB.next;
            
            // Don't allow a or b to be the most negative number
            if( a != most_neg_number && b != most_neg_number ) begin
                let test_function = multiply_by_adding#(n);
                let ref_function = (testSigned) ? multiply_signed_ref#(n) : multiply_unsigned_ref#(n);  
                let test = test_function(a,b);
                let expected = ref_function(a,b);
               
                if ( (pack(test == expected) ^ pack(test != expected)) == 0 ) begin
                   $display("FAILED undefined value (?) returned");
                   $finish;
                end

                Int#(n) a_signed = unpack(a);
                Int#(n) b_signed = unpack(b);
                Int#(n+n) test_signed = unpack(test);
               
                if(test != expected) begin
                    Int#(n+n) expected_signed = unpack(expected);
                    $display("FAILED incorrect result");
                    if (testSigned) $display("%0d * %0d test function gave %0d instead of %0d", a_signed, b_signed, test_signed, expected_signed);
                    else $display("%0d * %0d test function gave %0d instead of %0d", a, b, test, expected);
                    $finish;
                end else if( verbose ) begin
                    $display("PASSED case %0d", cycle);
                    if (testSigned) $display("%0d * %0d test function gave %0d", a_signed, b_signed, test_signed);
                    else $display("%0d * %0d test function gave %0d", a, b, test);
                end
            end
        end
    endrule
endmodule

// Function-Module Test Bench
module TbMulModule#(type T, Integer n) (
    Bool testSigned,
    Bool verbose
); 
    T#(n) multiplier;
    Reg#(Bit#(32)) cycle(0); // total cycles
    Reg#(Bit#(32)) test_count(0); // number of tests generated
    Reg#(Bit#(32)) finished_count(0);
    Reg#(Bit#(32)) test_cycles(0);
    Reg#(Bool) multiplier_initialized(False);
    RegU#(MultiplierInput#(n)) current_test;
    GenericRandomizerWrapped#(Bit#(n)) randomA;
    GenericRandomizerWrapped#(Bit#(n)) randomB;
    Bit#(n) most_neg_number = { 1'b1, 0 };

    Bool multiplier_test_done = isValid(multiplier.getResult);

    // Generate test 
    rule testGen;
        let next_test_cycles = test_cycles + 1;
        if (test_count < 128 && cycle > 2) begin
            if (test_count == 0 || multiplier_test_done) begin
                // Start a new test
                let a = randomA.next;
                let b = randomB.next;
                next_test_cycles = 0;
                if( a != most_neg_number && b != most_neg_number ) begin
                    MultiplierInput#(n) operands;
                    operands.a = a;
                    operands.b = b;
                    current_test <= operands; 
                    multiplier.in = Valid(operands);
                    test_count <= test_count + 1;
                end
            end
        end
        test_cycles <= next_test_cycles;
    endrule

    rule checkTest;
        if (multiplier_test_done) begin
            finished_count <= finished_count + 1;
            let test = fromMaybe(?, multiplier.getResult);
            let a = current_test.a;
            let b = current_test.b;
            let ref_function = (testSigned) ? multiply_signed_ref#(n) : multiply_unsigned_ref#(n);  
            let expected = ref_function(a, b);
            if ( (pack(test == expected) ^ pack(test != expected)) == 0 ) begin
                $display("FAILED undefined value (?) returned");
                $finish;
            end

            Int#(n) a_signed = unpack(a);
            Int#(n) b_signed = unpack(b);
            Int#(n+n) test_signed = unpack(test);

            if(test != expected) begin
                Int#(n+n) expected_signed = unpack(expected);
                $display("FAILED incorrect result");
                if (testSigned) $display("%0d * %0d test function gave %0d instead of %0d",
                    a_signed, b_signed, test_signed, expected_signed);
                else $display("%0d * %0d test function gave %0d instead of %0d",
                    a, b, test, expected);
                $finish;
            end else if (test_cycles > n) begin
                $display("FAILED due to cycle count");
                $display("Took %d cycles instead of %d", test_cycles, n);
                $finish;
            end else if( verbose ) begin
                $display("PASSED case %0d", finished_count);
                if (testSigned) $display("%0d * %0d test function gave %0d",
                    a_signed, b_signed, test_signed);
                else $display("%0d * %0d test function gave %0d",
                    a, b, test);
            end
        end
    endrule

    rule initialize;
        if( cycle == 0 ) begin
            randomA.init;
            randomB.init;
        end
    endrule

    rule monitor_test;
        if( finished_count == 128 ) begin
            if( verbose ) begin
                $display("PASSED %0d test cases in %0d cycles", finished_count, cycle);
            end else begin
                $display("PASSED");
            end
            $finish;
        end
        if( cycle == 128*4*n ) begin
            // 2*n cycles per mult should be pleanty of time
            $display("FAILED due to timeout");
            $display("You only completed %d out of 128 tests", finished_count);
            $display("Make sure that your code responds with a valid output within n cycles");
            $finish;
        end
    endrule

    rule count_cycles;
        cycle <= cycle + 1; 
    endrule
endmodule

// Function-Module Test Bench
module TbMulModuleSingleTest#(type T, Integer n) (
   Bit#(n) a, Bit#(n) b 
); 
    T#(n) multiplier;
    Reg#(Bit#(32)) cycle(0); // total cycles
    Reg#(Bit#(32)) test_count(0); // number of tests generated
    Reg#(Bit#(32)) finished_count(0);
    Reg#(Bit#(32)) test_cycles(0);
    Reg#(Bool) multiplier_initialized(False);
    RegU#(MultiplierInput#(n)) current_test;

    Bool multiplier_test_done = isValid(multiplier.getResult);

    // Generate test 
    rule testGen;
        let next_test_cycles = test_cycles + 1;
        if (test_count < 1 && cycle > 2) begin
            if (test_count == 0 || multiplier_test_done) begin
                // Start a new test
                next_test_cycles = 0;
                MultiplierInput#(n) operands;
                operands.a = a;
                operands.b = b;
                current_test <= operands; 
                multiplier.in = Valid(operands);
                test_count <= test_count + 1;
            end
        end
        test_cycles <= next_test_cycles;
    endrule

    rule checkTest;
        if (multiplier_test_done) begin
            finished_count <= finished_count + 1;
            let test = fromMaybe(?, multiplier.getResult);
            let a = current_test.a;
            let b = current_test.b;
            let ref_function = multiply_unsigned_ref#(n);  
            let expected = ref_function(a, b);
            if ( (pack(test == expected) ^ pack(test != expected)) == 0 ) begin
                $display("FAILED undefined value (?) returned");
                $finish;
            end

            Int#(n) a_signed = unpack(a);
            Int#(n) b_signed = unpack(b);
            Int#(n+n) test_signed = unpack(test);

            if(test != expected) begin
                Int#(n+n) expected_signed = unpack(expected);
                $display("FAILED incorrect result");
                $display("%0d * %0d test function gave %0d instead of %0d",
                    a, b, test, expected);
                $finish;
            end else if (test_cycles > n) begin
                $display("FAILED due to cycle count");
                $display("Took %d cycles instead of %d", test_cycles, n);
                $finish;
            end else begin
                $display("PASSED test in %0d cycles", test_cycles);
                $display("%0d * %0d test function gave %0d",
                    a, b, test);
                $finish;
            end
        end
    endrule

    rule monitor_test;
        if( cycle == 4*n ) begin
            // 4*n cycles per mult should be plenty of time
            $display("FAILED due to cycle count");
            $finish;
        end
    endrule

    rule count_cycles;
        cycle <= cycle + 1; 
    endrule
endmodule
