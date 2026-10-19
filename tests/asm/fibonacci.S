.option norvc
.option norelax

.section .text
.globl _start

_start:

    # Output port address
    addi x10, x0, 240

    # Fibonacci initial values
    addi x1, x0, 0
    addi x2, x0, 1

    # Number of values to generate
    addi x3, x0, 12


fib_loop:

    # Send current Fibonacci value to output port
    sw x1, 0(x10)

    # Calculate next Fibonacci value
    add x4, x1, x2

    # Shift values
    addi x1, x2, 0
    addi x2, x4, 0

    # Decrement counter
    addi x3, x3, -1

    # Continue while counter is not zero
    bne x3, x0, fib_loop


done:

    # Infinite terminal loop
    jal x0, done