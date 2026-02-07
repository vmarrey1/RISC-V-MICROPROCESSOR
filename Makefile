# Makefile for RISC-V CPU Simulation

# Compiler
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Directories
SRC_DIR = src
TB_DIR = testbench
BUILD_DIR = build

# Source files
SOURCES = $(wildcard $(SRC_DIR)/*.v)
TESTBENCH = $(TB_DIR)/riscv_cpu_tb.v

# Output files
OUTPUT = $(BUILD_DIR)/riscv_cpu_tb
VCD_FILE = $(BUILD_DIR)/riscv_cpu_tb.vcd

# Default target
all: compile run

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Compile
compile: $(BUILD_DIR)
	@echo "Compiling RISC-V CPU..."
	$(IVERILOG) -o $(OUTPUT) $(SOURCES) $(TESTBENCH)
	@echo "Compilation complete!"

# Run simulation
run: compile
	@echo "Running simulation..."
	$(VVP) $(OUTPUT)
	@echo "Simulation complete!"

# Run with VCD generation
wave: compile
	@echo "Running simulation with waveform generation..."
	$(VVP) $(OUTPUT) -vcd $(VCD_FILE)
	@echo "Waveform file generated: $(VCD_FILE)"

# View waveform
view: wave
	@echo "Opening waveform viewer..."
	$(GTKWAVE) $(VCD_FILE) &

# Clean build files
clean:
	rm -rf $(BUILD_DIR)
	@echo "Clean complete!"

# Help
help:
	@echo "Available targets:"
	@echo "  make compile  - Compile the design"
	@echo "  make run      - Compile and run simulation"
	@echo "  make wave     - Run simulation and generate VCD file"
	@echo "  make view     - Run simulation and open waveform viewer"
	@echo "  make clean    - Remove build files"
	@echo "  make help     - Show this help message"

.PHONY: all compile run wave view clean help
