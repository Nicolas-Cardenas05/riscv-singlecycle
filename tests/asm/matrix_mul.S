.option norvc
.option norelax

.section .text
.globl _start

_start:

    # ----------------------------------------------------------
    # Simulated output port
    # ----------------------------------------------------------

    addi x20, x0, 240


    # ----------------------------------------------------------
    # Matrix A
    #
    # | 1  2 |
    # | 3  4 |
    # ----------------------------------------------------------

    addi x2, x0, 1
    addi x3, x0, 2
    addi x4, x0, 3
    addi x5, x0, 4


    # ----------------------------------------------------------
    # Matrix B
    #
    # | 5  6 |
    # | 7  8 |
    # ----------------------------------------------------------

    addi x6, x0, 5
    addi x7, x0, 6
    addi x8, x0, 7
    addi x9, x0, 8


    # ----------------------------------------------------------
    # C00 = A00*B00 + A01*B10
    #     = 1*5 + 2*7
    #     = 19
    # ----------------------------------------------------------

    addi x10, x2, 0
    addi x11, x6, 0
    jal  x1, multiply

    addi x14, x12, 0

    addi x10, x3, 0
    addi x11, x8, 0
    jal  x1, multiply

    add x14, x14, x12

    sw x14, 0(x20)


    # ----------------------------------------------------------
    # C01 = A00*B01 + A01*B11
    #     = 1*6 + 2*8
    #     = 22
    # ----------------------------------------------------------

    addi x10, x2, 0
    addi x11, x7, 0
    jal  x1, multiply

    addi x14, x12, 0

    addi x10, x3, 0
    addi x11, x9, 0
    jal  x1, multiply

    add x14, x14, x12

    sw x14, 0(x20)


    # ----------------------------------------------------------
    # C10 = A10*B00 + A11*B10
    #     = 3*5 + 4*7
    #     = 43
    # ----------------------------------------------------------

    addi x10, x4, 0
    addi x11, x6, 0
    jal  x1, multiply

    addi x14, x12, 0

    addi x10, x5, 0
    addi x11, x8, 0
    jal  x1, multiply

    add x14, x14, x12

    sw x14, 0(x20)


    # ----------------------------------------------------------
    # C11 = A10*B01 + A11*B11
    #     = 3*6 + 4*8
    #     = 50
    # ----------------------------------------------------------

    addi x10, x4, 0
    addi x11, x7, 0
    jal  x1, multiply

    addi x14, x12, 0

    addi x10, x5, 0
    addi x11, x9, 0
    jal  x1, multiply

    add x14, x14, x12

    sw x14, 0(x20)


    # Skip multiplication function after main program
    jal x0, done


# ==============================================================
# MULTIPLICATION FUNCTION
#
# Input:
#   x10 = multiplicand
#   x11 = multiplier
#
# Output:
#   x12 = result
#
# Return address:
#   x1
# ==============================================================

multiply:

    # Clear result
    addi x12, x0, 0

    # Copy multiplier
    addi x13, x11, 0


multiply_loop:

    # Finish when multiplier reaches zero
    beq x13, x0, multiply_done

    # Accumulate multiplicand
    add x12, x12, x10

    # Decrement multiplier
    addi x13, x13, -1

    jal x0, multiply_loop


multiply_done:

    # Return to caller
    jalr x0, 0(x1)


# ==============================================================
# TERMINAL LOOP
# ==============================================================

done:

    jal x0, done