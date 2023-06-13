bsvimport Vector;
bsvimport Randomizable;
import CombDigitalSystemsTemp;
//import IsPowerOf2Temp::*;
// Bluespec-provided implementation of popcount
bsvimport PopCount;


typedef enum { Testing, Done } TestMode;

function Bit#(2) log_2(Bit#(4) a);
    Bit#(2) ret = 0;
    if (a[0] == 1) ret = 0;
    if (a[1] == 1) ret = 1;
    if (a[2] == 1) ret = 2;
    if (a[3] == 1) ret = 3;
    return ret;
endfunction

function Bit#(1) power_2(Bit#(4) a);
    Bit#(1) ret = 0;
    if (a == 1) ret = 1;
    if (a == 2) ret = 1;
    if (a == 4) ret = 1;
    if (a == 8) ret = 1;
    return ret;
endfunction

function Bit#(2) which_power_2(Bit#(4) a);
    Bit#(2) ret = 0;
    if (a == 1) ret = 0;
    if (a == 2) ret = 1;
    if (a == 4) ret = 2;
    if (a == 8) ret = 3;
    return ret;
endfunction

module BitScanReverseTest;
    Reg#(Bool) error_found(False);
    Reg#(TestMode) mode(Testing);
    
    // Small Exhaustive testing
    Reg#(Bit#(4)) small_a(1);

    rule test;
        if (mode == Testing) begin
            // Do a test
            Bit#(2) test_output = bit_scan_reverse(small_a);
            Bit#(2) expected_output = log_2(small_a);
            if (test_output != expected_output) begin
                $display("bit_scan_reverse( ",fshow(small_a), " ) = ", fshow(test_output), " (ERROR)");
                error_found <= True;
            end else begin
                $display("bit_scan_reverse( ",fshow(small_a),  " ) = ", fshow(test_output));
            end
            
            if (small_a == 4'b1111) begin
                mode <= Done;
            end else begin
                small_a <= small_a + 1;
            end
        end else if (mode == Done) begin
            $display("");
            $display("Lab3.BitScanReverse: ", error_found ? "FAILED" : "PASSED");
            $finish();
        end
    endrule
endmodule

module IsPowerOf2Test;
    Reg#(Bool) error_found(False);
    Reg#(TestMode) mode(Testing);
    
    // Small Exhaustive testing
    Reg#(Bit#(4)) small_a(1);


    rule test;
        if (mode == Testing) begin
            Bit#(1) test_output = is_power_of_2(small_a);
            Bit#(1) expected_output = power_2(small_a);
            if (test_output != expected_output) begin
                $display("is_power_of_2( ",fshow(small_a), " ) = ", fshow(test_output), " (ERROR)");
                error_found <= True;
            end else begin
                $display("is_power_of_2( ",fshow(small_a),  " ) = ", fshow(test_output));
            end
            
            if (small_a == 4'b1111) begin
                mode <= Done;
            end else begin
                small_a <= small_a + 1;
            end
        end if (mode == Done) begin
            $display("");
            $display("Lab3.IsPowerOf2: ", error_found ? "FAILED" : "PASSED");
            $finish();
        end
    endrule
endmodule

module EqualTest;
    Reg#(Bool) error_found(False);
    Reg#(TestMode) mode(Testing);
    
    // Small Exhaustive testing
    Reg#(Bit#(8)) small_a(0);
    Reg#(Bit#(8)) small_b(0);


    rule test;
        if (mode == Testing) begin
            Bit#(1) test_output = equal(small_a,small_b);
            Bit#(1) expected_output = pack(small_a == small_b);
            if (test_output != expected_output) begin
                $display("equal( ",fshow(small_a), " , ", fshow(small_b), " ) = ", fshow(test_output), " (ERROR)");
                error_found <= True;
            end else begin
                $display("equal( ",fshow(small_a), " , ", fshow(small_b), " ) = ", fshow(test_output));
            end
            
            // next test
            if (small_b == 8'b11111111) begin
                if (small_a == 8'b11111111) begin
                    mode <= Done;
                end else begin
                    small_a <= small_a + 1;
                    small_b <= 0;
                end
            end else begin
                small_b <= small_b + 1;
            end
        end else if (mode == Done) begin
            $display("");
            $display("Lab3.Equal: ", error_found ? "FAILED" : "PASSED");
            $finish();
        end
    endrule
endmodule


module IsGeqTest;
    Reg#(TestMode) mode(Testing);
    Reg#(Bit#(10)) i(0);
    Reg#(Bool) error_found(False);
    
    // Small Exhaustive testing
    Reg#(Bit#(4)) small_a(0);
    Reg#(Bit#(4)) small_b(0);

    rule doSmallTest;
        if (mode == Testing) begin
            Bit#(1) test_output = is_geq(small_a, small_b);
            Bit#(1) expected_output = pack(small_a >= small_b);
            if (test_output != expected_output) begin
                $display("is_geq( ",fshow(small_a), " , ", fshow(small_b), " ) = ", fshow(test_output), " (ERROR)");
                error_found <= True;
            end else begin
                $display("is_geq( ",fshow(small_a), " , ", fshow(small_b), " ) = ", fshow(test_output));
            end
            // next test
            if (small_b == 4'b1111) begin
                if (small_a == 4'b1111) begin
                    i <= 0;
                    mode <= Done;
                end else begin
                    small_a <= small_a + 1;
                    small_b <= 0;
                end
            end else begin
                small_b <= small_b + 1;
            end
        end else if (mode == Done) begin
            $display("");
            $display("Lab3.IsGeq: ", error_found ? "FAILED" : "PASSED");
            $finish();
        end
    endrule
endmodule


module LogOfPowerOf2Test;
    Reg#(Bool) error_found(False);
    Reg#(TestMode) mode(Testing);
    
    // Small Exhaustive testing
    Reg#(Bit#(4)) small_a(1);



    rule doSmallTest;
        if (mode == Testing) begin
            Bit#(2) test_output = log_of_power_of_2(small_a);
            Bit#(2) expected_output = which_power_2(small_a);
            if (test_output != expected_output) begin
                $display("log_of_power_of_2( ",fshow(small_a), " ) = ", fshow(test_output), " (ERROR)");
                error_found <= True;
            end else begin
                $display("log_of_power_of_2( ",fshow(small_a),  " ) = ", fshow(test_output));
            end
            if (small_a == 4'b1111) begin
                mode <= Done;
            end else begin
                small_a <= small_a + 1;
            end
        end else if (mode == Done) begin
            $display("");
            $display("Lab3.LogOfPowerOf2: ", error_found ? "FAILED" : "PASSED");
            $finish();
        end
    endrule
endmodule

module PopulationCountTest;
    Reg#(Bool) done(False);
    Reg#(Bool) error_found(False);
    Reg#(Bit#(4)) first_error(0);
    Reg#(Bit#(4)) input_value(0);

    rule test;
        if (done == False) begin 
            Bit#(3) test_output = population_count(input_value);
            Bit#(3) expected_output = popCountNaive(input_value);
            if (test_output != expected_output) begin
                $display("population_count( %b ) = %0d (ERROR)", input_value, test_output);
                if (!error_found) begin
                    // first error
                    error_found <= True;
                    first_error <= input_value;
                end
            end else begin
                $display("population_count( %b ) = %0d", input_value, test_output);
            end
            if (input_value == 4'b1111) begin
                done <= True;
            end else begin
                input_value <= input_value + 1;
            end
        end else if (done == True) begin
            $display("");
            $display("Lab3.PopulationCount: ", error_found ? "FAILED" : "PASSED");
            if (error_found) begin
                $display("First Error: population_count( %b ) = %0d", first_error, population_count(first_error));
            end
            $finish();
        end
    endrule
endmodule

//     a
//   +---+
// f |   | b
//   +-g-+
// e |   | c
//   +---+
//     d
// 
// function Action display_seven_segment(Bit#(7) value);
//     return (action
//         Bool a, b, c, d, e, f, g;
//         a = value[6] == 1;
//         b = value[5] == 1;
//         c = value[4] == 1;
//         d = value[3] == 1;
//         e = value[2] == 1;
//         f = value[1] == 1;
//         g = value[0] == 1;
//         // first row:
//         $write( (a || f) ? "+" : " " );
//         $write( a ? "---" : "   " );
//         $write( (a || b) ? "+" : " " );
//         $write( "\n" );
//         // second row:
//         $write( f ? "|" : " " );
//         $write( "   " );
//         $write( b ? "|" : " " );
//         $write( "\n" );
//         // third row:
//         $write( (e || f || g) ? "+" : " " );
//         $write( g ? "---" : "   " );
//         $write( (b || c || g) ? "+" : " " );
//         $write( "\n" );
//         // fourth row:
//         $write( e ? "|" : " " );
//         $write( "   " );
//         $write( c ? "|" : " " );
//         $write( "\n" );
//         // fifth row:
//         $write( (d || e) ? "+" : " " );
//         $write( d ? "---" : "   " );
//         $write( (c || d) ? "+" : " " );
//         $write( "\n" );
//     endaction);
// endfunction

module SevenSegmentTest;
    Reg#(Bool) done(False);
    Reg#(Bit#(4)) count(0);
    Reg#(Bit#(112)) result_digest(0);
    Bit#(112) expected_result_digest = 112'hfce7fe22fdb4cf6ee8a9c46a98b8;

    rule test;
        if (done == False) begin
            $display("Seven Segment Display for %0d", count);
            $display("============================");
            
            // Display the seven-segment
            Bit#(7) decoded = seven_segment_decoder(count);
            Bool a, b, c, d, e, f, g;
            a = decoded[6] == 1;
            b = decoded[5] == 1;
            c = decoded[4] == 1;
            d = decoded[3] == 1;
            e = decoded[2] == 1;
            f = decoded[1] == 1;
            g = decoded[0] == 1;
            // first row:
            $write( (a || f) ? "+" : " " );
            $write( a ? "---" : "   " );
            $write( (a || b) ? "+" : " " );
            $write( "\n" );
            // second row:
            $write( f ? "|" : " " );
            $write( "   " );
            $write( b ? "|" : " " );
            $write( "\n" );
            // third row:
            $write( (e || f || g) ? "+" : " " );
            $write( g ? "---" : "   " );
            $write( (b || c || g) ? "+" : " " );
            $write( "\n" );
            // fourth row:
            $write( e ? "|" : " " );
            $write( "   " );
            $write( c ? "|" : " " );
            $write( "\n" );
            // fifth row:
            $write( (d || e) ? "+" : " " );
            $write( d ? "---" : "   " );
            $write( (c || d) ? "+" : " " );
            $write( "\n" );
            
            //display_seven_segment(seven_segment_decoder(d));
            result_digest <= truncate(result_digest << 7) | zeroExtend(seven_segment_decoder(count) ^ (({3'b0, count} << 3) ^ zeroExtend(count)));
            $display();
            if (count == 15) begin
                done <= True;
            end else begin
                count <= count + 1;
            end
        end else if (done == True) begin
            $display("Lab3.SevenSegmentDecoder: ", result_digest == expected_result_digest ? "PASSED" : "FAILED");
            $finish();
        end
    endrule
endmodule



module VectorEqualTest;
    Reg#(TestMode) mode(Testing);

    Reg#(Bool) error_found(False);
    

    // Large Random Testing
    Reg#(Bit#(8)) a_(0);
    Reg#(Bit#(8)) dif_(1);


//     function Action test(Bit#(32) a, Bit#(32) b);
//         return (action
//                 Bit#(4) test_output = vector_equal(a, b);
//                 Bit#(4) expected_output = 0;
//                 expected_output[3] = pack(a[31:24] == b[31:24]);
//                 expected_output[2] = pack(a[23:16] == b[23:16]);
//                 expected_output[1] = pack(a[15:8] == b[15:8]);
//                 expected_output[0] = pack(a[7:0] == b[7:0]);
//                 if (test_output != expected_output) begin
//                     $display("vector_equal( ",fshow(a), " , ", fshow(b), " ) = ", fshow(test_output), " (ERROR)");
//                     error_found <= True;
//                 end else begin
//                     $display("vector_equal( ",fshow(a), " , ", fshow(b), " ) = ", fshow(test_output));
//                 end
//             endaction);
//     endfunction

    rule test;
        if (mode == Testing) begin
            Bit#(32) final_a = 0;
            Bit#(32) final_b = 0;
            if (a_[0] == 1) begin
                final_a[7:0] = a_;
                final_b[7:0] = a_+dif_;
            end else begin
                final_a[7:0] = a_;
                final_b[7:0] = a_;
            end
            if (a_[1] == 1) begin
                final_a[15:8] = a_;
                final_b[15:8] = a_+dif_;
            end else begin
                final_a[15:8] = a_;
                final_b[15:8] = a_;
            end
            if (a_[2] == 1) begin
                final_a[23:16] = a_;
                final_b[23:16] = a_+dif_;
            end else begin
                final_a[23:16] = a_;
                final_b[23:16] = a_;
            end
            if (a_[3] == 1) begin
                final_a[31:24] = a_;
                final_b[31:24] = a_+dif_;
            end else begin
                final_a[31:24] = a_;
                final_b[31:24] = a_;
            end
        
        
            //test(final_a, final_b);
            Bit#(4) test_output = vector_equal(final_a, final_b);
            Bit#(4) expected_output = 0;
            expected_output[3] = pack(final_a[31:24] == final_b[31:24]);
            expected_output[2] = pack(final_a[23:16] == final_b[23:16]);
            expected_output[1] = pack(final_a[15:8] == final_b[15:8]);
            expected_output[0] = pack(final_a[7:0] == final_b[7:0]);
            if (test_output != expected_output) begin
                $display("vector_equal( ",fshow(final_a), " , ", fshow(final_b), " ) = ", fshow(test_output), " (ERROR)");
                error_found <= True;
            end else begin
                $display("vector_equal( ",fshow(final_a), " , ", fshow(final_b), " ) = ", fshow(test_output));
            end
        
        
            // next test
            if (dif_ == 255) begin
                dif_ <= 1;
                a_ <= a_ + 1;
            end else begin
                dif_ <= dif_ + 1;
            end
            if (a_ == 255) begin
                mode <= Done;
            end
        end else if (mode == Done) begin
            $display("");
            $display("Lab3.VectorEqual: ", error_found ? "FAILED" : "PASSED");
            $finish();
        end
    endrule
endmodule
