`timescale 1ns/1ps

module p16_dmem (
    input  logic        clk,
    input  logic        read_en,
    input  logic        write_en,
    input  logic [7:0]  addr,
    input  logic [15:0] write_data,
    output logic [15:0] read_data
);

    // 256 words, each 16 bits wide
    logic [15:0] mem [0:255];

    // Synchronous memory writes
    always_ff @(posedge clk) begin
        if (write_en)
            mem[addr] <= write_data;
    end

    // Combinational memory reads
    always_comb begin
        if (read_en)
            read_data = mem[addr];
        else
            read_data = 16'h0000;
    end

endmodule