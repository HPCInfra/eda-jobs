`timescale 1ns / 1ps

module alu_tb;

    parameter WIDTH = 8;

    reg  [WIDTH-1:0] a, b;
    reg  [3:0]       op;
    wire [WIDTH-1:0] result;
    wire zero, carry, overflow;

    alu #(.WIDTH(WIDTH)) uut (
        .a(a), .b(b), .op(op),
        .result(result), .zero(zero),
        .carry(carry), .overflow(overflow)
    );

    integer pass_count = 0;
    integer fail_count = 0;
    integer run_test = 0;

    task check(input integer tid, input [WIDTH-1:0] expected, input [63:0] test_name);
        begin
            if (run_test != 0 && run_test != tid) begin
                // skip — not the selected test
            end else if (result !== expected) begin
                $display("FAIL #%02d [%0s]: a=0x%02h b=0x%02h op=%b => got 0x%02h, expected 0x%02h",
                         tid, test_name, a, b, op, result, expected);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS #%02d [%0s]: a=0x%02h b=0x%02h op=%b => 0x%02h",
                         tid, test_name, a, b, op, result);
                pass_count = pass_count + 1;
            end
        end
    endtask

    task check_flag(input integer tid, input flag_val, input expected_val, input [63:0] test_name);
        begin
            if (run_test != 0 && run_test != tid) begin
                // skip
            end else if (flag_val !== expected_val) begin
                $display("FAIL #%02d [%0s]: flag=%b, expected=%b",
                         tid, test_name, flag_val, expected_val);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS #%02d [%0s]: flag=%b",
                         tid, test_name, flag_val);
                pass_count = pass_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);

        // If +TEST_NUM=N is provided, run only that test; otherwise run all
        if (!$value$plusargs("TEST_NUM=%d", run_test))
            run_test = 0;

        $display("--- ALU Testbench (run_test=%0d) ---", run_test);

        // ---- ADD tests ----
        a = 8'd10; b = 8'd20; op = 4'b0000; #10;
        check(1, 8'd30, "ADD_BASIC");

        a = 8'd42; b = 8'd0; op = 4'b0000; #10;
        check(2, 8'd42, "ADD_ZERO");

        a = 8'd200; b = 8'd100; op = 4'b0000; #10;
        check(3, 8'd44, "ADD_WRAP");

        check_flag(4, carry, 1'b1, "ADD_CARRY_F");

        a = 8'd127; b = 8'd1; op = 4'b0000; #10;
        check(5, 8'd128, "ADD_OVFL_R");

        check_flag(6, overflow, 1'b1, "ADD_OVFL_F");

        a = 8'd1; b = 8'd2; op = 4'b0000; #10;
        check_flag(7, overflow, 1'b0, "ADD_NO_OVF");

        // ---- SUB tests ----
        a = 8'd50; b = 8'd20; op = 4'b0001; #10;
        check(8, 8'd30, "SUB_BASIC");

        a = 8'd77; b = 8'd77; op = 4'b0001; #10;
        check(9, 8'd0, "SUB_EQ");

        check_flag(10, zero, 1'b1, "SUB_ZERO_F");

        a = 8'd0; b = 8'd1; op = 4'b0001; #10;
        check(11, 8'hFF, "SUB_UNDRFL");

        a = 8'h80; b = 8'd1; op = 4'b0001; #10;
        check_flag(12, overflow, 1'b1, "SUB_OVFL_F");

        // ---- AND tests ----
        a = 8'hF0; b = 8'h0F; op = 4'b0010; #10;
        check(13, 8'h00, "AND_MASK");

        a = 8'hA5; b = 8'hFF; op = 4'b0010; #10;
        check(14, 8'hA5, "AND_IDENT");

        // ---- OR tests ----
        a = 8'hF0; b = 8'h0F; op = 4'b0011; #10;
        check(15, 8'hFF, "OR_COMBIN");

        a = 8'h5A; b = 8'h00; op = 4'b0011; #10;
        check(16, 8'h5A, "OR_ZERO");

        // ---- XOR tests ----
        a = 8'hAA; b = 8'h55; op = 4'b0100; #10;
        check(17, 8'hFF, "XOR_COMPL");

        a = 8'h3C; b = 8'h3C; op = 4'b0100; #10;
        check(18, 8'h00, "XOR_SELF");

        check_flag(19, zero, 1'b1, "XOR_ZERO_F");

        // ---- NOT tests ----
        a = 8'h0F; b = 8'd0; op = 4'b0101; #10;
        check(20, 8'hF0, "NOT_BASIC");

        a = 8'hFF; b = 8'd0; op = 4'b0101; #10;
        check(21, 8'h00, "NOT_ONES");

        // ---- SLL tests ----
        a = 8'h01; b = 8'd1; op = 4'b0110; #10;
        check(22, 8'h02, "SLL_BY1");

        a = 8'h0F; b = 8'd4; op = 4'b0110; #10;
        check(23, 8'hF0, "SLL_BY4");

        // ---- SRL tests ----
        a = 8'h80; b = 8'd2; op = 4'b0111; #10;
        check(24, 8'h20, "SRL_BY2");

        a = 8'hFF; b = 8'd4; op = 4'b0111; #10;
        check(25, 8'h0F, "SRL_ZFILL");

        // ---- SRA tests ----
        a = 8'h80; b = 8'd2; op = 4'b1000; #10;
        check(26, 8'hE0, "SRA_SIGN");

        a = 8'h40; b = 8'd2; op = 4'b1000; #10;
        check(27, 8'h10, "SRA_POS");

        // ---- SLT tests ----
        a = 8'hFF; b = 8'h01; op = 4'b1001; #10;
        check(28, 8'd1, "SLT_TRUE");

        a = 8'h01; b = 8'hFF; op = 4'b1001; #10;
        check(29, 8'd0, "SLT_FALSE");

        a = 8'h05; b = 8'h05; op = 4'b1001; #10;
        check(30, 8'd0, "SLT_EQUAL");

        // ---- Default opcode ----
        a = 8'hFF; b = 8'hFF; op = 4'b1111; #10;
        check(31, 8'h00, "DEFAULT");

        check_flag(32, zero, 1'b1, "DFLT_ZR_F");

        // Summary
        $display("\n========================================");
        $display("  Results: %0d passed, %0d failed", pass_count, fail_count);
        $display("========================================");
        if (fail_count == 0)
            $display("  ALL TESTS PASSED");
        else begin
            $display("  SOME TESTS FAILED");
            $finish(1);
        end
        $display("========================================");
        $finish;
    end

endmodule
