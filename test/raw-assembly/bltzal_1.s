	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function

main:
	MOVE $2, $0
	LI $3, 0xFFFFFFFF
	MOVE $4, $31
	BLTZAL $3, label
	MOVE $31, $4
	ADDU $2,$2,3
	JR $31
	.end main
    .set	noreorder
    .set	nomacro


label:
	ADDU $2,$2,4
	JR $31