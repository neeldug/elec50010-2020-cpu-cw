	.text
	.section	.text.foo,"ax",@progbits
	.align	2
	.globl	foo
	.set	nomips16
	.set	nomicromips
	.ent	foo
	.type	foo, @function
foo:
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
	.set	noreorder
	.set	nomacro
	move $4,$31
	li $2, 4
	li $5, 0xbfc00030
	.option	pic0
	jalr $5
	nop

	.option	pic2
	move $31,$4
	sltu	$2,$0,$2
	jr	$31

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main

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
