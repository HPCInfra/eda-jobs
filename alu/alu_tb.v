module alu_tb;
    reg [31:0] a, b;
    reg [2:0] opcode;
    wire [31:0] result;
    reg [31:0] expected;
    integer seed, i, errors;

    // Instantiate the DUT (Device Under Test)
    alu dut (.a(a), .b(b), .opcode(opcode), .result(result));

    initial begin
        // Get seed from Slurm, default to 1
        if (!$value$plusargs("SEED=%d", seed)) seed = 1;
        errors = 0;
        
        $display("Starting ALU Verification with SEED=%d", seed);

        // Run 10 million random transactions to stress the CPU
        for (i = 0; i < 10000000; i = i + 1) begin
            a = $random(seed);
            b = $random(seed);
            opcode = $random(seed) % 7;

            // Wait a simulation tick for logic to propagate
            #1;

            // Behavioral check
            case (opcode)
                3'b000: expected = a + b;
                3'b001: expected = a - b;
                3'b010: expected = a & b;
                3'b011: expected = a | b;
                3'b100: expected = a ^ b;
                3'b101: expected = a << b[4:0];
                3'b110: expected = a >> b[4:0];
                default: expected = 32'b0;
            endcase

            if (result !== expected) begin
                $display("ERROR at txn %d: op=%b a=%h b=%h | expected=%h got=%h", i, opcode, a, b, expected, result);
                errors = errors + 1;
            end
        end

        if (errors == 0) $display("PASS: SEED=%d completed with 0 errors.", seed);
        else $display("FAIL: SEED=%d had %d errors.", seed, errors);
        
        $finish;
    end
endmodule