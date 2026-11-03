module p16_regfile (
    input  logic        clk,
    input  logic        reset,

    input  logic        we,
    input  logic [2:0]  ra1,
    input  logic [2:0]  ra2,
    input  logic [2:0]  wa,
    input  logic [15:0] wd,

    output logic [15:0] rd1,
    output logic [15:0] rd2
);

    // Eight 16-bit registers: R0 to R7
    logic [15:0] regs [0:7];

    integer i;

    // Synchronous, active-high reset and register writes
    always_ff @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 8; i = i + 1)
                regs[i] <= 16'h0000;
        end
        else if (we && (wa != 3'd0)) begin
            regs[wa] <= wd;
        end
    end

    // Two asynchronous read ports
    // R0 is hardwired to zero
    always_comb begin
        rd1 = 16'h0000;
        rd2 = 16'h0000;

        if (ra1 != 3'd0)
            rd1 = regs[ra1];

        if (ra2 != 3'd0)
            rd2 = regs[ra2];
    end

endmodule