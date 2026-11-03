module p16_pc (
    input  logic       clk,
    input  logic       reset,
    input  logic       enable,

    input  logic       branch_taken,
    input  logic [5:0] branch_offset,

    input  logic       jump,
    input  logic [7:0] jump_target,

    output logic [7:0] pc
);

    logic [7:0] pc_plus_one;
    logic [7:0] pc_next;
    logic signed [7:0] branch_disp;

    // Sign-extend the 6-bit branch offset to 8 bits
    always_comb begin
        branch_disp = {{2{branch_offset[5]}}, branch_offset};

        // Instructions are addressed in 16-bit words
        pc_plus_one = pc + 8'd1;

        // Jump has priority over a conditional branch
        if (jump)
            pc_next = jump_target;
        else if (branch_taken)
            pc_next = pc_plus_one + branch_disp;
        else
            pc_next = pc_plus_one;
    end

    // Synchronous, active-high reset
    always_ff @(posedge clk) begin
        if (reset)
            pc <= 8'h00;
        else if (enable)
            pc <= pc_next;
    end

endmodule