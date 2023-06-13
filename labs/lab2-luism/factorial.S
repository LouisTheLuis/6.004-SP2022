#include "src/defines.h"
.section ".text.init"
    .globl factorial
    .globl violation
#include "src/mul.S"

/*
Python equivalent (for reference)


def mul(a,b):
    return a * b

def factorial(n):
    running_prod = n
    for i in range(1, n):
        running_prod *= i
    return running_prod

*/

//  Input:  a0 = n
//  Output: a0

factorial:
  li a1, 1       // a1 = i
  mv a2, a0      // a2 = n
  j compare
loop:
  addi sp, sp, -12
  sw ra, 0(sp)
  sw a1, 4(sp)
  sw a2, 8(sp)
  call mul       // a0 = running_prod * i
  lw ra, 0(sp)
  lw a1, 4(sp)
  lw a2, 8(sp)
  addi sp, sp, 12 
  addi a1, a1, 1  // i += 1
compare:
  blt a1, a2, loop
end:
  ret
