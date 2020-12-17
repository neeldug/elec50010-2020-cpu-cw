	.file	1 "addu_1.c"
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
	lui	$2,%hi(a)
	lw	$3,%lo(a)($2)
	lui	$2,%hi(b)
	lw	$2,%lo(b)($2)
	jr	$31
	addu	$2,$3,$2

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.globl	b
	.data
	.align	2
	.type	b, @object
	.size	b, 4
b:
	.word	7
	.globl	a
	.align	2
	.type	a, @object
	.size	a, 4
a:
	.word	8
	.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
