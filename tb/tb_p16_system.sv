`timescale 1ns/1ps

module tb_p16_system;

    logic clk = 0;
    logic reset = 1;

    logic [7:0] pc_debug;
    logic halted;
    logic fault;

    integer cycles = 0;
    integer errors = 0;

    always #5 clk = ~clk;

    p16_system dut (
        .clk      (clk),
        .reset    (reset),
        .pc_debug (pc_debug),
        .halted   (halted),
        .fault    (fault)
    );

    initial begin
        $dumpfile("build/p16_system.vcd");
        $dumpvars(0, tb_p16_system);

        // Apply synchronous reset
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        // Wait for HALT, with a timeout
        while ((halted !== 1'b1) && (cycles < 40)) begin
            @(posedge clk);
            #1;
            cycles = cycles + 1;
        end

        $display("");
        $display("=== P16 SYSTEM RESULTS ===");
        $display("Cycles: %0d", cycles);
        $display("PC: %h", pc_debug);
        $display("Halted: %b", halted);
        $display("Fault: %b", fault);

        if (halted !== 1'b1) begin
            errors = errors + 1;
            $display("FAIL: Processor did not halt");
        end

        if (fault !== 1'b0) begin
            errors = errors + 1;
            $display("FAIL: Unexpected processor fault");
        end

        if (pc_debug !== 8'd13) begin
            errors = errors + 1;
            $display("FAIL: Incorrect final PC");
        end

        // Check architectural registers
        if (dut.u_cpu.u_regfile.regs[0] !== 16'd0)
            errors = errors + 1;

        if (dut.u_cpu.u_regfile.regs[1] !== 16'd5)
            errors = errors + 1;

        if (dut.u_cpu.u_regfile.regs[2] !== 16'd3)
            errors = errors + 1;

        if (dut.u_cpu.u_regfile.regs[3] !== 16'd8)
            errors = errors + 1;

        if (dut.u_cpu.u_regfile.regs[4] !== 16'd8)
            errors = errors + 1;

        if (dut.u_cpu.u_regfile.regs[5] !== 16'd42)
            errors = errors + 1;

        if (dut.u_cpu.u_regfile.regs[6] !== 16'd5)
            errors = errors + 1;

        if (dut.u_cpu.u_regfile.regs[7] !== 16'd0)
            errors = errors + 1;

        // Check the store result
        if (dut.u_dmem.mem[10] !== 16'd8)
            errors = errors + 1;

        if (errors == 0)
            $display("P16 COMPLETE SYSTEM TEST PASSED");
        else
            $display("%0d SYSTEM CHECKS FAILED", errors);

        $finish;
    end

endmodule