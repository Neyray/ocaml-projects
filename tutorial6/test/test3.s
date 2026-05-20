.text
.global main
main:
	addi sp, sp, -32
	mv fp, sp
	li a0, 1
	beq a0, x0, Lelse_1
	li a0, 42
	j Lend_2
Lelse_1:
	li a0, 13
Lend_2:
	mv sp, fp
	addi sp, sp, 32
	ret
