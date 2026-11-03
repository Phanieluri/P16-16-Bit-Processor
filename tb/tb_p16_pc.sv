`timescale 1ns/1ps

module tb_p16_pc;

    logic clk = 0;
    logic reset = 0;
    logic enable = 0;
    logic branch_taken = 0;
    logic [5:0] branch_offset = 0;
    logic jump = 0;
    logic [7:0] jump_target = 0;

    logic [7:0] pc;
    integer errors = 0;

    always #5 clk = ~clk;

    p16_pc dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .branch_taken(branch_taken),
        .branch_offset(branch_offset),
        .jump(jump),
        .jump_target(jump_target),
        .pc(pc)
    );

    task automatic step_check(
        input logic [7:0] expected,
        input logic en,
        input logic br,
        input logic jmp,
        input logic [5:0] offset,
        input logic [7:0] target,
        input string test_name
    );
        begin
            @(negedge clk);
            enable        = en;
            branch_taken  = br;
            jump           = jmp;
            branch_offset = offset;
            jump_target   = target;

            @(posedge clk);
            #1;

            if (pc !== expected) begin
                errors = errors + 1;
                $display(
                    "FAIL: %s | got=%h expected=%h",
                    test_name, pc, expected
                );
            end
            else begin
                $display("PASS: %s | PC=%h", test_name, pc);
            end
        end
    endtask

    initial begin
        $dumpfile("build/p16_pc.vcd");
        $dumpvars(0, tb_p16_pc);

        // Reset PC to address zero
        reset = 1;
        @(posedge clk);
        #1;

        if (pc !== 8'h00) begin
            errors = errors + 1;
            $display("FAIL: Reset | PC=%h", pc);
        end
        else begin
            $display("PASS: Reset | PC=00");
        end

        reset = 0;

        step_check(8'h01, 1, 0, 0, 6'd0, 8'h00,
                   "Normal increment 00 -> 01");

        step_check(8'h02, 1, 0, 0, 6'd0, 8'h00,
                   "Normal increment 01 -> 02");

        step_check(8'h05, 1, 1, 0, 6'd2, 8'h00,
                   "Forward branch +2");

        step_check(8'h04, 1, 1, 0, 6'b111110, 8'h00,
                   "Backward branch -2");

        step_check(8'hFE, 1, 0, 1, 6'd0, 8'hFE,
                   "Absolute jump");

        step_check(8'hFE, 0, 0, 0, 6'd0, 8'h00,
                   "PC holds when disabled");

        step_check(8'hFF, 1, 0, 0, 6'd0, 8'h00,
                   "Increment to FF");

        step_check(8'h00, 1, 0, 0, 6'd0, 8'h00,
                   "PC wraps from FF to 00");

        step_check(8'h80, 1, 1, 1, 6'd1, 8'h80,
                   "Jump takes priority over branch");

        // Reset again to confirm synchronous reset
        @(negedge clk);
        reset = 1;
        enable = 1;

        @(posedge clk);
        #1;

        if (pc !== 8'h00) begin
            errors = errors + 1;
            $display("FAIL: Second reset | PC=%h", pc);
        end
        else begin
            $display("PASS: Second reset | PC=00");
        end

        if (errors == 0)
            $display("ALL PC TESTS PASSED");
        else
            $display("%0d PC TESTS FAILED", errors);

        $finish;
    end

endmodule
