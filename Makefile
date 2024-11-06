# Makefile for bootloader project

# Variables
ASM_SRC = src/boot.asm
BIN_OUT = builds/boot.bin
NASM = nasm
QEMU = qemu-system-x86_64

# Default rule
all: $(BIN_OUT)

# Assemble boot.asm to boot.bin
$(BIN_OUT): $(ASM_SRC)
	$(NASM) -f bin $(ASM_SRC) -o $(BIN_OUT)

# Run the bootloader in QEMU
run: $(BIN_OUT)
	$(QEMU) -drive format=raw,file=$(BIN_OUT),if=floppy

# Clean up generated files
clean:
	rm -f $(BIN_OUT)

debug: $(BIN_OUT)
	$(QEMU) -drive format=raw,file=$(BIN_OUT),if=floppy -monitor stdio -S

# Phony targets
.PHONY: all run clean