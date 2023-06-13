# This looks for riscv32-unknown-elf-gcc or riscv64-unknown-elf-gcc and sets
# RISCV_TARGET accordingly. The check_for_riscv_target variable is used to
# abort compilation if no RISC-V compiler was found.
RVNE_EXISTS:=$(shell command -v riscv-none-embed-gcc 2> /dev/null)
check_for_riscv_target=$(error No RISC-V compiler found. \
		       Expecting riscv-none-embed-gcc. \
		       Please restart terminal to update tools.)

ifdef RVNE_EXISTS
RISCV_TARGET=$(shell dirname $(RVNE_EXISTS))/riscv-none-embed-
check_for_riscv_target=
endif

CFLAGS=-mcmodel=medany -nostdlib -nostartfiles -march=rv32i -mabi=ilp32 -mstrict-align
LDFLAGS=-march=rv32i -nostdlib -nostartfiles -Wl,-Tsrc/riscv-link.ld

# Specify source files
files = collatz maximum triangular bubblesort
assemblyFiles = crt0
cFiles = main
# Targets
assemblyObjects = $(addprefix build/, $(addsuffix .o, $(assemblyFiles)))
fileObjects = $(addprefix build/, $(addsuffix .o, $(files)))
cObjects = $(addprefix build/, $(addsuffix .o, $(cFiles)))
vmhs = $(addsuffix .vmh, $(files))
dumps = $(addsuffix .dump, $(files))

all: $(vmhs) $(dumps)

$(assemblyObjects): build%.o: src%.S
	$(call check_for_riscv_target)
	@mkdir -p build
	$(RISCV_TARGET)gcc $(CFLAGS) -c $< -o $@

$(fileObjects): build/%.o: %.S
	$(call check_for_riscv_target)
	@mkdir -p build
	$(RISCV_TARGET)gcc $(CFLAGS) -c $< -o $@

$(cObjects): build%.o: src%.c
	$(call check_for_riscv_target)
	@mkdir -p build
	$(RISCV_TARGET)gcc $(CFLAGS) -c $< -o $@

%.riscv: build/main.o build/crt0.o %.o
	$(call check_for_riscv_target)
	$(RISCV_TARGET)gcc $(LDFLAGS) $^ -o $@

%.vmh: build/%.riscv tools/elf2hex/elf2hex
	./tools/elf2hex/elf2hex $< 0 16K 4 $@

%.dump: build/%.riscv
	$(call check_for_riscv_target)
	$(RISCV_TARGET)objdump -M no-aliases -s -d $^ > $@

# Technically this should be a phony target, but we're assuming this tool
# will not change often.
tools/elf2hex/elf2hex:
	make -C tools/elf2hex

clean:
	rm -rf build __pycache__ tools/__pycache__
	rm -f *.dump *.vmh *.x86

test: all
	./test_all.sh

.PHONY: all clean test
.DEFAULT_GOAL := all
