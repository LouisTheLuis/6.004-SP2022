#include "src/defines.h"
.section ".text.init"
    .globl triangular

/*
Python equivalents (for reference)

def triangular(n):
    running_sum = 0
    for i in range(n+1):
        running_sum += i
    return running_sum

*/

triangular:
  li a1, 0              // a1 is running_sum, which is initialized to 0
  li a2, 0              // a2 is the i counter, which is initialized to 0
  addi a3, a0, 1        // a3 is equal to n+1
loop:
  add a1, a1, a2        // we add i (a2) to running_sum (a1)
  addi a2, a2, 1        // i += 1
  bne a2, a3, loop      // if i != n+1, continue the loop
end:
  addi a0, a1, 0        // set a0 equal to running_sum
  ret
