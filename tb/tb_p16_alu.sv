`timescale 1ns/1ps

module tb_p16_alu;

    logic [15:0] a, b;
    logic [3:0]  op;
    logic [15:0] result;
    logic zero, negative, carry, overflow;

    integer errors;

    p16_alu dut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .zero(zero),
        .negative(negative),
        .carry(carry),
        .overflow(overflow)
    );

    task automatic check(
        input logic [3:0]  op_i,
        input logic [15:0] a_i,
        input logic [15:0] b_i,
        input logic [15:0] exp_result,
        input logic exp_carry,
        input logic exp_overflow,
        input logic exp_zero,
        input logic exp_negative
    );
        begin
            op = op_i;
            a  = a_i;
            b  = b_i;
            #1;

            if ((result !== exp_result) ||
                (carry !== exp_carry) ||
                (overflow !== exp_overflow) ||
                (zero !== exp_zero) ||
                (negative !== exp_negative)) begin

                errors = errors + 1;
                $display(
                    "FAIL op=%h a=%h b=%h got=%h expected=%h",
                    op_i, a_i, b_i, result, exp_result
                );
            end else begin
                $display(
                    "PASS op=%h a=%h b=%h result=%h",
                    op_i, a_i, b_i, result
                );
            end
        end
    endtask

    initial begin
        errors = 0;

        $dumpfile("build/p16_alu.vcd");
        $dumpvars(0, tb_p16_alu);

        check(4'h0, 16'h0003, 16'h0004,
              16'h0007, 0, 0, 0, 0);

        check(4'h0, 16'hFFFF, 16'h0001,
              16'h0000, 1, 0, 1, 0);

        check(4'h0, 16'h7FFF, 16'h0001,
              16'h8000, 0, 1, 0, 1);

        check(4'h1, 16'h0005, 16'h0003,
              16'h0002, 1, 0, 0, 0);

        check(4'h1, 16'h0003, 16'h0005,
              16'hFFFE, 0, 0, 0, 1);

        check(4'h1, 16'h8000, 16'h0001,
              16'h7FFF, 1, 1, 0, 0);

        check(4'h2, 16'hF0F0, 16'h0FF0,
              16'h00F0, 0, 0, 0, 0);

        check(4'h3, 16'hA000, 16'h0F0F,
              16'hAF0F, 0, 0, 0, 1);

        check(4'h4, 16'hAAAA, 16'hFFFF,
              16'h5555, 0, 0, 0, 0);

        check(4'h5, 16'h0001, 16'h0004,
              16'h0010, 0, 0, 0, 0);

        check(4'h6, 16'h8000, 16'h0001,
              16'h4000, 0, 0, 0, 0);

        check(4'h7, 16'h8000, 16'h0001,
              16'hC000, 0, 0, 0, 1);

        check(4'h8, 16'hFFFF, 16'h0001,
              16'h0001, 0, 0, 0, 0);

        check(4'h9, 16'hFFFF, 16'h0001,
              16'h0000, 0, 0, 1, 0);

        check(4'hA, 16'h1234, 16'h5678,
              16'h0000, 0, 0, 0, 0);

        if (errors == 0)
            $display("ALL 15 ALU TESTS PASSED");
        else
            $display("%0d TESTS FAILED", errors);

        $finish;
    end

endmodule