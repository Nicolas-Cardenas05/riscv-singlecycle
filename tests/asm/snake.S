.option norvc

.section .text
.globl _start

# ============================================================
# Snake for the custom RV32I + WISHBONE SoC
#
# Memory map
#   0x10000000 : LEDs
#   0x10000008 : Buttons
#   0x10001000 : Seven-segment display
#   0x20000000 : VGA framebuffer, 320x240, 8 bpp RRRGGGBB
#
# Button bits
#   bit 0 : UP
#   bit 1 : DOWN
#   bit 2 : LEFT
#   bit 3 : RIGHT
#   bit 4 : CENTER / restart
#
# Game board
#   40 x 30 cells
#   8 x 8 framebuffer pixels per cell
#
# Data RAM usage
#   0x0020 : snake length
#   0x0024 : direction
#   0x0028 : food position
#   0x002C : score
#   0x0030 : pseudo-random seed
#   0x0100 : snake body array
#
# Snake positions:
#   bits [7:0]  = X
#   bits [15:8] = Y
#
# Direction values
#   0 = UP
#   1 = DOWN
#   2 = LEFT
#   3 = RIGHT
# ============================================================

.equ LEDS_ADDR,       0x10000000
.equ BUTTONS_ADDR,    0x10000008
.equ SEVSEG_ADDR,     0x10001000
.equ VRAM_ADDR,       0x20000000

.equ LENGTH_ADDR,     0x00000020
.equ DIR_ADDR,        0x00000024
.equ FOOD_ADDR,       0x00000028
.equ SCORE_ADDR,      0x0000002C
.equ RNG_ADDR,        0x00000030
.equ SNAKE_BASE,      0x00000100

.equ DIR_UP,          0
.equ DIR_DOWN,        1
.equ DIR_LEFT,        2
.equ DIR_RIGHT,       3

.equ COLOR_BLACK,     0x00
.equ COLOR_RED,       0xE0
.equ COLOR_GREEN,     0x1C
.equ COLOR_YELLOW,    0xFC
.equ COLOR_WHITE,     0xFF

# Adjust later to change Snake speed
.equ MOVE_DELAY,      5000000


# ============================================================
# ENTRY
# ============================================================

_start:
    j game_init


# ============================================================
# GAME INITIALIZATION
# ============================================================

game_init:

    # Clear framebuffer
    jal ra, clear_screen

    # Draw border
    jal ra, draw_border

    # Snake length = 4
    li t0, LENGTH_ADDR
    li t1, 4
    sw t1, 0(t0)

    # Initial direction = RIGHT
    li t0, DIR_ADDR
    li t1, DIR_RIGHT
    sw t1, 0(t0)

    # Score = 0
    li t0, SCORE_ADDR
    sw zero, 0(t0)

    # RNG seed
    li t0, RNG_ADDR
    li t1, 0x12345678
    sw t1, 0(t0)

    # --------------------------------------------------------
    # Initial snake
    #
    # Head: (20,15)
    # Body: (19,15), (18,15), (17,15)
    # --------------------------------------------------------

    li t0, SNAKE_BASE

    li t1, 0x0F14
    sw t1, 0(t0)

    li t1, 0x0F13
    sw t1, 4(t0)

    li t1, 0x0F12
    sw t1, 8(t0)

    li t1, 0x0F11
    sw t1, 12(t0)

    # Draw head
    li a0, 20
    li a1, 15
    li a2, COLOR_YELLOW
    jal ra, draw_cell

    # Draw body
    li a0, 19
    li a1, 15
    li a2, COLOR_GREEN
    jal ra, draw_cell

    li a0, 18
    li a1, 15
    li a2, COLOR_GREEN
    jal ra, draw_cell

    li a0, 17
    li a1, 15
    li a2, COLOR_GREEN
    jal ra, draw_cell

    # Score = 0 on seven-segment
    li t0, SEVSEG_ADDR
    sw zero, 0(t0)

    # LED0 means game running
    li t0, LEDS_ADDR
    li t1, 1
    sw t1, 0(t0)

    # Generate first food
    jal ra, spawn_food

    # a0 = packed XY
    srli a1, a0, 8
    andi a1, a1, 0xFF

    andi a0, a0, 0xFF

    li a2, COLOR_RED
    jal ra, draw_cell

    j game_loop


# ============================================================
# MAIN LOOP
# ============================================================

game_loop:

    # --------------------------------------------------------
    # Read buttons
    # --------------------------------------------------------

    li t0, BUTTONS_ADDR
    lw t1, 0(t0)

    # CENTER restarts game
    andi t2, t1, 0x10
    bnez t2, game_init

    # Load current direction
    li t0, DIR_ADDR
    lw t2, 0(t0)


    # --------------------------------------------------------
    # UP
    # --------------------------------------------------------

    andi t3, t1, 0x01
    beqz t3, check_down

    # Cannot reverse DOWN -> UP
    li t4, DIR_DOWN
    beq t2, t4, direction_done

    li t2, DIR_UP
    sw t2, 0(t0)

    j direction_done


check_down:

    # --------------------------------------------------------
    # DOWN
    # --------------------------------------------------------

    andi t3, t1, 0x02
    beqz t3, check_left

    # Cannot reverse UP -> DOWN
    li t4, DIR_UP
    beq t2, t4, direction_done

    li t2, DIR_DOWN
    sw t2, 0(t0)

    j direction_done


check_left:

    # --------------------------------------------------------
    # LEFT
    # --------------------------------------------------------

    andi t3, t1, 0x04
    beqz t3, check_right

    # Cannot reverse RIGHT -> LEFT
    li t4, DIR_RIGHT
    beq t2, t4, direction_done

    li t2, DIR_LEFT
    sw t2, 0(t0)

    j direction_done


check_right:

    # --------------------------------------------------------
    # RIGHT
    # --------------------------------------------------------

    andi t3, t1, 0x08
    beqz t3, direction_done

    # Cannot reverse LEFT -> RIGHT
    li t4, DIR_LEFT
    beq t2, t4, direction_done

    li t2, DIR_RIGHT
    sw t2, 0(t0)


direction_done:

    # --------------------------------------------------------
    # Movement speed
    # --------------------------------------------------------

    jal ra, game_delay


    # --------------------------------------------------------
    # Read current head
    # --------------------------------------------------------

    li t0, SNAKE_BASE
    lw s6, 0(t0)

    # X
    andi t2, s6, 0xFF

    # Y
    srli t3, s6, 8
    andi t3, t3, 0xFF


    # --------------------------------------------------------
    # Read direction
    # --------------------------------------------------------

    li t0, DIR_ADDR
    lw s5, 0(t0)


    # --------------------------------------------------------
    # Compute next head
    # --------------------------------------------------------

    li t4, DIR_UP
    beq s5, t4, move_up

    li t4, DIR_DOWN
    beq s5, t4, move_down

    li t4, DIR_LEFT
    beq s5, t4, move_left

    # RIGHT
    addi t2, t2, 1
    j new_head_ready


move_up:

    addi t3, t3, -1
    j new_head_ready


move_down:

    addi t3, t3, 1
    j new_head_ready


move_left:

    addi t2, t2, -1


new_head_ready:

    # ========================================================
    # WALL COLLISION
    #
    # Valid area:
    # X = 1 .. 38
    # Y = 1 .. 28
    # ========================================================

    beqz t2, game_over

    li t4, 39
    beq t2, t4, game_over

    beqz t3, game_over

    li t4, 29
    beq t3, t4, game_over


    # --------------------------------------------------------
    # Pack new head position
    # --------------------------------------------------------

    slli s0, t3, 8
    or s0, s0, t2


    # ========================================================
    # FOOD COLLISION
    # ========================================================

    li t0, FOOD_ADDR
    lw t1, 0(t0)

    # s1 = eating flag
    li s1, 0

    bne s0, t1, food_test_done

    li s1, 1


food_test_done:

    # --------------------------------------------------------
    # Load snake length
    # --------------------------------------------------------

    li t0, LENGTH_ADDR
    lw s2, 0(t0)


    # ========================================================
    # SELF COLLISION
    #
    # When the snake is not eating, its current tail disappears
    # during this movement, so we can exclude it.
    # ========================================================

    mv t1, s2

    bnez s1, collision_count_ready

    addi t1, t1, -1


collision_count_ready:

    beqz t1, collision_done

    li t0, SNAKE_BASE


collision_loop:

    lw t2, 0(t0)

    beq s0, t2, game_over

    addi t0, t0, 4
    addi t1, t1, -1

    bnez t1, collision_loop


collision_done:

    # ========================================================
    # SAVE OLD TAIL
    # ========================================================

    li s4, 0

    bnez s1, tail_saved

    addi t1, s2, -1

    slli t1, t1, 2

    li t0, SNAKE_BASE
    add t0, t0, t1

    lw s4, 0(t0)


tail_saved:

    # ========================================================
    # FOOD EATEN
    # ========================================================

    mv s3, s2

    beqz s1, length_ready

    # Increase snake length
    addi s3, s2, 1

    li t0, LENGTH_ADDR
    sw s3, 0(t0)

    # Increase score
    li t0, SCORE_ADDR
    lw t1, 0(t0)

    addi t1, t1, 1

    sw t1, 0(t0)

    # Update seven-segment
    li t0, SEVSEG_ADDR
    sw t1, 0(t0)


length_ready:

    # ========================================================
    # SHIFT BODY
    #
    # body[i] = body[i - 1]
    # ========================================================

    addi t1, s3, -1

    beqz t1, shift_done

    slli t2, t1, 2

    li t0, SNAKE_BASE
    add t0, t0, t2


shift_loop:

    lw t3, -4(t0)

    sw t3, 0(t0)

    addi t0, t0, -4
    addi t1, t1, -1

    bnez t1, shift_loop


shift_done:

    # Store new head
    li t0, SNAKE_BASE
    sw s0, 0(t0)


    # ========================================================
    # ERASE OLD TAIL
    # ========================================================

    bnez s1, skip_tail_erase

    andi a0, s4, 0xFF

    srli a1, s4, 8
    andi a1, a1, 0xFF

    li a2, COLOR_BLACK

    jal ra, draw_cell


skip_tail_erase:

    # ========================================================
    # OLD HEAD BECOMES BODY
    # ========================================================

    li t0, SNAKE_BASE
    lw t1, 4(t0)

    andi a0, t1, 0xFF

    srli a1, t1, 8
    andi a1, a1, 0xFF

    li a2, COLOR_GREEN

    jal ra, draw_cell


    # ========================================================
    # DRAW NEW HEAD
    # ========================================================

    andi a0, s0, 0xFF

    srli a1, s0, 8
    andi a1, a1, 0xFF

    li a2, COLOR_YELLOW

    jal ra, draw_cell


    # ========================================================
    # NEW FOOD
    # ========================================================

    beqz s1, game_loop

    jal ra, spawn_food

    srli a1, a0, 8
    andi a1, a1, 0xFF

    andi a0, a0, 0xFF

    li a2, COLOR_RED

    jal ra, draw_cell

    j game_loop


# ============================================================
# GAME OVER
# ============================================================

game_over:

    # Turn LEDs off
    li t0, LEDS_ADDR
    sw zero, 0(t0)

    # Display DEAD
    li t0, SEVSEG_ADDR
    li t1, 0x0000DEAD
    sw t1, 0(t0)


wait_restart:

    li t0, BUTTONS_ADDR
    lw t1, 0(t0)

    # CENTER restarts
    andi t2, t1, 0x10

    beqz t2, wait_restart

    j game_init


# ============================================================
# CLEAR SCREEN
#
# 320 x 240 = 76800 bytes
# 76800 / 4 = 19200 words
# ============================================================

clear_screen:

    li t0, VRAM_ADDR

    li t1, 19200


clear_screen_loop:

    sw zero, 0(t0)

    addi t0, t0, 4

    addi t1, t1, -1

    bnez t1, clear_screen_loop

    ret


# ============================================================
# DRAW BORDER
#
# White border around 40 x 30 game board
# ============================================================

draw_border:

    # Save return address because this function calls draw_cell
    mv s11, ra


    # --------------------------------------------------------
    # TOP
    # --------------------------------------------------------

    li s0, 0


border_top_loop:

    mv a0, s0

    li a1, 0

    li a2, COLOR_WHITE

    jal ra, draw_cell

    addi s0, s0, 1

    li t0, 40

    blt s0, t0, border_top_loop


    # --------------------------------------------------------
    # BOTTOM
    # --------------------------------------------------------

    li s0, 0


border_bottom_loop:

    mv a0, s0

    li a1, 29

    li a2, COLOR_WHITE

    jal ra, draw_cell

    addi s0, s0, 1

    li t0, 40

    blt s0, t0, border_bottom_loop


    # --------------------------------------------------------
    # SIDES
    # --------------------------------------------------------

    li s0, 1


border_side_loop:

    # Left side
    li a0, 0

    mv a1, s0

    li a2, COLOR_WHITE

    jal ra, draw_cell


    # Right side
    li a0, 39

    mv a1, s0

    li a2, COLOR_WHITE

    jal ra, draw_cell


    addi s0, s0, 1

    li t0, 29

    blt s0, t0, border_side_loop


    mv ra, s11

    ret


# ============================================================
# DRAW CELL
#
# a0 = cell X
# a1 = cell Y
# a2 = color
#
# Each cell is 8 x 8 framebuffer pixels
#
# framebuffer address:
#
# Y * 8 rows * 320 pixels
# +
# X * 8 pixels
#
# Y * 2560 + X * 8
#
# 2560 = 2048 + 512
# ============================================================

draw_cell:

    # Y * 2048
    slli t0, a1, 11

    # Y * 512
    slli t1, a1, 9

    # Y * 2560
    add t0, t0, t1

    # X * 8
    slli t1, a0, 3

    add t0, t0, t1

    # Add VRAM base
    li t1, VRAM_ADDR

    add t0, t0, t1


    # --------------------------------------------------------
    # Draw 8 rows
    # --------------------------------------------------------

    li t2, 8


draw_cell_row:

    sb a2, 0(t0)
    sb a2, 1(t0)
    sb a2, 2(t0)
    sb a2, 3(t0)

    sb a2, 4(t0)
    sb a2, 5(t0)
    sb a2, 6(t0)
    sb a2, 7(t0)

    # Next framebuffer row
    addi t0, t0, 320

    addi t2, t2, -1

    bnez t2, draw_cell_row

    ret


# ============================================================
# SPAWN FOOD
#
# Generates pseudo-random X/Y position
#
# X = 1 .. 38
# Y = 1 .. 28
#
# Food is rejected if it overlaps snake.
#
# Returns:
#   a0 = packed XY
# ============================================================

spawn_food:


spawn_food_retry:

    # --------------------------------------------------------
    # Load random state
    # --------------------------------------------------------

    li t0, RNG_ADDR

    lw t1, 0(t0)


    # ========================================================
    # XORSHIFT32
    #
    # x ^= x << 13
    # x ^= x >> 17
    # x ^= x << 5
    # ========================================================

    slli t2, t1, 13

    xor t1, t1, t2


    srli t2, t1, 17

    xor t1, t1, t2


    slli t2, t1, 5

    xor t1, t1, t2


    # Save new RNG state
    sw t1, 0(t0)


    # ========================================================
    # X POSITION
    #
    # X = (random byte % 38) + 1
    # ========================================================

    andi t2, t1, 0xFF

    li t3, 38


food_x_mod:

    bltu t2, t3, food_x_ready

    sub t2, t2, t3

    j food_x_mod


food_x_ready:

    addi t2, t2, 1


    # ========================================================
    # Y POSITION
    #
    # Y = (next byte % 28) + 1
    # ========================================================

    srli t4, t1, 8

    andi t4, t4, 0xFF

    li t5, 28


food_y_mod:

    bltu t4, t5, food_y_ready

    sub t4, t4, t5

    j food_y_mod


food_y_ready:

    addi t4, t4, 1


    # ========================================================
    # PACK POSITION
    # ========================================================

    slli t6, t4, 8

    or t6, t6, t2


    # ========================================================
    # CHECK FOOD DOES NOT OVERLAP SNAKE
    # ========================================================

    li t0, LENGTH_ADDR

    lw a1, 0(t0)

    li t0, SNAKE_BASE


food_collision_loop:

    beqz a1, food_position_valid

    lw a2, 0(t0)

    beq t6, a2, spawn_food_retry

    addi t0, t0, 4

    addi a1, a1, -1

    j food_collision_loop


food_position_valid:

    # Save food
    li t0, FOOD_ADDR

    sw t6, 0(t0)

    # Return packed position
    mv a0, t6

    ret


# ============================================================
# GAME DELAY
#
# Software delay.
# No timer peripheral required yet.
# ============================================================

game_delay:

    li t0, MOVE_DELAY


game_delay_loop:

    addi t0, t0, -1

    bnez t0, game_delay_loop

    ret