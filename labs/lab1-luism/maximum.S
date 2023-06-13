#include "src/defines.h"
.section ".text.init"
    .globl maximum

/*
Python equivalent (for reference)

def maximum(p, n):
    largest_so_far = 0
    while n != 0:
        w = load_word(p)
        if w > largest_so_far:
            largest_so_far = w
        p = p + 4
        n = n - 1
    return largest_so_far

*/

maximum:
  li    a2, 0             // load immediate 0 into a2 (largest_so_far)
loop:
  lw    a3, 0(a0)         // load word at [[address stored in a0] + 0] into a3 (w)
  ble   a3, a2, continue  // skip next instruction if a3 (w) <= a2 (largest_so_far)
  addi  a2, a3, 0 
continue:
  addi a0, a0, 4          // address at a0 + 4
  addi a1, a1, -1         // n = n-1
  bnez  a1, loop          // go to top of loop if a1 (n) != 0
done:
  addi a0, a2, 0          // a0 = largest_so_far
  ret
