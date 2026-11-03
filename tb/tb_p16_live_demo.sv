
`timescale 1ns/1ps

module tb_p16_live_demo;

    logic clk = 0;
    logic reset = 1;

    logic [7:0] pc_debug;
    logic halted;
    logic fault;

    integer step;

    always #5 clk = ~clk;

    // Our P16 processor system
    p16_system dut (
        .clk      (clk),
        .reset    (reset),
        .pc_debug (pc_debug),
        .halted   (halted),
        .fault    (fault)
    );

    initial begin

        // Record signals for GTKWave
        $dumpfile("build/p16_live_demo.vcd");
        $dumpvars(0, tb_p16_live_demo);

        $display("");
        $display("======================================");
        $display("       P16 PROCESSOR LIVE DEMO");
        $display("======================================");

        // Reset the processor
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        $display("");
        $display("Starting P16...");
        $display("");

        // Execute the first three instructions
        for (step = 0; step < 3; step = step + 1) begin

            $display("--------------------------------------");
            $display("STEP %0d", step + 1);
            $display("Program Counter: %0d", pc_debug);
            $display("Machine Code: 0x%04h", dut.instruction);

            case (dut.instruction[15:12])

                4'hA:
                    $display(
                        "Instruction: ADDI R%0d, R%0d, %0d",
                        dut.instruction[11:9],
                        dut.instruction[8:6],
                        $signed(dut.instruction[5:0])
                    );

                4'h0:
                    $display(
                        "Instruction: ADD R%0d, R%0d, R%0d",
                        dut.instruction[11:9],
                        dut.instruction[8:6],
                        dut.instruction[5:3]
                    );

                default:
                    $display("Unknown instruction");
            endcase

            // Execute the instruction at the next clock edge
            @(posedge clk);
            #1;

            // Show processor register contents
            $display("");
            $display("REGISTER VALUES:");
            $display("R1 = %0d", dut.u_cpu.u_regfile.regs[1]);
            $display("R2 = %0d", dut.u_cpu.u_regfile.regs[2]);
            $display("R3 = %0d", dut.u_cpu.u_regfile.regs[3]);

            @(negedge clk);

        end

        $display("");
        $display("======================================");
        $display("          FINAL P16 RESULT");
        $display("======================================");

        $display("R1 = %0d", dut.u_cpu.u_regfile.regs[1]);
        $display("R2 = %0d", dut.u_cpu.u_regfile.regs[2]);
        $display("R3 = %0d", dut.u_cpu.u_regfile.regs[3]);

        if (dut.u_cpu.u_regfile.regs[1] == 16'd5 &&
            dut.u_cpu.u_regfile.regs[2] == 16'd3 &&
            dut.u_cpu.u_regfile.regs[3] == 16'd8) begin

            $display("");
            $display("SUCCESS: P16 COMPUTED 5 + 3 = 8");
        end
        else begin
            $display("");
            $display("FAIL: INCORRECT RESULT");
        end

        $display("======================================");

        $finish;

    end

endmodule
