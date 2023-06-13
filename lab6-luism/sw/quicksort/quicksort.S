.section ".text.init"
    .globl sort

/* Python code for reference
# p is an integer array
# n is the number of elements in p: n == len(p)
def sort(p, n):
    quicksort(p, 0, n - 1)

def quicksort(p, start, end):      # Sort elements from p[start] to p[end]
    if (start < end):
        q = partition(p, start, end)
        quicksort(p, start, q - 1)
        quicksort(p, q + 1, end)

def partition(p, start, end):      # Divide p[start:end] into two subarrays, one with all
    pivot = p[end]                 # elements smaller or equal to a pivot value (the last
    i = start                      # value of input array), and another with all elements
    for j in range(start, end):    # larger than the pivot. Returns the index of the pivot.
        if (p[j] <= pivot):
            (p[i], p[j]) = (p[j], p[i]) # swap
            i += 1
    (p[i], p[end]) = (p[end], p[i]) # swap
    return i
*/

//  QUICKSORT (should call "partition")
//
//  Inputs:
//  a0 = p (address of array)
//  a1 = start
//  a2 = end
//  a3 = q
//  t0 = q - 1
//  t1 = q + 1

sort:
  bge a1, a2, end          // if start >= end, terminate the program

  addi sp, sp, -20         // open 5 spaces in the stack
  sw ra, 0(sp)          
  sw a0, 4(sp)
  sw a1, 8(sp)
  sw a2, 12(sp)
  call partition           // call partition
  mv a3, a0                // a3 = i + 1 from partition
  lw a0, 4(sp)
  lw a1, 8(sp)
  lw a2, 12(sp)
  
  addi t0, a3, -1
  sw a0, 4(sp)
  sw a1, 8(sp)
  sw a2, 12(sp)
  sw a3, 16(sp)
  mv a2, t0
  call sort
  lw a0, 4(sp)
  lw a1, 8(sp)
  lw a2, 12(sp)
  lw a3, 16(sp)

  addi t1, a3, 1
  sw a0, 4(sp)
  sw a1, 8(sp)
  sw a2, 12(sp)
  mv a1, t1
  call sort
  lw a0, 4(sp)
  lw a1, 8(sp)
  lw a2, 12(sp)

  lw ra, 0(sp)
  addi sp, sp, 20
end:
  ret


// PARTITION
//
// Inputs:           
// a0 = starting address of the array (&p)
// a1 = index of the starting element (start)
// a2 = index of the ending element (end)
// a3 = x
// t1 = j
// t2 = tmp
// t3 = i
// t4 = p[j]
// t5 = p[i]
// a4 = i + 1
// t6 = p[i + 1]

partition:
  slli t0, a2, 2                               // t0 = (&end*4)
  add t0, t0, a0
  lw a3, 0(t0)                                 // a3 = p[end] = x
  slli  t1, a1, 2                              // t1 = &start*4 = j
  add t1, t1, a0
  addi t3, t1, -4                              // t3 = (&start*4)-1 = i
loop:
  bge t1, t0, after                            // if (j*4) >= (&end*4), terminate
  lw t4, 0(t1)                                 // t4 = p[j]
  addi t1, t1, 4                               // j++
  blt a3, t4, loop                             // switch if x >= p[j]
switch:
  addi t3, t3, 4                               // i++
  lw t5, 0(t3)                                 // t5 = p[i]
  mv t2, t4                                    // tmp = p[j]
  mv t4, t5                                    // p[i] = p[j]
  mv t5, t2                                    // p[j] = tmp
  addi t1, t1, -4
  sw t5, 0(t3)                                 // store p[i] in *p[j]
  sw t4, 0(t1)                                 // store p[j] in *p[i]
  addi t1, t1, 4
  j loop
after:
  addi a4, t3, 4                               // a4 = i + 1
  lw t6, 0(a4)                                 // t6 = p[i + 1]
  sw t6, 0(t0)                                 // p[j] = p[i + 1]
  sw a3, 0(a4)                                 // p[i + 1] = p[j]
  sub a4, a4, a0
  srli a0, a4, 2                               // a0 = (4 * (i + 1))/4 = i + 1
  ret
