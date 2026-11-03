`timescale 1ns/1ps

module tb_p16_regfile;

    logic clk = 0;
    logic reset;
    logic we;

    logic [2:0]  ra1, ra2, wa;
    logic [15:0] wd;
    logic [15:0] rd1, rd2;

    integer errors = 0;

    always #5 clk = ~clk;

    p16_regfile dut (
        .clk(clk),
        .reset(reset),
        .we(we),
        .ra1(ra1),
        .ra2(ra2),
        .wa(wa),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    task automatic check_read(
        input logic [2:0]  r1,
        input logic [2:0]  r2,
        input logic [15:0] expected1,
        input logic [15:0] expected2
    );
        begin
            ra1 = r1;
            ra2 = r2;
            #1;

            if (rd1 !== expected1 || rd2 !== expected2) begin
                errors = errors + 1;
                $display(
                    "FAIL: R%0d=%h (expected %h), R%0d=%h (expected %h)",
                    r1, rd1, expected1,
                    r2, rd2, expected2
                );
            end
            else begin
                $display(
                    "PASS: R%0d=%h, R%0d=%h",
                    r1, rd1, r2, rd2
                );
            end
        end
    endtask

    task automatic write_register(
        input logic [2:0]  address,
        input logic [15:0] data
    );
        begin
            @(negedge clk);
            we = 1;
            wa = address;
            wd = data;

            @(posedge clk);
            #1;
            we = 0;
        end
    endtask

    initial begin
        $dumpfile("build/p16_regfile.vcd");
        $dumpvars(0, tb_p16_regfile);

        reset = 1;
        we = 0;
        ra1 = 0;
        ra2 = 0;
        wa = 0;
        wd = 0;

        // Reset all registers
        @(posedge clk);
        #1;
        reset = 0;

        check_read(3'd0, 3'd1, 16'h0000, 16'h0000);

        // Write and read R1
        write_register(3'd1, 16'hABCD);
        check_read(3'd1, 3'd1, 16'hABCD, 16'hABCD);

        // Write R7 and read two registers simultaneously
        write_register(3'd7, 16'h1357);
        check_read(3'd1, 3'd7, 16'hABCD, 16'h1357);

        // Attempt to write R0; it must remain zero
        write_register(3'd0, 16'hFFFF);
        check_read(3'd0, 3'd1, 16'h0000, 16'hABCD);

        // Reset must clear the stored values
        @(negedge clk);
        reset = 1;
        @(posedge clk);
        #1;
        reset = 0;

        check_read(3'd1, 3'd7, 16'h0000, 16'h0000);

        if (errors == 0)
            $display("ALL REGISTER FILE TESTS PASSED");
        else
            $display("%0d REGISTER FILE TESTS FAILED", errors);

        $finish;
    end

endmodule