	.file	1 "multu_1.c"
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
	lui	$2,%hi(x)
	lw	$3,%lo(x)($2)
	lui	$2,%hi(y)
	lw	$2,%lo(y)($2)
	nop
	multu	$3,$2
	mflo	$2
	andi    $2, $2, 0xFFFF
	srl    $2, $2, 12
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.globl	y
	.data
	.align	2
	.type	y, @object
	.size	y, 4
y:
	.word	-8
	.globl	x
	.align	2
	.type	x, @object
	.size	x, 4
x:
	.word	2
	.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
