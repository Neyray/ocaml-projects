.text
.global main
main:
	addi sp, sp, -32
	mv fp, sp
	li a0, 3
	addi sp, sp, -8
	sd a0, 0(sp)
	li a0, 5
	addi sp, sp, -8
	sd a0, 0(sp)
	li a0, 9
	ld t0, 0(sp)
	addi sp, sp, 8
	mul a0, t0, a0
	ld t0, 0(sp)
	addi sp, sp, 8
	add a0, t0, a0
	mv sp, fp
	addi sp, sp, 32
	ret
