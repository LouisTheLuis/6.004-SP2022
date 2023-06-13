.section ".text.init"
    .globl _start
    .globl exit
    .globl main
    .globl print_char
    .globl load_arg
    .globl violation
    .globl setup_shadow
    .globl print_error

_start:
    // initialize global pointer
    // la gp, _gp
    li gp, 0

    // initialize stack pointer
    // hard-code sp to the top of memory (assuming 64 KB)
    li sp, 0x10000

    call main
    j exit

print_char:
    andi t0, a0, 0xff
    li t1, 0x40000000
    sw t0, 0(t1)
    ret

load_arg:
    li t0, 0x40003000
    lw a0, 0(t0)
    ret

exit:
    li t0, 0x40001000
    sw a0, 0(t0)

exit_loop:
    beq x0, x0, exit_loop

violation:
    addi gp, ra, -4
    call print_error
    li tp, 0x40000000
    sw gp, 8(tp)
    li gp, 0x0A
    sw gp, 0(tp)
    j exit

setup_shadow:
    li gp, 0x40000
    sw sp, 0(gp)
    sw s0, -4(gp)
    sw s1, -8(gp)
    sw s2, -12(gp)
    sw s3, -16(gp)
    sw s4, -20(gp)
    sw s5, -24(gp)
    sw s6, -28(gp)
    sw s7, -32(gp)
    sw s8, -36(gp)
    sw s9, -40(gp)
    sw s10, -44(gp)
    sw s11, -48(gp)
    addi gp, gp, -52
    ret
