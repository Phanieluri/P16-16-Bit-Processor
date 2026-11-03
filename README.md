# P16 — Custom 16-bit RISC-Style Processor

A custom 16-bit processor designed using Verilog/SystemVerilog, verified through simulation, synthesized using Yosys, and physically implemented targeting the SkyWater SKY130A process.

## Project Overview

P16 is an educational 16-bit RISC-style processor developed from the ground up to explore digital architecture, RTL design, functional verification, synthesis, and ASIC physical design.

The project covers the development process from describing hardware in RTL to generating and inspecting a GDSII physical layout.

## Architecture Specifications

| Specification | Description |
|---|---|
| Processor | P16 |
| Architecture | Custom 16-bit RISC-style |
| Datapath width | 16-bit |
| General-purpose registers | 8 |
| Register R0 | Hardwired to zero |
| Program counter | 8-bit, word-addressed |
| Execution model | Single-cycle, non-pipelined |
| Instruction width | 16-bit |
| Physical-design target | SkyWater SKY130A |
| Standard-cell library | sky130_fd_sc_hd |

## Processor Components

- **ALU:** Arithmetic, logical, shift and comparison operations.
- **Register File:** Eight 16-bit general-purpose registers with two asynchronous read ports and one write port.
- **Program Counter:** Sequential instruction addressing, conditional branching and jumping.
- **Instruction Decoder:** Decodes instructions and generates control signals.
- **Control Logic:** Coordinates processor operations.
- **Data Memory Interface:** Supports load and store operations.

The physical-design top-level is `p16_cpu`, which exposes external instruction-memory and data-memory interfaces. The `p16_system` module is a simulation wrapper containing instruction ROM and data memory.

## Instruction Set

### Register Operations

| Operation | Function |
|---|---|
| ADD | Addition |
| SUB | Subtraction |
| AND | Bitwise AND |
| OR | Bitwise OR |
| XOR | Bitwise XOR |
| SLL | Logical left shift |
| SRL | Logical right shift |
| SRA | Arithmetic right shift |
| SLT | Signed comparison |
| SLTU | Unsigned comparison |

### Other Instructions

| Instruction | Function |
|---|---|
| ADDI | Add immediate |
| LD | Load from data memory |
| ST | Store to data memory |
| BEQ | Branch if equal |
| JMP | Absolute jump |
| HALT | Stop execution |

## Example Program

The following program calculates 5 + 3:

```text
ADDI R1, R0, 5
ADDI R2, R0, 3
ADD  R3, R1, R2
HALT
```

Expected register values:

```text
R1 = 5
R2 = 3
R3 = 8
```

## Verification

The project includes individual testbenches for the ALU, register file, program counter, decoder, data memory and CPU.

The integrated system test exercises arithmetic, memory operations, conditional branching, jumping and processor halt behaviour.

Simulation is performed using Icarus Verilog, with waveform inspection through GTKWave.

## ASIC Physical Design

The P16 CPU is targeted to the SkyWater SKY130A PDK using the `sky130_fd_sc_hd` standard-cell library.

Tools used:

- Verilator — RTL linting
- Yosys — Logic synthesis
- LibreLane — ASIC physical-design flow
- KLayout — GDSII layout inspection
- GTKWave — Simulation waveform inspection

A GDSII layout was generated and opened in KLayout. Physical signoff status, including DRC and timing results, is documented separately as those checks are verified.

## Repository Structure

```text
rtl/         Processor RTL modules
tb/          Simulation testbenches
physical/    ASIC physical-design configuration and RTL package
docs/        Architecture, test results and screenshots
artifacts/   Release and layout information
```

## Current Project Status

- Custom processor RTL completed.
- Individual module simulations passed.
- Integrated processor simulation passed.
- Synthesis netlist generated.
- GDSII physical layout generated and inspected in KLayout.
- Physical signoff reports still to be reviewed.

## Scope and Limitations

P16 is an educational processor implementation, not a commercial mobile SoC. It does not include an integrated GPU, NPU, cache hierarchy or on-chip program/data memory in the physical CPU top-level.

The generated GDSII is a design layout, not a fabricated silicon chip.

## Objective

To gain practical experience in custom processor architecture, RTL implementation, verification, logic synthesis and ASIC physical design.

**Project:** P16 — Custom 16-bit Processor  
**HDL:** SystemVerilog  
**ASIC Target:** SkyWater SKY130A
