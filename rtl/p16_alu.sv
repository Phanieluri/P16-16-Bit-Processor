module p16_alu (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic [3:0]  op,

    output logic [15:0] result,
    output logic        zero,
    output logic        negative,
    output logic        carry,
    output logic        overflow
);

    logic [16:0] arithmetic_tmp;
    logic        valid_op;

    always_comb begin
        arithmetic_tmp = 17'b0;
        valid_op       = 1'b0;

        result   = 16'h0000;
        zero     = 1'b0;
        negative = 1'b0;
        carry    = 1'b0;
        overflow = 1'b0;

        case (op)
            // ADD
            4'h0: begin
                valid_op = 1'b1;
                arithmetic_tmp = {1'b0, a} + {1'b0, b};
                result = arithmetic_tmp[15:0];
                carry = arithmetic_tmp[16];
                overflow = (~(a[15] ^ b[15])) &
                           (result[15] ^ a[15]);
            end

            // SUB
            4'h1: begin
                valid_op = 1'b1;
                arithmetic_tmp = {1'b0, a} +
                                 {1'b0, ~b} + 17'd1;
                result = arithmetic_tmp[15:0];
                carry = arithmetic_tmp[16]; // No borrow
                overflow = (a[15] ^ b[15]) &
                           (result[15] ^ a[15]);
            end

            // AND
            4'h2: begin
                valid_op = 1'b1;
                result = a & b;
            end

            // OR
            4'h3: begin
                valid_op = 1'b1;
                result = a | b;
            end

            // XOR
            4'h4: begin
                valid_op = 1'b1;
                result = a ^ b;
            end

            // Logical shift left
            4'h5: begin
                valid_op = 1'b1;
                result = a << b[3:0];
            end

            // Logical shift right
            4'h6: begin
                valid_op = 1'b1;
                result = a >> b[3:0];
            end

            // Arithmetic shift right
            4'h7: begin
                valid_op = 1'b1;
                result = $signed(a) >>> b[3:0];
            end

            // Signed less-than
            4'h8: begin
                valid_op = 1'b1;
                result = ($signed(a) < $signed(b))
                         ? 16'd1 : 16'd0;
            end

            // Unsigned less-than
            4'h9: begin
                valid_op = 1'b1;
                result = (a < b) ? 16'd1 : 16'd0;
            end

            default: begin
                // Unsupported operation: all outputs remain zero.
            end
        endcase

        if (valid_op) begin
            zero     = (result == 16'h0000);
            negative = result[15];
        end
    end

endmodule