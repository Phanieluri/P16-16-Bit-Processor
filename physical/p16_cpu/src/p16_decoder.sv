module p16_decoder (
    input  logic [15:0] instruction,

    output logic [3:0]  opcode,
    output logic [2:0]  rd,
    output logic [2:0]  rs1,
    output logic [2:0]  rs2,
    output logic [5:0]  imm6,
    output logic [7:0]  jump_target,

    output logic [3:0]  alu_op,

    output logic        reg_write,
    output logic        mem_read,
    output logic        mem_write,
    output logic        alu_src_imm,
    output logic        mem_to_reg,
    output logic        branch_eq,
    output logic        jump,
    output logic        halt,
    output logic        valid_instruction
);

    always_comb begin

        // Decode instruction fields
        opcode      = instruction[15:12];
        rd          = instruction[11:9];
        rs1         = instruction[8:6];
        rs2         = instruction[5:3];
        imm6        = instruction[5:0];
        jump_target = instruction[7:0];

        // Safe defaults
        alu_op           = 4'h0;
        reg_write        = 1'b0;
        mem_read         = 1'b0;
        mem_write        = 1'b0;
        alu_src_imm      = 1'b0;
        mem_to_reg       = 1'b0;
        branch_eq        = 1'b0;
        jump             = 1'b0;
        halt             = 1'b0;
        valid_instruction = 1'b0;

        case (opcode)

            // Register-to-register ALU instructions: 0 through 9
            4'h0, 4'h1, 4'h2, 4'h3, 4'h4,
            4'h5, 4'h6, 4'h7, 4'h8, 4'h9: begin

                // Low three bits are reserved and must be zero
                if (instruction[2:0] == 3'b000) begin
                    valid_instruction = 1'b1;
                    reg_write = 1'b1;
                    alu_op = opcode;
                end
            end

            // ADDI: rd = rs1 + signed immediate
            4'hA: begin
                valid_instruction = 1'b1;
                reg_write = 1'b1;
                alu_src_imm = 1'b1;
                alu_op = 4'h0;
            end

            // LD: rd = memory[base + offset]
            4'hB: begin
                valid_instruction = 1'b1;
                reg_write = 1'b1;
                mem_read = 1'b1;
                alu_src_imm = 1'b1;
                mem_to_reg = 1'b1;
                alu_op = 4'h0;
            end

            // ST: memory[base + offset] = source register
            4'hC: begin
                valid_instruction = 1'b1;
                mem_write = 1'b1;
                alu_src_imm = 1'b1;
                alu_op = 4'h0;
            end

            // BEQ: branch if registers are equal
            4'hD: begin
                valid_instruction = 1'b1;
                branch_eq = 1'b1;

                // BEQ has its own register field layout
                rs1 = instruction[11:9];
                rs2 = instruction[8:6];
            end

            // JMP: absolute 8-bit word address
            4'hE: begin
                if (instruction[11:8] == 4'b0000) begin
                    valid_instruction = 1'b1;
                    jump = 1'b1;
                end
            end

            // HALT: all reserved bits must be zero
            4'hF: begin
                if (instruction[11:0] == 12'b0) begin
                    valid_instruction = 1'b1;
                    halt = 1'b1;
                end
            end

            // Invalid instructions retain safe control defaults
            default: begin
            end

        endcase
    end

endmodule       