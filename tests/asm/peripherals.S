.section .text
.globl _start

_start:

    li x10, 0x10000004     # Switches
    li x11, 0x10000000     # LEDs
    li x12, 0x10001000     # Seven-segment display

loop:

    lw x13, 0(x10)         # Read switches

    sw x13, 0(x11)         # Write value to LEDs
    sw x13, 0(x12)         # Write value to seven-segment display

    j loop