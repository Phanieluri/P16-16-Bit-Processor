`timescale 1ns/1ps

module p16_system (
    input  logic       clk,
    input  logic       reset,
    output logic [7:0] pc_debug,
    output logic       halted,
    output logic       fault
);

    logic [15:0] instruction;
    logic [7:0]  instr_addr;

    logic        data_read_en;
    logic        data_write_en;
    logic [7:0]  data_addr;
    logic [15:0] data_write_data;
    logic [15:0] data_read_data;

    logic [15:0] imem [0:255];
    integer i;

    assign pc_debug = instr_addr;

    // Demo instruction ROM
    initial begin
        for (i = 0; i < 256; i = i + 1)
            imem[i] = 16'hF001; // Invalid instruction sentinel

        // R1 = 5
        imem[0] = {4'hA, 3'd1, 3'd0, 6'd5};

        // R2 = 3
        imem[1] = {4'hA, 3'd2, 3'd0, 6'd3};

        // R3 = R1 + R2 = 8
        imem[2] = {4'h0, 3'd3, 3'd1, 3'd2, 3'b000};

        // Store R3 at data-memory address 10
        imem[3] = {4'hC, 3'd3, 3'd0, 6'd10};

        // Load memory[10] into R4
        imem[4] = {4'hB, 3'd4, 3'd0, 6'd10};

        // If R3 == R4, skip two instructions
        imem[5] = {4'hD, 3'd3, 3'd4, 6'd2};

        // These two instructions must be skipped
        imem[6] = {4'hA, 3'd7, 3'd0, 6'd25};
        imem[7] = {4'hA, 3'd7, 3'd0, 6'd13};

        // R5 = 21
        imem[8] = {4'hA, 3'd5, 3'd0, 6'd21};

        // R5 = R5 + R5 = 42
        imem[9] = {4'h0, 3'd5, 3'd5, 3'd5, 3'b000};

        // R6 = R3 - R2 = 5
        imem[10] = {4'h1, 3'd6, 3'd3, 3'd2, 3'b000};

        // Jump to HALT at address 13
        imem[11] = {4'hE, 4'h0, 8'd13};

        // This instruction must be skipped
        imem[12] = {4'hA, 3'd5, 3'd0, 6'd11};

        // HALT
        imem[13] = 16'hF000;
    end

    // Combinational instruction fetch
    always_comb begin
        instruction = imem[instr_addr];
    end

    // Processor core
    p16_cpu u_cpu (
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

    // Separate data-memory instance
    p16_dmem u_dmem (
        .clk        (clk),
        .read_en    (data_read_en),
        .write_en   (data_write_en),
        .addr       (data_addr),
        .write_data (data_write_data),
        .read_data  (data_read_data)
    );

endmodule