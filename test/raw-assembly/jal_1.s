	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function

main:
	MOVE $2, $0
	MOVE $4, $31
	JAL pass
	nop
	ADDU $2,$2,5
	JR $31
	.end main
    .set	noreorder
    .set	nomacro

pass:
	ADDU $2,$2,3
	MOVE $31, $4
	JR $31