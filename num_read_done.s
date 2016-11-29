@ FIR Filter
	.text
	.global _start
_start:
	;load string
	LDR r0,=readIn ;loads address of first index of string
	LDRB r1, [r0]   ;loads first element of string into r1
	
	MOV r3, #43		; ASCII for "+"
	MOV r5, #46		; ASCII for "."
	
	;take string and load a negative sign as a 1
	;take the parts before the decimal and convert those to binary for one value
	;take the decimal and convert to ieee with whatever is after the decimal point

	CMP r1, r5	;if sign is + then put a 0 in r6
	BEQ positive

negative:
	
	MOV r6,#1	;if sign is - then put 1in r6 for sign bit
	MOV r1, #1	;set r1 to 1 (using r1 as string index offset)
	STR r6, =signed_bit
	
	MOV r6, #0	; clear r6 for reuse (signed bit already stored)
	B number_start

positive:
	
	MOV r6,#0	;puts 0 in r6 for sign bit
	MOV r1, #1	;set r1 to 1 (using r1 as string index offset)
	STR r6, =signed_bit
	MOV r6, #0  ; clear r6 for reuse

number_start:

	LDRB r2, [r0, r1]; get character in number string
	ADD r1, r1, #1	; r1 is string index offset
	CMP r2, r5		; if character is "." then jump
	BEQ decimal_start
	
	ADD r9, r7, r9
	ADD r9, r7, r9
	ADD r9, r7, r9
	ADD r9, r7, r9
	ADD r9, r7, r9
	ADD r9, r7, r9
	ADD r9, r7, r9
	ADD r9, r7, r9
	ADD r9, r7, r9
	
	SUB r2, r2, #48	; ASCII -> actual number
	ADD r9, r9, r2	; add the new digit
	MOV r7, r9 		; r7 = r9 so we can "multiply" the sum by 10

	B 	number_start

decimal_start:
	STR r9, =whole_num
	MOV r2, #0
	MOV r4, #0
	MOV r5, #0
	MOV r7, #0
	MOV r9, #0

decimal_loop:

	LDRB r2, [r0, r1]; get character in number string
	ADD r1, r1, #1	; r1 is string index offset
	CMP r2, #36		; if character is "$" then reached end of string
	BEQ clear_regs
	
	ADD r9, r7, r9
	ADD r9, r7, r9
	ADD r9, r7, r9
	ADD r9, r7, r9
	ADD r9, r7, r9
	ADD r9, r7, r9
	ADD r9, r7, r9
	ADD r9, r7, r9
	ADD r9, r7, r9
	
	SUB r2, r2, #48	; ASCII -> actual number
	ADD r9, r9, r2	; add the new digit
	MOV r7, r9 		; r7 = r9 so we can "multiply" the sum by 10
	
	ADD r2, r2, #48
	B decimal_loop
	
clear_regs:
	STR r4, =frac_num ; store the fraction part into frac_num
	
	MOV r0, #0
	MOV r1, #0
	MOV r2, #0
	MOV r3, #0		; used for binary form 
	MOV r4, #0
	MOV r5, #0
	MOV r6, #5
	MOV r7, #0
	MOV r8, #1		; used for binary form
	
	MOV r0, #16384 	; 2^14
	LDR r1, =whole_num
	
exponent_convert:

	SUB r2, r1, r0  ; remaining number minus by 2^x
	
	;MOV r0, r1, LSL #4
	;DIV r0, #2		; get 2^(x-1)
	
	CMP r2, #0		; if < 0, store a zero 
	BLT exponent_zero
	
	MUL r7, r4, r9 	; multiply by 10, basically (MUL r7, r7, #10) but syntax won't allow
	ADD r7, r7, r8	; add the new digit
	MOV r4, r7 		; r4 = r7 so we can mult by itself
	
	CMP r0, #0 		; if reached 2^0 != 0, then loop back up. Else, go to mantissa_convert
	BNE exponent_convert
	B mantissa_convert
	
exponent_zero:

	MUL r7, r4, r9 	; multiply by 10, basically (MUL r7, r7, #10) but syntax won't allow
	ADD r7, r7, r3	; add the new digit
	MOV r4, r7 		; r4 = r7 so we can mult by itself
	
	CMP r0, #0 		; if reached 2^0 = 0, then end of exponent part
	BNE exponent_convert

mantissa_convert:
	
	
	
	.data
readIn: .asciz "-1.56789$"

signed_bit: .word 0
whole_num: .word 0
frac_num: .word 0

exponent: .word 0
mantissa: .word 0

.end
