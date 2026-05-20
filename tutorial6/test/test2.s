.text
.global main
main:
	addi sp, sp, -32
	mv fp, sp
	li a0, 10
	addi sp, sp, -8
	sd a0, -8(fp)
	ld a0, -8(fp)
	addi sp, sp, -8
	sd a0, 0(sp)
	li a0, 2
	ld t0, 0(sp)
	addi sp, sp, 8
	mul a0, t0, a0
	addi sp, sp, -8
	sd a0, 0(sp)
	li a0, 3
	addi sp, sp, -8
	sd a0, -16(fp)
	ld a0, -8(fp)
	addi sp, sp, -8
	sd a0, 0(sp)
	ld a0, -16(fp)
	ld t0, 0(sp)
	addi sp, sp, 8
	add a0, t0, a0
	addi sp, sp, 8
	ld t0, 0(sp)
	addi sp, sp, 8
	add a0, t0, a0
	addi sp, sp, 8
	mv sp, fp
	addi sp, sp, 32
	ret
