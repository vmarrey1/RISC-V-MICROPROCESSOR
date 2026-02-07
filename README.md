# RISC-V CPU Implementation

A 5-stage pipelined RISC-V CPU implementation supporting the RV32I base instruction set. This project demonstrates a complete CPU design suitable for educational purposes and portfolio demonstration.

## Architecture Overview

### Pipeline Stages

The CPU implements a classic 5-stage pipeline:

1. **IF (Instruction Fetch)**: Fetches instructions from instruction memory
2. **ID (Instruction Decode)**: Decodes instructions and reads register file
3. **EX (Execute)**: Performs arithmetic/logic operations using the ALU
4. **MEM (Memory)**: Accesses data memory for load/store operations
5. **WB (Write Back)**: Writes results back to the register file

### Key Features

- **RV32I Base Instruction Set**: Supports all standard RISC-V base integer instructions
- **5-Stage Pipeline**: Improves throughput by overlapping instruction execution
- **Hazard Detection**: Handles data hazards with pipeline stalls
- **Forwarding**: Implements data forwarding to reduce pipeline stalls
- **Branch Control**: Supports all RISC-V branch instructions (BEQ, BNE, BLT, BGE, BLTU, BGEU)
- **Jump Instructions**: Supports JAL and JALR for function calls and jumps

## Supported Instructions

### R-Type (Register-Register)
- `ADD`, `SUB`, `AND`, `OR`, `XOR`
- `SLL` (Shift Left Logical)
- `SRL` (Shift Right Logical)
- `SRA` (Shift Right Arithmetic)
- `SLT` (Set Less Than - signed)
- `SLTU` (Set Less Than - unsigned)

### I-Type (Immediate)
- `ADDI`, `ANDI`, `ORI`, `XORI`
- `SLLI`, `SRLI`, `SRAI`
- `SLTI`, `SLTIU`
- `LB`, `LH`, `LW` (Load Byte/Halfword/Word)
- `LBU`, `LHU` (Load Byte/Halfword Unsigned)
- `JALR` (Jump and Link Register)

### S-Type (Store)
- `SB`, `SH`, `SW` (Store Byte/Halfword/Word)

### B-Type (Branch)
- `BEQ`, `BNE` (Branch if Equal/Not Equal)
- `BLT`, `BGE` (Branch if Less Than/Greater or Equal - signed)
- `BLTU`, `BGEU` (Branch if Less Than/Greater or Equal - unsigned)

### U-Type (Upper Immediate)
- `LUI` (Load Upper Immediate)
- `AUIPC` (Add Upper Immediate to PC)

### J-Type (Jump)
- `JAL` (Jump and Link)

## Project Structure

```
cpudesign/
├── src/
│   ├── alu.v                 # Arithmetic Logic Unit
│   ├── alu_control.v         # ALU control signal generation
│   ├── branch_control.v      # Branch condition evaluation
│   ├── control_unit.v        # Main control unit
│   ├── data_memory.v         # Data memory (RAM)
│   ├── instruction_decoder.v # Instruction field extraction
│   ├── instruction_memory.v  # Instruction memory (ROM)
│   ├── register_file.v        # 32-register file
│   └── riscv_cpu.v           # Top-level CPU module
├── testbench/
│   └── riscv_cpu_tb.v        # Testbench
└── README.md                 # This file
```

## Component Descriptions

### ALU (Arithmetic Logic Unit)
Performs arithmetic and logical operations based on control signals. Supports 10 different operations including addition, subtraction, bitwise operations, shifts, and comparisons.

### Register File
32 general-purpose registers (x0-x31) where x0 is hardwired to zero. Supports two read ports and one write port for pipelined operation.

### Control Unit
Decodes instruction opcodes and generates control signals for:
- Register write enable
- ALU source selection (register vs immediate)
- Memory access control
- Branch/jump control
- Immediate format selection

### Instruction Decoder
Extracts instruction fields (opcode, registers, function codes) and generates immediate values for all RISC-V immediate formats (I, S, B, U, J).

### Pipeline Hazard Handling
- **Data Hazards**: Detects load-use hazards and inserts pipeline bubbles (stalls)
- **Control Hazards**: Handles branch/jump instructions with pipeline flushing
- **Forwarding**: Forwards results from EX and MEM stages to reduce stalls

## Simulation

### Prerequisites
- Verilog simulator (e.g., ModelSim, Vivado, Icarus Verilog)

### Running the Testbench

Using Icarus Verilog:
```bash
# Compile
iverilog -o riscv_cpu_tb src/*.v testbench/riscv_cpu_tb.v

# Run simulation
vvp riscv_cpu_tb

# View waveform (optional)
gtkwave riscv_cpu_tb.vcd
```

Using Vivado:
1. Create a new project
2. Add all `.v` files from `src/` and `testbench/`
3. Set `riscv_cpu_tb` as top module
4. Run simulation

## Example Program

The instruction memory is pre-loaded with a simple program:

```assembly
ADDI x1, x0, 10    # x1 = 10
ADDI x2, x0, 20    # x2 = 20
ADD  x3, x1, x2    # x3 = x1 + x2 (result: 30)
SW   x3, 0(x0)     # Store result to memory[0]
```

## Design Decisions

1. **5-Stage Pipeline**: Balanced complexity - demonstrates pipelining concepts without excessive complexity
2. **Simple Hazard Detection**: Implements basic load-use hazard detection with stalls
3. **Forwarding**: Reduces pipeline stalls by forwarding results from later stages
4. **Synchronous Memory**: Both instruction and data memories are synchronous for simplicity
5. **No Cache**: Keeps design focused on core CPU functionality
6. **No Branch Prediction**: Simple branch handling with pipeline flush on taken branches

## Performance Characteristics

- **Clock Cycles per Instruction (CPI)**: 
  - Ideal: 1.0 (one instruction per cycle)
  - With hazards: ~1.1-1.3 (depending on program)
- **Pipeline Depth**: 5 stages
- **Register File**: 32 registers, 2 read ports, 1 write port
- **Memory**: 4KB instruction memory, 4KB data memory

