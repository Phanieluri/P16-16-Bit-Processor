`timescale 1ns/1ps

module tb_p16_cpu;

    logic clk = 0;
    logic reset = 1;

    logic [15:0] instruction;
    logic [7:0]  instr_addr;

    logic data_read_en;
    logic data_write_en;
    logic [7:0]  data_addr;
    logic [15:0] data_write_data;
    logic [15:0] data_read_data;

    logic halted;
    logic fault;

    logic [15:0] imem [0:255];

    integer i;
    integer cycles;
    integer errors;

    always #5 clk = ~clk;

    // Instruction memory for this test.
    always @*
        instruction = imem[instr_addr];

    p16_cpu dut (
        .clk             (clk),
        .reset           (reset),
        .instruction     (instruction),
        .instr_addr      (instr_addr),
        .data_read_en    (data_read_en),
        .data_write_en   (data_write_en),
        .data_addr       (data_addr),
        .data_write_data (data_write_data),
        .data_read_data  (data_read_data),
        .halted          (halted),
        .fault           (fault)
    );

    p16_dmem u_dmem (
        .clk        (clk),
        .read_en    (data_read_en),
        .write_en   (data_write_en),
        .addr       (data_addr),
        .write_data (data_write_data),
        .read_data  (data_read_data)
    );

    initial begin
        $dumpfile("build/p16_cpu.vcd");
        $dumpvars(0, tb_p16_cpu);

        errors = 0;
        cycles = 0;

        // Invalid instructions fill unused addresses so an
        // unexpected execution path raises the fault signal.
        for (i = 0; i < 256; i = i + 1)
            imem[i] = 16'hF001;

        // Program begins at instruction address 0.

        // R1 = 5
        imem[0] = {4'hA, 3'd1, 3'd0, 6'd5};

        // R2 = 3
        imem[1] = {4'hA, 3'd2, 3'd0, 6'd3};

        // R3 = R1 + R2 = 8
        imem[2] = {4'h0, 3'd3, 3'd1, 3'd2, 3'b000};

        // Store R3 at data-memory word address 10.
        imem[3] = {4'hC, 3'd3, 3'd0, 6'd10};

        // Load memory[10] into R4.
        imem[4] = {4'hB, 3'd4, 3'd0, 6'd10};

        // If R3 == R4, skip the next two instructions.
        imem[5] = {4'hD, 3'd3, 3'd4, 6'd2};

        // These instructions must be skipped by the branch.
        imem[6] = {4'hA, 3'd7, 3'd0, 6'd25};
        imem[7] = {4'hA, 3'd7, 3'd0, 6'd13};

        // R5 = 21
        imem[8] = {4'hA, 3'd5, 3'd0, 6'd21};

        // R5 = R5 + R5 = 42
        imem[9] = {4'h0, 3'd5, 3'd5, 3'd5, 3'b000};

        // R6 = R3 - R2 = 5
        imem[10] = {4'h1, 3'd6, 3'd3, 3'd2, 3'b000};

        // Jump to instruction address 13
        imem[11] = {4'hE, 4'h0, 8'd13};

        // Must be skipped by the jump
        imem[12] = {4'hA, 3'd5, 3'd0, 6'd11};

        // Stop the program
        imem[13] = 16'hF000;

        // Apply synchronous reset for two rising clock edges.
        repeat (2) @(posedge clk);

        @(negedge clk);
        reset = 0;

        // Wait for HALT, or stop if execution runs too long.
        while ((halted !== 1'b1) && (cycles < 40)) begin
            @(posedge clk);
            #1;
            cycles = cycles + 1;
        end

        $display("");
        $display("=== P16 CPU INTEGRATION RESULTS ===");
        $display("Cycles executed: %0d", cycles);
        $display("Final PC: %h", instr_addr);
        $display("Halted: %b", halted);
        $display("Fault: %b", fault);

        if (halted !== 1'b1) begin
            errors = errors + 1;
            $display("FAIL: CPU did not halt");
        end

        if (fault !== 1'b0) begin
            errors = errors + 1;
            $display("FAIL: CPU raised an invalid-instruction fault");
        end

        if (instr_addr !== 8'd13) begin
            errors = errors + 1;
            $display("FAIL: Incorrect final PC");
        end

        if (dut.u_regfile.regs[1] !== 16'd5) begin
            errors = errors + 1;
            $display("FAIL: R1 should equal 5");
        end

        if (dut.u_regfile.regs[2] !== 16'd3) begin
            errors = errors + 1;
            $display("FAIL: R2 should equal 3");
        end

        if (dut.u_regfile.regs[3] !== 16'd8) begin
            errors = errors + 1;
            $display("FAIL: R3 should equal 8");
        end

        if (dut.u_regfile.regs[4] !== 16'd8) begin
            errors = errors + 1;
            $display("FAIL: R4 should equal 8");
        end

        if (dut.u_regfile.regs[5] !== 16'd42) begin
            errors = errors + 1;
            $display("FAIL: R5 should equal 42");
        end

        if (dut.u_regfile.regs[6] !== 16'd5) begin
            errors = errors + 1;
            $display("FAIL: R6 should equal 5");
        end

        if (dut.u_regfile.regs[7] !== 16'd0) begin
            errors = errors + 1;
            $display("FAIL: Branch did not skip the expected instructions");
        end

        if (u_dmem.mem[10] !== 16'd8) begin
            errors = errors + 1;
            $display("FAIL: Data memory word 10 should equal 8");
        end

        if (errors == 0)
            $display("P16 CPU PROGRAM TEST PASSED");
        else
            $display("%0d CPU TESTS FAILED", errors);

        $finish;
    end

endmodule