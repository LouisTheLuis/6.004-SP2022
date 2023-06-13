.section ".text.init"
    .globl sort

sort:
  addi sp, sp, -4
  sw ra, 0(sp)

  li t3, 0x40005000
  call quicksort
  lw t5, 0(t4)

  lw ra, 0(sp)

  li t2, 0x40000004
  lw t6, 0(t3)
  sw t6, 0(t2)
  sw t5, 0(t2)

  addi sp, sp, 4
  ret


quicksort:
  bge a1, a2, end          // if start >= end, terminate the program

  addi sp, sp, -20         // open 5 spaces in the stack
  sw ra, 0(sp)
  sw a0, 4(sp)
  sw a1, 8(sp)
  sw a2, 12(sp)

  li t4, 0x40006000
  li t5, 1
  sw t5, 4(t4)
  call partition           // call partition
  sw zero, 4(t4)

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
  call quicksort
  lw a0, 4(sp)
  lw a1, 8(sp)
  lw a2, 12(sp)
  lw a3, 16(sp)

  addi t1, a3, 1
  sw a0, 4(sp)
  sw a1, 8(sp)
  sw a2, 12(sp)
  mv a1, t1
  call quicksort
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
// s1 = j
// s2 = tmp
// s3 = i
// s4 = p[j]
// s5 = p[i]
// a4 = i + 1
// s6 = p[i + 1]

partition:
  addi sp, sp, -28
  sw s0, 0(sp)
  sw s1, 4(sp)
  sw s2, 8(sp)
  sw s3, 12(sp)
  sw s4, 16(sp)
  sw s5, 20(sp)
  sw s6, 24(sp)


  slli s0, a2, 2                               // t0 = (&end*4)
  add s0, s0, a0
  lw a3, 0(s0)                                 // a3 = p[end] = x
  slli  s1, a1, 2                              // t1 = &start*4 = j
  add s1, s1, a0
  addi s3, s1, -4                              // t3 = (&start*4)-1 = i
loop:
  bge s1, s0, after                            // if (j*4) >= (&end*4), terminate
  lw s4, 0(s1)                                 // t4 = p[j]
  addi s1, s1, 4                               // j++
  blt a3, s4, loop                             // switch if x >= p[j]
switch:
  addi s3, s3, 4                               // i++
  lw s5, 0(s3)                                 // t5 = p[i]
  mv s2, s4                                    // tmp = p[j]
  mv s4, s5                                    // p[i] = p[j]
  mv s5, s2                                    // p[j] = tmp
  addi s1, s1, -4
  sw s5, 0(s3)                                 // store p[i] in *p[j]
  sw s4, 0(s1)                                 // store p[j] in *p[i]
  addi s1, s1, 4
  j loop
after:
  addi a4, s3, 4                               // a4 = i + 1
  lw s6, 0(a4)                                 // t6 = p[i + 1]
  sw s6, 0(s0)                                 // p[j] = p[i + 1]
  sw a3, 0(a4)                                 // p[i + 1] = p[j]
  sub a4, a4, a0
  srli a0, a4, 2                               // a0 = (4 * (i + 1))/4 = i + 1

  lw s0, 0(sp)
  lw s1, 4(sp)
  lw s2, 8(sp)
  lw s3, 12(sp)
  lw s4, 16(sp)
  lw s5, 20(sp)
  lw s6, 24(sp)
  addi sp, sp, 28
  ret

