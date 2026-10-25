.section .text
.globl _start

_start:
    # LED peripheral address
    li x10, 0x10000000

    # Buttons peripheral address
    li x11, 0x10000008

main_loop:
    # Read buttons
    lw x12, 0(x11)

    # Write button state to LEDs
    sw x12, 0(x10)

    # Repeat forever
    j main_loop