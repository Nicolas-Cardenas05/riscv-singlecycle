.option norvc
.option norelax

.section .text
.globl _start

_start:

    # ----------------------------------------------------------
    # Memory map
    #
    # 0x80 - 0xA4 : Seven-segment lookup table
    # 0xF4        : Simulated seven-segment output port
    # ----------------------------------------------------------

    addi x10, x0, 128
    addi x11, x0, 244


    # ----------------------------------------------------------
    # Seven-segment lookup table
    #
    # Bit mapping:
    #
    # bit 0 = a
    # bit 1 = b
    # bit 2 = c
    # bit 3 = d
    # bit 4 = e
    # bit 5 = f
    # bit 6 = g
    # ----------------------------------------------------------

    addi x12, x0, 0x3F
    sw   x12, 0(x10)

    addi x12, x0, 0x06
    sw   x12, 4(x10)

    addi x12, x0, 0x5B
    sw   x12, 8(x10)

    addi x12, x0, 0x4F
    sw   x12, 12(x10)

    addi x12, x0, 0x66
    sw   x12, 16(x10)

    addi x12, x0, 0x6D
    sw   x12, 20(x10)

    addi x12, x0, 0x7D
    sw   x12, 24(x10)

    addi x12, x0, 0x07
    sw   x12, 28(x10)

    addi x12, x0, 0x7F
    sw   x12, 32(x10)

    addi x12, x0, 0x6F
    sw   x12, 36(x10)


    # ----------------------------------------------------------
    # Counter initialization
    #
    # x1 = current digit
    # x2 = upper limit
    # ----------------------------------------------------------

    addi x1, x0, 0
    addi x2, x0, 10


counter_loop:

    # ----------------------------------------------------------
    # Calculate table address
    #
    # address = table_base + digit * 4
    # ----------------------------------------------------------

    slli x3, x1, 2

    add x4, x10, x3


    # ----------------------------------------------------------
    # Read seven-segment pattern
    # ----------------------------------------------------------

    lw x5, 0(x4)


    # ----------------------------------------------------------
    # Send pattern to simulated display
    # ----------------------------------------------------------

    sw x5, 0(x11)


    # ----------------------------------------------------------
    # Small software delay
    # ----------------------------------------------------------

    addi x6, x0, 20


delay_loop:

    addi x6, x6, -1

    bne x6, x0, delay_loop


    # ----------------------------------------------------------
    # Increment counter
    # ----------------------------------------------------------

    addi x1, x1, 1

    blt x1, x2, counter_loop


done:

    jal x0, done