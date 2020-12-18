	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function

main:
    MOVE $2,$0
    J PASS
    nop
    JR $31
    .end main
    .set	noreorder
    .set	nomacro

PASS:
    JR $31
    ADDIU $2,$2,3
