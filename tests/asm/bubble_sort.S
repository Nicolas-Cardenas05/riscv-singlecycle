.option norvc
.option norelax

.section .text
.globl _start

_start:

    # Array base address
    addi x10, x0, 128

    # Simulated output port
    addi x11, x0, 240


    # ----------------------------------------------------------
    # Initialize array
    #
    # [23, 5, 17, 1, 12, 9, 30, 4]
    # ----------------------------------------------------------

    addi x12, x0, 23
    sw   x12, 0(x10)

    addi x12, x0, 5
    sw   x12, 4(x10)

    addi x12, x0, 17
    sw   x12, 8(x10)

    addi x12, x0, 1
    sw   x12, 12(x10)

    addi x12, x0, 12
    sw   x12, 16(x10)

    addi x12, x0, 9
    sw   x12, 20(x10)

    addi x12, x0, 30
    sw   x12, 24(x10)

    addi x12, x0, 4
    sw   x12, 28(x10)


    # ----------------------------------------------------------
    # Bubble sort
    #
    # x4 = number of comparisons in current pass
    # ----------------------------------------------------------

    addi x4, x0, 7


outer_loop:

    # Reset pointer to first array element
    addi x5, x10, 0

    # Inner loop comparison counter
    addi x6, x4, 0


inner_loop:

    # Load adjacent elements
    lw x7, 0(x5)
    lw x8, 4(x5)

    # x9 = 1 if next element < current element
    slt x9, x8, x7

    # Skip swap if elements are already ordered
    beq x9, x0, no_swap

    # Swap adjacent elements
    sw x8, 0(x5)
    sw x7, 4(x5)


no_swap:

    # Move to next pair
    addi x5, x5, 4

    # Decrement inner counter
    addi x6, x6, -1

    bne x6, x0, inner_loop


    # Decrement outer counter
    addi x4, x4, -1

    bne x4, x0, outer_loop


    # ----------------------------------------------------------
    # Output sorted array
    # ----------------------------------------------------------

    addi x5, x10, 0
    addi x6, x0, 8


output_loop:

    lw x7, 0(x5)

    # Write value to simulated output port
    sw x7, 0(x11)

    addi x5, x5, 4
    addi x6, x6, -1

    bne x6, x0, output_loop


done:

    jal x0, done