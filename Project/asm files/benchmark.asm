add r1, r0, r0		;inizialize x
addi r2, r0, #10	;loop counter
addi r31, r0, #5	;constant value for c
add r30, r0, r0	;set value to start saving in memory
label_1:
lw r3, 0(r1)
slli r4, r3, #2		;multiply by 4
lw r5, 1(r1)		;load second value
srai r6, r5, #1		;divide by 2
lw r7, 2(r1)		;load third value
mult r8, r7, r31	;multiply by c
add r8, r6, r8		;first addition
add r8, r4, r8		;second addition
sw 12(r30), r8		;store the data
addi r30, r30, #1	;increase the address for storing
addi r1, r1, #1		;increase index for the next sample
subi r2, r2, #1		;decrease the loop counter
bnez r2, label_1
nop
; add r1, r0, r0		; INIT R1 = 0
; addi r30, r0, #9	; INIT R30 = 9 AS THE N OF ELEMENTS TO SORT
; start:
; lw r2, 12(r1)		; LOAD FIRST ELEMENT
; lw r3, 13(r1)		; LOAD SECOND ELEMENT
; sge r31, r3, r2	; CHECK IF R3 > R2
; bnez r31, no_sorting	; IF SO, NO NEED TO SWAP
; sw 13(r1), r2		; STORE THE VALUES IN THE SWAPPED ORDER
; sw 12(r1), r3
; no_sorting:
; addi r1, r1, #1		; INCREASE THE INDEX
; sub r29, r30, r1	; DECREASE N OF ELEMENTS TO SORT
; bnez r29, start		; IF FINISH, RESTART
; subi r30, r30, #1	; 
; add r1, r0, r0
; bnez r30, start
; nop