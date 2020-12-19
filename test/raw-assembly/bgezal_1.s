	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function

main:
	MOVE $2, $0
	LI $3, 0x00000025
	MOVE $4, $31
	BGEZAL $3, main + 32
	nop
	MOVE $31, $4
	JR $31
	nop
	ADDU $2,$2,3
	MOVE $31, $4
	JR $31
	.end main
    	.set	noreorder
    	.set	nomacro

