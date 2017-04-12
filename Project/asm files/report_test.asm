addi r1, r0, #3
label:
subi r1, r1, #1
sw 1(r0), r1
lw r1, 1(r0)
bnez r1, label
nop