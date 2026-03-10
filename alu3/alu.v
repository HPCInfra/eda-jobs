`timescale 1ns / 1ps

module alu #(
    parameter WIDTH = 8
)(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input  [3:0]       op,
    output reg [WIDTH-1:0] result,
    output zero,
    output carry,
    output overflow
);

    reg carry_out;

    // Operation codes
    localparam OP_ADD  = 4'b0000;
    localparam OP_SUB  = 4'b0001;
    localparam OP_AND  = 4'b0010;
    localparam OP_OR   = 4'b0011;
    localparam OP_XOR  = 4'b0100;
    localparam OP_NOT  = 4'b0101;
    localparam OP_SLL  = 4'b0110; // shift left logical
    localparam OP_SRL  = 4'b0111; // shift right logical
    localparam OP_SRA  = 4'b1000; // shift right arithmetic
    localparam OP_SLT  = 4'b1001; // set less than (signed)

    always @(*) begin
        carry_out = 1'b0;
        case (op)
            OP_ADD: {carry_out, result} = a + b;
            OP_SUB: {carry_out, result} = a - b;
            OP_AND: result = a & b;
            OP_OR:  result = a | b;
            OP_XOR: result = a ^ b;
            OP_NOT: result = ~a;
            OP_SLL: result = a << b[2:0];
            OP_SRL: result = a >> b[2:0];
            OP_SRA: result = $signed(a) >>> b[2:0];
            OP_SLT: result = ($signed(a) < $signed(b)) ? {{(WIDTH-1){1'b0}}, 1'b1} : {WIDTH{1'b0}};
            default: result = {WIDTH{1'b0}};
        endcase
    end

    assign zero  = (result == {WIDTH{1'b0}});
    assign carry = carry_out;
    // Overflow: sign of inputs same, sign of result differs (for add/sub)
    assign overflow = ((op == OP_ADD) && (a[WIDTH-1] == b[WIDTH-1]) && (result[WIDTH-1] != a[WIDTH-1])) ||
                      ((op == OP_SUB) && (a[WIDTH-1] != b[WIDTH-1]) && (result[WIDTH-1] != a[WIDTH-1]));

endmodule
