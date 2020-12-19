	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function

main:
	MOVE $2, $0
	LI $3, 0x00000029
	MTLO $3
	MFLO $2
	JR $31
	.end main
    	.set	noreorder
    	.set	nomacro
