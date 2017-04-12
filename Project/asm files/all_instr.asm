addi r1, r0, #1
addi r2, r0, #2
addi r3, r0, #3
addi r4, r0, #4
addi r5, r0, #5
addi r6, r0, #6
addi r7, r0, #7
addi r8, r0, #8
addi r9, r0, #9
addi r10, r0, #10
addi r11, r0, #11
addi r12, r0, #12
addi r13, r0, #13
addi r14, r0, #14
addi r15, r0, #15
addi r16, r0, #16
addi r17, r0, #17
addi r18, r0, #18
addi r19, r0, #19
addi r20, r0, #20
addi r21, r0, #21
addi r22, r0, #22
addi r23, r0, #23
addi r24, r0, #24
addi r25, r0, #25
addi r26, r0, #26
addi r27, r0, #27
addi r28, r0, #28
addi r29, r0, #29
addi r30, r0, #30
addi r31, r0, #31
cicle:
sw  4(r0), r28
add r31, r1, r2
and r30, r3, r4
or  r29, r5, r6
sge r28, r7, r8
sle r27, r9, r10
sll r26, r11, r12
srl r25, r13, r14
sub r24, r15, r16
xor r23, r17, r18
lw  r22, 4(r0)
j label
nop
addi r1, r0, #1
addi r2, r0, #2
addi r3, r0, #3
label:
bnez r25, cicle
nop
beqz r25, cicle
nop
