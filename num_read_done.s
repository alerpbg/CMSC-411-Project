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

	MOV r0, #0
	MOV r1, #0
	MOV r2, #0
	MOV r3, #0		
	MOV r4, #0
	MOV r5, #0
	MOV r6, #0
	MOV r7, #0
	MOV r8, #0	
	
ValueBreakdown:
	LDR r1, =num1
	LDR r2, =num2
							;get sign bit
	MOV r3, r1, LSR #31		;sign num 1		
	MOV r4, r2, LSR #31		;sign num 2
							;get exponents
	MOV r5, r1, LSL #1		
	MOV r6, r2, LSL #1
	MOV r5, r5, LSR #24		;exponent num 1
	MOV r6, r6, LSR #24		;exponent num 2
	
fractions_get:
							;get fractions
	MOV r10, #1
	MOV r7, r1, LSL #9		;shift out sign and exponent
	ADD r7, r7, r10			;add the omitted top bit
	MOV r7, r7, ROR #1		;rotate that bit to the beginning of the number
	MOV r7, r7, LSR #8		;fraction num 1
	MOV r8, r1, LSL #9		;shift out sign and exponent
	ADD r8, r8, r10			;add the omitted top bit
	MOV r8, r8, ROR #1		;rotate that bit to the beginning of the number
	MOV r8, r8, LSR #9		;fraction num 2
	
	XOR r9, r9, r9
	XOR r12, r12, r12
	XOR r11, r11, r11
	
normalize_exponent:
	MOV r1, #0xFFFFFFFF	;used with xor to flip bits
	MOV r2, #0x01000000 ;2^24 to check if addition and subtraction shifts exponent
	MOV r11, #1			;used to store value of 1
	SUB r9, r5, r6		;check the differnce in exponent 1 and 2
	CMP r9, r0
	BLT shift_second_num
	MOV r7, r7			;stores num 1 with same exponent
	MOV r8, r8, LSR r9	;stores num 2 with same exponent
	CMP r3, r0			;check num 1 sign bit
	BEQ second_sign_first
	XOR r7, r7, r1		;if negative, flip bits
	ADD r7, r7, r11		;add one to change to twos compliment
second_sign_first:	
	CMP r4, r0			;check num 2 sign bit
	BEQ	store_exp_first
	XOR r8, r8, r1		;if negative, flip bits
	ADD r8, r8, r11
store_exp_first:
	MOV r10, r5			;stores the largest exponent
	B addition
	
shift_second_num:
	SUB r9, r6, r5		;difference in exponent 2 and 1
	MOV r7, r7, LSR r9	;stores num 1 with same exponent
	MOV r8, r8, 		;stores num 2 with same exponent
	CMP r3, r0			;check num 1 sign bit
	BEQ second_sign_second
	XOR r7, r7, r1		;if negative, flip bits
	ADD r7, r7, r11		;add one to change to twos compliment
second_sign_second:	
	CMP r4, r0			;check num 2 sign bit
	BEQ	store_exp_second
	XOR r8, r8, r1		;if negative, flip bits
	ADD r8, r8, r11		;add one to change to twos complement
store_exp_second:	
	MOV r10, r6 		;stores the largest exponent
	XOR r3, r3, r3
	XOR r4, r4, r4
addition:
	MOV r3, 0x00800000
	ADD	r12, r7, r8			;stored num1 + num2	
	MOV r13, r12, LSR #31	;stores the sign of addition
	CMP r13, r0
	BEQ add_exp
	SUB r12, r12, r11		;subtract one from twos complement number
	XOR r12, r12, r1		;flips bits since it is negative
add_exp:
	CMP r12, r2
	BGE add_exp_greater
	CMP r12, r3
	BGT move_back
	SUB r10, r10, r11
	MOV r12, r12, LSL #1
	B move_back 
add_exp_greater:
	ADD r10, r10, r11
	MOV r12, r12, LSR #1

move_back:
	ADD r3, r3, r13
	MOV r3, r3, LSL #8
	ADD r3, r3, r10
	MOV r3, r3, LSL #23
	ADD r3, r3, r12
	STR r3, =sum1and2
	
	
	
	.data
readIn: .asciz "-1.56789$"

signed_bit: .word 0
whole_num: .word 0
frac_num: .word 0

exponent: .word 0
mantissa: .word 0

num1: 	.word 0
num2:	.word 0
sum1and2:	.word 0


.end
