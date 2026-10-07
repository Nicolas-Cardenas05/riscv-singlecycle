.option norvc
.option norelax

.section .text
.globl _start

_start:
    addi x1,  x0, 5
    addi x2,  x0, 10

    add  x3,  x1, x2
    sub  x4,  x2, x1
    and  x5,  x1, x2
    or   x6,  x1, x2
    slt  x7,  x1, x2

    andi x8,  x3, 7
    ori  x9,  x5, 3
    slti x10, x2, 20

    beq  x3, x3, branch_taken
    addi x12, x0, 99

branch_taken:
    addi x12, x0, 42

    beq  x1, x2, skip_x13
    addi x13, x0, 7

skip_x13:
    jal  x14, jump_target
    addi x15, x0, 99

jump_target:
    addi x15, x0, 11

    sw   x3, 128(x14)
    lw   x11, 128(x14)

loop:
    jal x0, loop