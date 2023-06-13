#include "src/defines.h"
.section ".text.init"
    .globl sort

/*
C equivalent (for reference)

void sort(int *p, n) {
    int swapped = 1;
    while (swapped != 0) {
        swapped = 0;
        for (int i = 0; i < n - 1; i++) {
            if (p[i] > p[i + 1]) {
                int tmp = p[i];
                p[i] = p[i + 1];
                p[i + 1] = tmp;
                swapped = 1;
            }
        }
        n = n - 1;
    }
}

Python equivalent (for reference)

# p is an array of integers
# n is the number of elements in p
#  (in other words, n == len(p))

def sort(p, n):
    swapped = True
    while swapped:                            # stop if we didn't have to make any swaps (meaning everything is in order)
        swapped = False
        for i in range(n-1):
            if p[i] > p[i+1]:                 # if a larger element comes before a smaller element,
                p[i], p[i+1] = p[i+1], p[i]   #   swap them
                swapped = True
        n -= 1                        # optimization: after the first pass, the biggest element will be in the last place;
                                      #    after the second pass, the two biggest elements will be in the last two places;
                                      #    and so on -- so on the n-th pass we only need to consider the first n elements
*/

// a0 -> address of the first index of the array
// a1 -> n*4
// a2 -> swapped
// a3 -> i (incrementing by 4)
// a4 -> (n-1)*4
// a5 -> &p[i]
// a6 -> p[i]
// a7 -> p[i+1]

sort:
  li a2, 1                    // swapped = 1 (True)
  slli a1, a1, 2              // a1 = n*4
while:
  beqz a2, end                // if swapped == 0 (False), end the program
  li a2, 0                    // swapped = 0 (False)
  li a3, 0                    // i = 0
  addi a4, a1, -4             // a4 = n-4
loop:
  bge a3, a4, after           // if i*4 >= (n-1)*4, go to after
  add a5, a0, a3              // a5 = address of first element + i = &p[i]
  lw a6, 0(a5)                // a6 = p[i]
  lw a7, 4(a5)                // a7 = p[i+1]
  addi a3, a3, 4              // i = i+4
  bge a7, a6, loop            // if p[i+1] >= p[i], go to loop; else, make the switch

  sw a6, 4(a5)                // a6 <- a5
  sw a7, 0(a5)                // a5 <- a6

  li a2, 1                    // swapped = 1 (True)
  j loop                      // go back to loop
after:
  addi a1, a1, -4             // n -= 1
  j while                     // go to while
end:
  ret
