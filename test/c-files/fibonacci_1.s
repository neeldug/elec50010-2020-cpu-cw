	.file	1 "fibonacci_1.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=32
	.module	nooddspreg
	.abicalls
	.text
	.section	.text.startup.main,"ax",@progbits
	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function
main:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	lui	$2,%hi(t)
	lw	$7,%lo(t)($2)
	nop
	beq	$7,$0,$L4
	nop

	li	$2,1			# 0x1
	beq	$7,$2,$L5
	li	$3,2			# 0x2

	move	$4,$0
$L3:
	addiu	$3,$3,1
	move	$6,$2
	sltu	$5,$7,$3
	addu	$2,$2,$4
	beq	$5,$0,$L3
	move	$4,$6

	jr	$31
	nop

$L4:
	jr	$31
	move	$2,$0

$L5:
	jr	$31
	li	$2,1			# 0x1

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.globl	t
	.data
	.align	2
	.type	t, @object
	.size	t, 4
t:
	.word	8
	.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
