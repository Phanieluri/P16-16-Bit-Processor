`timescale 1ns/1ps

module tb_p16_decoder;

    logic [15:0] instruction;

    logic [3:0] opcode, alu_op;
    logic [2:0] rd, rs1, rs2;
    logic [5:0] imm6;
    logic [7:0] jump_target;

    logic reg_write, mem_read, mem_write;
    logic alu_src_imm, mem_to_reg, branch_eq;
    logic jump, halt, valid_instruction;

    integer errors = 0;

    p16_decoder dut (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .imm6(imm6),
        .jump_target(jump_target),
        .alu_op(alu_op),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_src_imm(alu_src_imm),
        .mem_to_reg(mem_to_reg),
        .branch_eq(branch_eq),
        .jump(jump),
        .halt(halt),
        .valid_instruction(valid_instruction)
    );

    task automatic check_decode(
        input string name,
        input logic [15:0] inst,
        input logic exp_valid,
        input logic exp_reg_write,
        input logic exp_mem_read,
        input logic exp_mem_write,
        input logic exp_alu_src_imm,
        input logic exp_mem_to_reg,
        input logic exp_branch_eq,
        input logic exp_jump,
        input logic exp_halt,
        input logic [3:0] exp_alu_op
    );

        logic [2:0] expected_rs1;
        logic [2:0] expected_rs2;

        begin
            instruction = inst;
            #1;

            expected_rs1 = inst[8:6];
            expected_rs2 = inst[5:3];

            if (inst[15:12] == 4'hD) begin
                expected_rs1 = inst[11:9];
                expected_rs2 = inst[8:6];
            end

            if (
                opcode !== inst[15:12] ||
                rd !== inst[11:9] ||
                rs1 !== expected_rs1 ||
                rs2 !== expected_rs2 ||
                imm6 !== inst[5:0] ||
                jump_target !== inst[7:0] ||
                valid_instruction !== exp_valid ||
                reg_write !== exp_reg_write ||
                mem_read !== exp_mem_read ||
                mem_write !== exp_mem_write ||
                alu_src_imm !== exp_alu_src_imm ||
                mem_to_reg !== exp_mem_to_reg ||
                branch_eq !== exp_branch_eq ||
                jump !== exp_jump ||
                halt !== exp_halt ||
                alu_op !== exp_alu_op
            ) begin
                errors = errors + 1;
                $display("FAIL: %s, instruction=%h",
                         name, inst);
            end
            else begin
                $display("PASS: %s", name);
            end
        end
    endtask

    initial begin
        $dumpfile("build/p16_decoder.vcd");
        $dumpvars(0, tb_p16_decoder);

        check_decode(
            "ADD",
            {4'h0,3'd1,3'd2,3'd3,3'b000},
            1,1,0,0,0,0,0,0,0,4'h0
        );

        check_decode(
            "SLTU",
            {4'h9,3'd1,3'd2,3'd3,3'b000},
            1,1,0,0,0,0,0,0,0,4'h9
        );

        check_decode(
            "ADDI",
            {4'hA,3'd1,3'd2,6'b111111},
            1,1,0,0,1,0,0,0,0,4'h0
        );

        check_decode(
            "LD",
            {4'hB,3'd4,3'd2,6'd3},
            1,1,1,0,1,1,0,0,0,4'h0
        );

        check_decode(
            "ST",
            {4'hC,3'd4,3'd2,6'd3},
            1,0,0,1,1,0,0,0,0,4'h0
        );

        check_decode(
            "BEQ",
            {4'hD,3'd1,3'd2,6'b111110},
            1,0,0,0,0,0,1,0,0,4'h0
        );

        check_decode(
            "JMP",
            {4'hE,4'b0000,8'hA5},
            1,0,0,0,0,0,0,1,0,4'h0
        );

        check_decode(
            "HALT",
            16'hF000,
            1,0,0,0,0,0,0,0,1,4'h0
        );

        check_decode(
            "Invalid R-type",
            {4'h0,3'd1,3'd2,3'd3,3'b001},
            0,0,0,0,0,0,0,0,0,4'h0
        );

        check_decode(
            "Invalid JMP",
            {4'hE,4'h1,8'hA5},
            0,0,0,0,0,0,0,0,0,4'h0
        );

        check_decode(
            "Invalid HALT",
            16'hF001,
            0,0,0,0,0,0,0,0,0,4'h0
        );

        if (errors == 0)
            $display("ALL DECODER TESTS PASSED");
        else
            $display("%0d DECODER TESTS FAILED", errors);

        $finish;
    end

endmodule