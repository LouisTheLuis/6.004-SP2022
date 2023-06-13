    .globl space



mul:
	li a2, 0x11111111
	li a3, 0x22222222
	li a7, 0x33333333
	li t0, 0x44444444
	li t1, 0x55555555
	li t2, 0x66666666
	li t3, 0x77777777
	li t4, 0x88888888
	li t5, 0x99999999
	li t6, 0xaaaaaaaa
	la a5, space
	li a6, 0xabababab
	sw a6, 0(a5)
	mv	a3,a0
	li	a4,32
	li	a0,0
__loop:
	andi	a5,a3,1
	addi	a4,a4,-1
	beqz	a5,__skip
	add	a0,a0,a1
__skip:
	srli	a3,a3,0x1
	slli	a1,a1,0x1
	bnez	a4,__loop
	ret
 