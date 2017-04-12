addi r1, r0, #255
addui r2, r0, #-10
andi r3, r1, #65535
ori r4, r1, #31
seqi r5, r1, #255
sgei r6, r1, #-1
sgeui r7, r1, #10
sgti r8, r1, #-2
sgtui r9, r1, #9
slei r10, r2, #-5
sleui r11, r2, #5
slli r12, r1, #3
slti r13, r2, #-5
sltui r14, r2, #5
snei r15, r1, #85
srli r16, r1, #3
subi r17, r1, #250
subui r18, r1, #200
xori r19, r1, #65535
lhi r20, #50
add r21, r1, r2
addu r22, r1, r2
and r23, r1, r2
or r24, r12, r5
seq r25, r3, r4
sge r26, r1, r2
sgeu r27, r2, r1
sgt r28, r1, r2
sgtu r29, r2, r1
sle r30, r2, r1
sleu r31, r1, r2
sll r20, r1, r5
slt r21, r2, r1
sltu r22, r1, r2
sne r23, r1, r2
sra r24, r19, r5
srl r25, r19, r5
sub r26, r2, r19
subu r27, r2, r19
xor r28, r2, r5
sb 0(r1), r2
sh 1(r1), r2
sw 2(r1), r2
nop
lb r29, 0(r1)
lbu r30, 0(r1)
lh r31, 1(r1)
lhu r20, 1(r1)
lw r21, 2(r1)
addi r22, r0, #228
addi r23, r0, #204
j label_1
nop
label_1:
jal label_2
nop
label_2:
jalr r22
nop
jr r23
nop