.option norvc
.option norelax

.section .text
.globl _start

_start:

    # ----------------------------------------------------------
    # Initial values
    # ----------------------------------------------------------

    addi x1, x0, 5
    addi x2, x0, 10
    addi x3, x0, -1
    addi x4, x0, 3


    # ----------------------------------------------------------
    # R-TYPE
    # ----------------------------------------------------------

    add  x5,  x1, x2
    sub  x6,  x2, x1
    sll  x7,  x1, x4
    slt  x8,  x3, x1
    sltu x9,  x3, x1
    xor  x10, x1, x2
    srl  x11, x3, x4
    sra  x12, x3, x4
    or   x13, x1, x2
    and  x16, x1, x2


    # ----------------------------------------------------------
    # I-TYPE ALU
    # ----------------------------------------------------------

    slli  x17, x1, 2
    slti  x18, x3, 0
    sltiu x19, x3, 1
    xori  x20, x1, 15
    srli  x21, x3, 4
    srai  x22, x3, 4
    ori   x23, x1, 8
    andi  x24, x2, 7


    # ----------------------------------------------------------
    # U-TYPE
    # ----------------------------------------------------------

    lui   x25, 0x12345
    auipc x26, 0


    # ----------------------------------------------------------
    # JAL
    #
    # JAL writes PC + 4 into x14 and skips the next instruction.
    # ----------------------------------------------------------

    jal x14, jalr_site

    addi x27, x0, 99


jalr_site:

    # ----------------------------------------------------------
    # JALR
    #
    # x14 contains the address immediately after the JAL.
    #
    # x14 + 13 produces an odd address.
    # JALR must clear bit 0 and jump to jalr_target.
    # ----------------------------------------------------------

    jalr x15, 13(x14)

    addi x28, x0, 99


jalr_target:

    addi x28, x0, 11


    # ----------------------------------------------------------
    # MEMORY TEST DATA
    #
    # Build:
    #
    # x29 = 0x80FF7F01
    # ----------------------------------------------------------

    lui  x29, 0x80ff8
    addi x29, x29, -255


    # ----------------------------------------------------------
    # STORE WORD
    #
    # Memory bytes after SW:
    #
    # base + 0 -> 01
    # base + 1 -> 7F
    # base + 2 -> FF
    # base + 3 -> 80
    # ----------------------------------------------------------

    sw x29, 1024(x14)


    # ----------------------------------------------------------
    # LOADS
    # ----------------------------------------------------------

    lb  x30, 1027(x14)
    lbu x31, 1026(x14)

    lh  x5,  1026(x14)
    lhu x6,  1026(x14)

    lw  x7,  1024(x14)


    # ----------------------------------------------------------
    # PARTIAL STORES
    # ----------------------------------------------------------

    sb x1, 1025(x14)
    sh x2, 1026(x14)


    # Final memory word should become:
    #
    # 0x000A0501
    # ----------------------------------------------------------

    lw x8, 1024(x14)


    # ----------------------------------------------------------
    # TAKEN BRANCHES
    # ----------------------------------------------------------

    beq x1, x1, beq_taken
    addi x9, x0, 91

beq_taken:

    bne x1, x2, bne_taken
    addi x9, x0, 92

bne_taken:

    blt x3, x1, blt_taken
    addi x9, x0, 93

blt_taken:

    bge x2, x1, bge_taken
    addi x9, x0, 94

bge_taken:

    bltu x1, x3, bltu_taken
    addi x9, x0, 95

bltu_taken:

    bgeu x3, x1, bgeu_taken
    addi x9, x0, 96


bgeu_taken:

    # ----------------------------------------------------------
    # NOT-TAKEN BRANCHES
    # ----------------------------------------------------------

    beq  x1, x2, branch_fail
    bne  x1, x1, branch_fail
    blt  x2, x1, branch_fail
    bge  x1, x2, branch_fail
    bltu x3, x1, branch_fail
    bgeu x1, x3, branch_fail


    # ----------------------------------------------------------
    # Successful completion marker
    # ----------------------------------------------------------

    addi x9, x0, 42


loop:

    jal x0, loop


branch_fail:

    addi x9, x0, 99
    jal x0, loop