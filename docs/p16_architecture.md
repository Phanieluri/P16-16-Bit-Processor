
# P16 — Processor Architecture Specification

Version: 1.0
Status: Initial design specification

## 1. Architecture

- Architecture type: Custom RISC-style processor
- Datapath width: 16 bits
- Instruction width: 16 bits
- Instruction address width: 8 bits
- Program counter: 8-bit, word-addressed
- General-purpose registers: R0-R7, each 16 bits
- R0 is hardwired to zero
- Instruction memory: External interface, 256 words x 16 bits
- Data memory: External interface, 256 words x 16 bits
- Initial implementation: Single-cycle, non-pipelined
- Reset: Synchronous, active-high

## 2. ALU

Reuse the existing p16_alu module.

Operations:
- 0: ADD
- 1: SUB
- 2: AND
- 3: OR
- 4: XOR
- 5: SLL
- 6: SRL
- 7: SRA
- 8: SLT
- 9: SLTU

## 3. Instruction formats

All instructions are 16 bits.

### Register operations: ADD through SLTU

- [15:12] Opcode
- [11:9] Destination register rd
- [8:6] Source register rs1
- [5:3] Source register rs2
- [2:0] Reserved; must be zero

### ADDI

- [15:12] Opcode A
- [11:9] Destination register rd
- [8:6] Source register rs1
- [5:0] Signed immediate, two's-complement

### LD

- [15:12] Opcode B
- [11:9] Destination register rd
- [8:6] Base register
- [5:0] Signed word offset

### ST

- [15:12] Opcode C
- [11:9] Source register
- [8:6] Base register
- [5:0] Signed word offset

### BEQ

- [15:12] Opcode D
- [11:9] Source register rs1
- [8:6] Source register rs2
- [5:0] Signed branch offset

### JMP

- [15:12] Opcode E
- [11:8] Reserved; must be zero
- [7:0] Absolute instruction word address

### HALT

- [15:12] Opcode F
- [11:0] Reserved; must be zero

## 4. Execution rules

- PC starts at address 0 after reset.
- Normal instructions advance PC by one word.
- BEQ branches when rs1 equals rs2.
- Branch target = PC + 1 + sign-extended offset.
- JMP loads the specified absolute word address into PC.
- PC arithmetic wraps modulo 256.
- Register writes to R0 are discarded.
- Signed immediates use two's-complement representation.
- LD/ST effective address = base register's low 8 bits
  plus the sign-extended offset, modulo 256.
- Memory addresses identify 16-bit words, not bytes.
- Data memory reads are combinational for this initial model.
- Data memory writes occur on the rising clock edge.
- HALT sets a halted state until reset.
- Unsupported or malformed instructions halt execution.
- The ALU's flags are internal; BEQ compares register values.

## 5. Verification requirements

- Reset initializes PC and processor state.
- R0 always reads zero.
- Arithmetic and logical instructions produce correct results.
- Register writes target the correct destination.
- Loads and stores use the correct effective addresses.
- Branches and jumps update PC correctly.
- HALT prevents further instruction execution.
- Testbench checks results automatically.
