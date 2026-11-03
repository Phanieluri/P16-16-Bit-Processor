# P16 — Custom 16-bit RISC-Style Processor

A custom 16-bit processor designed using SystemVerilog, verified through simulation, synthesized using Yosys, and physically implemented targeting the SkyWater SKY130A process.

## Architecture

- 16-bit datapath
- 8 general-purpose registers
- 16-bit instruction format
- ALU supporting arithmetic, logic, shifts and comparisons
- Instruction decoder
- Program counter
- Load/store operations
- Conditional branching and jumping
- HALT instruction

## Tools Used

| Tool | Purpose |
|---|---|
| SystemVerilog | RTL design |
| Icarus Verilog | Simulation |
| GTKWave | Waveform inspection |
| Verilator | RTL linting |
| Yosys | Logic synthesis |
| LibreLane | ASIC physical design |
| SkyWater SKY130A | Target PDK |
| KLayout | GDSII inspection |

## Demonstration

The processor executes a program that calculates:

5 + 3 = 8

The integrated simulation also tests memory operations, branching, jumping and processor halt behaviour.

## Physical Design

The P16 CPU was targeted to the SkyWater SKY130A standard-cell library (`sky130_fd_sc_hd`).

A GDSII layout was generated and opened in KLayout. Physical signoff, including DRC and timing checks, remains subject to verification.

## Repository Structure

- `rtl/` — Processor RTL modules
- `tb/` — Simulation testbenches
- `physical/` — Physical design configuration and source package
- `docs/` — Architecture documentation and test evidence

## Project Scope

P16 is an educational processor design. Its physical-design top-level is the CPU core with external instruction and data memory interfaces. It is not a fabricated silicon chip or a commercial mobile SoC.
