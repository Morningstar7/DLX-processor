addi r1, r0, #3
addi r2, r0, #10
addi r3, r0, #7
label:
mult r4, r3, r2
div r5, r2, r4
sle r6, r5, #7
beqz r6, test
addi r7, r0, #256
test:
subi r1, r1, #1
addi r8, r0, #512
addi r9, r0, #1024
bnez r1, label
nop
nop