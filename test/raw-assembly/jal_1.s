	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function

main:
	MOVE $2, $0
	MOVE $4, $31
	JAL label
	ADDU $2,$2,2
	MOVE $31, $4
	JR $31
	.end main
    	.set	noreorder
    	.set	nomacro

label:	
	JR $31
	ADDU $2,$2,3

