.text
.global main
main:
	addi sp, sp, -64
	mv fp, sp
	li a0, 10
	addi sp, sp, -8
	sd a0, -8(fp)
	li a0, 16
	jal ra, malloc
	mv t0, a0
	la t1, func_1
	sd t1, 0(t0)
	ld t1, -8(fp)
	sd t1, 8(t0)
	mv a0, t0
	addi sp, sp, -8
	sd a0, -16(fp)
	ld a0, -16(fp)
	addi sp, sp, 8
	addi sp, sp, 8
	mv t0, a0
	li a0, 3
	addi a1, t0, 8
	ld t1, 0(t0)
	jalr ra, 0(t1)
	mv sp, fp
	addi sp, sp, 64
	ret

func_1:
	addi sp, sp, -16
	sd ra, 8(sp)
	sd fp, 0(sp)
	mv fp, sp
	ld a0, -8(fp)
	addi sp, sp, -8
	sd a0, 0(sp)
	ld a0, 0(a1)
	ld t0, 0, 0(sp)
	addi sp, sp, 8
	add a0, t0, a0
	ld ra, 8(sp)
	ld fp, 0(sp)
	addi sp, sp, 16
	ret
