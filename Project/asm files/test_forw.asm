addi r1, r0, #255
subi r2, r1, #252
sra r3, r1, r2
sw 0(r2), r3
sltu r4, r2, r3
sw 0(r4), r4