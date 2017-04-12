cycle:
addi r1, r0, #8
nop
nop
nop
sw   4(r0), r1
nop
nop
nop
lw   r2, 4(r0)
add  r3, r2, r1
j cycle
nop