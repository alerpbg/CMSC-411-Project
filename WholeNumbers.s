@ FIR Filter
	.text
	.global _start
_start:
	;load string
	LDR r0,=readIn ;loads address of first index of string
	LDRB r1, [r0]   ;loads first element of string into r1
	LDR r2,=pos    ;r2 points to positive sign
	LDR r3,=neg    ;r3 points to negative sign
	LDRB r4, [r2]	;r4 is + sign
	LDRB r5,[r3]	;r5 is - sign
	;take string and load a negative sign as a 1
	;take the parts before the decimal and convert those to binary for one value
	;take the decimal and convert to ieee with whatever is after the decimal point
	
	MOV r2, #0	;zero out r2 and r3 for later use
	MOV r3, #0
	

	CMP r1,r4	;if sign is + then put a 0 in r6
	BEQ positive

negative:
	
	MOV r6,#1	;if sign is - then put 1in r6 for sign bit
	MOV r1, #1	;set r1 to 1 (using r1 as string index offset) and zeroing r5 to use as sum
	MOV r5, #0
	B number_start

positive:
	
	MOV r6,#0	;puts 0 in r6 for sign bit
	MOV r1, #1	;set r1 to 1 (using r1 as string index offset) and zeroing r5 to use as sum
	MOV r5, #0

number_start:
	
	LDR r3, =dot	;r3 points to "."
	LDRB r4, [r3]	;r4 is "."

	ADD r0, r0, r1
	LDRB r2, [r0]	;put current string element into r2
	CMP r2, r4	;if r0 is dot then skip the whole num and go to fraction #s reading
	BEQ appendFracNums

appendNums:

	
	ADD r5, r5, r5	;multiply by 10
	ADD r5, r5, r5
 	ADD r5, r5, r5
	ADD r5, r5, r5
	ADD r5, r5, r5
	ADD r5, r5, r5
 	ADD r5, r5, r5
	ADD r5, r5, r5
	ADD r5, r5, r5
	ADD r5, r5, r5

	SUB r9, r0, #48	;gets int value of character
	ADD r5, r5, r9	;adds int value to sum
	ADD r1, r1, #1	;increments string index offset
	B number_start	

appendFracNums:
	
	MOV r10, #123
	
 
	;while not "." mov it into register 7
	;while not end of string mov it into register 8 
	




	.data
readIn: .asciz "-1234.5"
pos: 	.asciz "+"
neg:	.asciz "-"
dot:	.asciz "."


.end

