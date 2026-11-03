`timescale 1ns/1ps

module p16_cpu (
    input  logic        clk,
    input  logic        reset,

    // Instruction-memory interface
    input  logic [15:0] instruction,
    output logic [7:0]  instr_addr,

    // Data-memory interface
    output logic        data_read_en,
    output logic        data_write_en,
    output logic [7:0]  data_addr,
    output logic [15:0] data_write_data,
    input  logic [15:0] data_read_data,

    // Processor status
    output logic        halted,
    output logic        fault
);

    // Decoder signals
    logic [3:0] opcode;
    logic [2:0] rd, rs1, rs2;
    logic [5:0] imm6;
    logic [7:0] jump_target;
    logic [3:0] alu_op;

    logic dec_reg_write;
    logic dec_mem_read;
    logic dec_mem_write;
    logic dec_alu_src_imm;
    logic dec_mem_to_reg;
    logic dec_branch_eq;
    logic dec_jump;
    logic dec_halt;
    logic valid_instruction;

    // Register-file signals
    logic [2:0]  rf_ra2;
    logic [15:0] rf_rd1;
    logic [15:0] rf_rd2;
    logic [15:0] rf_write_data;
    logic        rf_write_enable;

    // ALU signals
    logic [15:0] alu_b;
    logic [15:0] alu_result;
    logic        alu_zero;
    logic        alu_negative;
    logic        alu_carry;
    logic        alu_overflow;

    // Program-counter signals
    logic [7:0] pc_value;
    logic        pc_enable;
    logic        branch_taken;
    logic        pc_jump;

    logic active_instruction;

    assign instr_addr = pc_value;

    // Instruction decoder
    p16_decoder u_decoder (
        .instruction       (instruction),
        .opcode            (opcode),
        .rd                (rd),
        .rs1               (rs1),
        .rs2               (rs2),
        .imm6              (imm6),
        .jump_target       (jump_target),
        .alu_op            (alu_op),
        .reg_write         (dec_reg_write),
        .mem_read          (dec_mem_read),
        .mem_write         (dec_mem_write),
        .alu_src_imm       (dec_alu_src_imm),
        .mem_to_reg        (dec_mem_to_reg),
        .branch_eq         (dec_branch_eq),
        .jump              (dec_jump),
        .halt              (dec_halt),
        .valid_instruction (valid_instruction)
    );

    // Register-file read port 2:
    // ST uses rd as its source-register field.
    always_comb begin
        rf_ra2 = rs2;

        if (opcode == 4'hC)
            rf_ra2 = rd;
    end

    p16_regfile u_regfile (
        .clk   (clk),
        .reset (reset),
        .we    (rf_write_enable),
        .ra1   (rs1),
        .ra2   (rf_ra2),
        .wa    (rd),
        .wd    (rf_write_data),
        .rd1   (rf_rd1),
        .rd2   (rf_rd2)
    );

    // Select register or sign-extended immediate as ALU operand B.
    always_comb begin
        if (dec_alu_src_imm)
            alu_b = {{10{imm6[5]}}, imm6};
        else
            alu_b = rf_rd2;
    end

    p16_alu u_alu (
        .a        (rf_rd1),
        .b        (alu_b),
        .op       (alu_op),
        .result   (alu_result),
        .zero     (alu_zero),
        .negative (alu_negative),
        .carry    (alu_carry),
        .overflow (alu_overflow)
    );

    // Data-memory interface
    always_comb begin
        data_addr       = alu_result[7:0];
        data_write_data = rf_rd2;

        active_instruction =
            !reset && !halted && valid_instruction;

        data_read_en  = active_instruction && dec_mem_read;
        data_write_en = active_instruction && dec_mem_write;

        if (dec_mem_to_reg)
            rf_write_data = data_read_data;
        else
            rf_write_data = alu_result;

        rf_write_enable =
            active_instruction && dec_reg_write;

        // BEQ compares the two source-register values.
        branch_taken =
            active_instruction &&
            dec_branch_eq &&
            (rf_rd1 == rf_rd2);

        pc_jump = active_instruction && dec_jump;

        // Valid instructions advance the PC, except HALT.
        pc_enable = active_instruction && !dec_halt;
    end

    p16_pc u_pc (
        .clk           (clk),
        .reset         (reset),
        .enable        (pc_enable),
        .branch_taken  (branch_taken),
        .branch_offset (imm6),
        .jump           (pc_jump),
        .jump_target   (jump_target),
        .pc             (pc_value)
    );

    // Stop on HALT or an invalid instruction.
    always_ff @(posedge clk) begin
        if (reset) begin
            halted <= 1'b0;
            fault  <= 1'b0;
        end
        else if (!halted) begin
            if (!valid_instruction) begin
                halted <= 1'b1;
                fault  <= 1'b1;
            end
            else if (dec_halt) begin
                halted <= 1'b1;
                fault  <= 1'b0;
            end
        end
    end

endmodule