module alu (
    input [31:0] a,
    input [31:0] b,
    input [2:0] opcode,
    output reg [31:0] result
);
    always @(*) begin
        case (opcode)
            3'b000: result = a + b;       // ADD
            3'b001: result = a - b;       // SUB
            3'b010: result = a & b;       // AND
            3'b011: result = a | b;       // OR
            3'b100: result = a ^ b;       // XOR
            3'b101: result = a << b[4:0]; // SLL
            3'b110: result = a >> b[4:0]; // SRL
            default: result = 32'b0;
        endcase
    end
endmodule