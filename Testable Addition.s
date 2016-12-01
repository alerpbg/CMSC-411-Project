@ FIR Filter
@ Properly converts hexadecimal number to IEEE 754
@ Properly adds IEEE 754 numbers
@ Updates exponent after addition
@ Stores final sum in R3

	.text

	.global _start

_start:
	

ValueBreakdown:

	LDR r1, =0x4571d35c

	LDR r2, =0x3c4e703b

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

	MOV r8, r2, LSL #9		;shift out sign and exponent

	ADD r8, r8, r10			;add the omitted top bit

	MOV r8, r8, ROR #1		;rotate that bit to the beginning of the number

	MOV r8, r8, LSR #8		;fraction num 2

	

	EOR r9, r9, r9

	EOR r12, r12, r12

	EOR r11, r11, r11


	

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

	EOR r7, r7, r1		;if negative, flip bits

	ADD r7, r7, r11		;add one to change to twos compliment

second_sign_first:	

	CMP r4, r0			;check num 2 sign bit

	BEQ	store_exp_first

	EOR r8, r8, r1		;if negative, flip bits

	ADD r8, r8, r11

store_exp_first:

	MOV r10, r5			;stores the largest exponent

	B addition

	

shift_second_num:

	SUB r9, r6, r5		;difference in exponent 2 and 1

	MOV r7, r7, LSR r9	;stores num 1 with same exponent

	MOV r8, r8		;stores num 2 with same exponent

	CMP r3, r0			;check num 1 sign bit

	BEQ second_sign_second

	EOR r7, r7, r1		;if negative, flip bits

	ADD r7, r7, r11		;add one to change to twos compliment

second_sign_second:	

	CMP r4, r0			;check num 2 sign bit

	BEQ	store_exp_second

	EOR r8, r8, r1		;if negative, flip bits

	ADD r8, r8, r11		;add one to change to twos complement

store_exp_second:	

	MOV r10, r6 		;stores the largest exponent

	EOR r3, r3, r3

	EOR r4, r4, r4

addition:

	MOV r3, #0x00800000

	ADD	r12, r7, r8			;stored num1 + num2	

	MOV r13, r12, LSR #31	;stores the sign of addition

	CMP r13, r0

	BEQ add_exp

	SUB r12, r12, r11		;subtract one from twos complement number

	EOR r12, r12, r1		;flips bits since it is negative

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
	
	MOV r12, r12, LSL #9
	
	MOV r12, r12, LSR #9
	
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
