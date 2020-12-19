	.file	1 "jal_2.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=32
	.module	nooddspreg
	.abicalls
	.text
	.section	.text.foo,"ax",@progbits
	.align	2
	.globl	foo
	.set	nomips16
	.set	nomicromips
	.ent	foo
	.type	foo, @function
foo:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	jr	$31
	move	$2,$0

	.set	macro
	.set	reorder
	.end	foo
	.size	foo, .-foo
	.section	.text.main,"ax",@progbits
	.align	2
	.globl	main
	.set	nomips16
	.set	nomicromips
	.ent	main
	.type	main, @function
main:
	.frame	$sp,32,$31		# vars= 0, regs= 1/0, args= 16, gp= 8
	.mask	0x80000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	move $4,$31
	li $2, 4
	.option	pic0
	jal	foo
	nop

	.option	pic2
	move $31,$4
	sltu	$2,$0,$2
	jr	$31

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"

# This c code works similarly but slightly changed to remove stackpointer usage
# int foo();
# __attribute__((section(".text.main"))) int main(void) {
#     int x = foo();
#     if (x == 0) {
#         return 0;
#     } else {
#         return 1;
#    }
# }
# int __attribute__ ((noinline)) foo() {
#    return 0;
# }
