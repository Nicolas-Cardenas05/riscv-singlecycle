.section .text
.globl _start

_start:

    # VRAM base address
    li x10, 0x20000000


    # --------------------------------------------------------
    # Red band
    # 60 rows x 320 pixels = 19200 bytes = 4800 words
    # RRRGGGBB red = 0xE0
    # --------------------------------------------------------

    li x11, 0xE0E0E0E0
    li x12, 4800

red_loop:

    sw x11, 0(x10)
    addi x10, x10, 4
    addi x12, x12, -1
    bne x12, x0, red_loop


    # --------------------------------------------------------
    # Green band
    # --------------------------------------------------------

    li x11, 0x1C1C1C1C
    li x12, 4800

green_loop:

    sw x11, 0(x10)
    addi x10, x10, 4
    addi x12, x12, -1
    bne x12, x0, green_loop


    # --------------------------------------------------------
    # Blue band
    # --------------------------------------------------------

    li x11, 0x03030303
    li x12, 4800

blue_loop:

    sw x11, 0(x10)
    addi x10, x10, 4
    addi x12, x12, -1
    bne x12, x0, blue_loop


    # --------------------------------------------------------
    # White band
    # --------------------------------------------------------

    li x11, 0xFFFFFFFF
    li x12, 4800

white_loop:

    sw x11, 0(x10)
    addi x10, x10, 4
    addi x12, x12, -1
    bne x12, x0, white_loop


    # --------------------------------------------------------
    # Indicate framebuffer initialization complete
    # --------------------------------------------------------

    li x10, 0x10000000
    li x11, 0x0000FFFF
    sw x11, 0(x10)


    li x10, 0x10001000
    li x11, 0x0000C0DE
    sw x11, 0(x10)


done:

    j done