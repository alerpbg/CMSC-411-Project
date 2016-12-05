@ Converts successfully with all tested numbers
@ Tested with 0x3001A000, 0x10F1A800, 0x7FFFF000, 0x0000F000, 0x0000a800, and 0xFFFFFFFF successfully

@ FIR Filter
	.text
	.global _start
_start:

	LDR r1, =0x3001A000
	LDR r2, =0x3001A000

	MOV r3, r1, LSR #31		;sign num 1		
	MOV r4, r2, LSR #31		;sign num 2
	STR r3, =num1_sign		; store the signs
	STR r4, =num2_sign
	
	EOR r3, r3, r3 			; clear registers for reuse
	EOR r4, r4, r4

	MOV r3, r1, LSL #1		; num1 without sign bit
	MOV r8, #14 			; counter for the integer mark
	MOV r9, #1				; hold the constant 1
	
num1_integer:

	MOV r4, r3, LSR #31 	; check if the first bit has a 1
	CMP r4, r9		; if it is then it computes the exponent, else it checks the next bit
	BEQ num1_exponent
	
	MOV r3, r3, LSL #1	; shift left by one
	SUB r8, r8, r9		;subtracting 1 from counter
	B num1_integer
	
num1_exponent:

	MOV r7, #127
	ADD r7, r7, r8
	STR r7, =num1_exp		; store the num1 exponent
	
num1_mant:

	MOV r3, r3, LSL #1		; mantissa
	STR r3, =num1_mantissa

	LDR r8, =num1_sign	;putting each component into a register
	LDR r9, =num1_exp
	LDR r10, =num1_mantissa

	EOR r3, r3, r3

	ADD r3, r3, r8		;adding sign bit to final register
	MOV r3, r3, LSL #8	;making room for exponent
	
	ADD r3, r3, r9		;adding exponent
	MOV r3, r3, LSL #23	;making room for mantissa
	
	MOV r10, r10, LSR #9	;shifting mantissa to fit format
	ADD r3, r3, r10		;adding mantissa

	STR r3, =ieee1


num2_start:

	EOR r3, r3, r3
	EOR r4, r4, r4
	EOR r5, r5, r5 			; clear registers for reuse
	EOR r6, r6, r6
	EOR r7, r7, r7 			; clear registers for reuse
	EOR r8, r8, r8
	EOR r9, r9, r9 			; clear registers for reuse
	EOR r10, r10, r10

	MOV r3, r2, LSL #1		; num2 without sign bit
	MOV r8, #14 			; counter for the integer mark
	MOV r9, #1				; hold the constant 1
	
num2_integer:

	MOV r4, r3, LSR #31 	; check if the first bit has a 1
	CMP r4, r9
	BEQ num2_exponent
	
	MOV r3, r3, LSL #1		; shift left by one
	SUB r8, r8, r9
	B num2_integer
	
num2_exponent:

	MOV r7, #127
	ADD r7, r7, r8
	STR r7, =num2_exp		; store the num2 exponent
	
num2_mant:

	MOV r3, r3, LSL #1		; mantissa
	STR r3, =num2_mantissa

	LDR r8, =num2_sign	;putting each component into a register for troubleshooting
	LDR r9, =num2_exp
	LDR r10, =num2_mantissa

	EOR r3, r3, r3

	ADD r3, r3, r8		;adding sign bit to final register
	MOV r3, r3, LSL #8	;making room for exponent
	
	ADD r3, r3, r9		;adding exponent
	MOV r3, r3, LSL #23	;making room for mantissa
	
	MOV r10, r10, LSR #9	;shifting mantissa to fit format
	ADD r3, r3, r10		;adding mantissa

	STR r3, =ieee2
	
.data

num1_sign: 	.word 0
num2_sign: 	.word 0
num1_exp: 	.word 0
num2_exp:	.word 0
num1_mantissa: .word 0
num2_mantissa: .word 0
ieee1:	.word 0
ieee2:	.word 0
	
.end