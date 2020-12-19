	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function

main:
    MOVE $0,$2
    MOVE $4, $31
    JAL PASS
    nop
    ADDU $2,$2,5
    MOVE $31, $4
    JR $31
    .end main
    .set noreorder
    .set nomacro

PASS:
    JR $31
    ADDU $2,$2,3
