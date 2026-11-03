`timescale 1ns/1ps

module tb_p16_dmem;

    logic clk = 0;
    logic read_en = 0;
    logic write_en = 0;

    logic [7:0]  addr = 0;
    logic [15:0] write_data = 0;
    logic [15:0] read_data;

    integer errors = 0;

    always #5 clk = ~clk;

    p16_dmem dut (
        .clk(clk),
        .read_en(read_en),
        .write_en(write_en),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data)
    );

    task automatic write_word(
        input logic [7:0] address,
        input logic [15:0] data
    );
        begin
            @(negedge clk);
            addr = address;
            write_data = data;
            write_en = 1;

            @(posedge clk);
            #1;
            write_en = 0;
        end
    endtask

    task automatic check_read(
        input logic [7:0] address,
        input logic [15:0] expected
    );
        begin
            addr = address;
            read_en = 1;
            #1;

            if (read_data !== expected) begin
                errors = errors + 1;
                $display(
                    "FAIL: address=%h got=%h expected=%h",
                    address, read_data, expected
                );
            end
            else begin
                $display(
                    "PASS: address=%h data=%h",
                    address, read_data
                );
            end

            read_en = 0;
        end
    endtask

    initial begin
        $dumpfile("build/p16_dmem.vcd");
        $dumpvars(0, tb_p16_dmem);

        // Write and read a normal address
        write_word(8'h00, 16'h1234);
        check_read(8'h00, 16'h1234);

        // Write and read the highest address
        write_word(8'hFF, 16'hBEEF);
        check_read(8'hFF, 16'hBEEF);

        // Confirm that the first word remains unchanged
        check_read(8'h00, 16'h1234);

        // A disabled read must return zero
        addr = 8'hFF;
        read_en = 0;
        #1;

        if (read_data !== 16'h0000) begin
            errors = errors + 1;
            $display("FAIL: disabled read");
        end
        else begin
            $display("PASS: disabled read");
        end

        // Disabled writes must not alter stored data
        @(negedge clk);
        addr = 8'h00;
        write_data = 16'hDEAD;
        write_en = 0;

        @(posedge clk);
        #1;
        check_read(8'h00, 16'h1234);

        if (errors == 0)
            $display("ALL DATA MEMORY TESTS PASSED");
        else
            $display("%0d DATA MEMORY TESTS FAILED", errors);

        $finish;
    end

endmodule