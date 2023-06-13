#! /bin/bash

# Check to see if the RISC-V tools exist and are in the path

GCC_EXISTS=$(command -v riscv-none-embed-gcc 2> /dev/null)

if [ -n "$GCC_EXISTS" ]; then
  RISCV=$(dirname $GCC_EXISTS)/riscv-none-embed-
else
  echo "Error: no RISC-V compiler found"
  exit
fi

# Assemble "collatz.S" into binary (technically, into an object file)
#
#   -march=rv32i  We're using RV32 without any extensions
#   -o collatz.o  Call the output "collatz.o"
#
${RISCV}as -march=rv32i -o collatz.o collatz.S

# Generate a human-readable form of the object file
#
#   -S  Display instruction address, hexadecimal, and source -- line by line
#   -s  Display copy of all hexadecimal at top
#   -w  Don't wrap lines at 80 characters
#
${RISCV}objdump -Ssw collatz.o > collatz.dump

# Remove the object file
#
rm collatz.o
