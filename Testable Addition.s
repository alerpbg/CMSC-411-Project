@ FIR Filter
@ Properly converts hexadecimal number to IEEE 754
@ Properly adds IEEE 754 numbers
@ Updates exponent after addition
@ Stores final sum in R3

	.text

	.global _start

_start:
	

ValueBreakdown:

	LDR r1, =0xc3cc2e14

	LDR r2, =0x41a1e354

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

	MOV r7, r7, LSR #7		;fraction num 1

	MOV r8, r2, LSL #9		;shift out sign and exponent

	ADD r8, r8, r10			;add the omitted top bit

	MOV r8, r8, ROR #1		;rotate that bit to the beginning of the number

	MOV r8, r8, LSR #7		;fraction num 2

	

	EOR r9, r9, r9

	EOR r12, r12, r12

	EOR r11, r11, r11


	

normalize_exponent:

	MOV r1, #0xFFFFFFFF	;used with xor to flip bits

	MOV r2, #0x02000000 ;2^25 to check if addition and subtraction shifts exponent

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
	
	MOV r4, r5

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
	
	MOV r4, r6

addition:

	MOV r9, #0x01000000

	ADDS	r12, r7, r8			;stored num1 + num2	

	ADDCS r13, r13, r11
	
	BNE carried

	MOV r13, r12, LSR #31	;stores the sign of addition
	
carried:	
	CMP r13, r0

	BEQ add_exp

	SUB r12, r12, r11		;subtract one from twos complement number

	EOR r12, r12, r1		;flips bits since it is negative

add_exp:

	CMP r12, r2				;checks if exponent increased

	BGE add_exp_greater		

	CMP r12, r9				;checks if exponent decreased

	BGE move_back

	SUB r10, r10, r11		;decrements exponent

	MOV r12, r12, LSL #1	;shifts number to normalize decimal

	B move_back 

add_exp_greater:

	ADD r10, r10, r11		;increments exponent

	MOV r12, r12, LSR #1	;shifts number to normalize decimal



move_back:
	EOR r9, r9, r9			;store answer in r9 and clear
	
	MOV r12, r12, LSR #1;	;shift number to fix earlier displacement

	ADD r9, r9, r13			;adds the sign to the answer

	MOV r9, r9, LSL #8		;shift to make space for exponent

	ADD r9, r9, r10			;add the exponent to the answer

	MOV r9, r9, LSL #23		;shift to make space for the mantissa
	
	MOV r12, r12, LSL #9	;shift out the highest order bit
	
	MOV r12, r12, LSR #9	;shift back into the proper space
	
	ADD r9, r9, r12			;add the mantissa to the answer

	LDR r14, =sum1and2 		;load the memory position of the sum
	
	STR r9, [r14]			;store the answer
	
	
	
	EOR r13, r13, r13
	
	EOR r12, r12, r12
	
	MOV r10, r4
	
	EOR r14, r14, r14	
	

subtraction:
	MOV r4, #0xF0000000
	
	CMP r8, r4 

	BGE neg_sub
	
	EOR r8, r8, r1		;flip bits for twos complement subtraction
	
	ADD r8, r8, r11		;add one to change to twos complement
	
	B sub_start
	
neg_sub:
	
	SUB r8, r8, r11
	
	EOR r8, r8, r1		;flip bits for twos complement subtraction

sub_start:
	
	MOV r4, #0x01000000

	ADDS	r12, r7, r8			;stored num1 - num2	
	
	ADDCS r13, r13, r11
	
	CMP r13, r0
	
	BNE carried_sub

	MOV r13, r12, LSR #31	;stores the sign of addition
	
carried_sub:

	CMP r13, r0

	BEQ add_exp_sub

	SUB r12, r12, r11		;subtract one from twos complement number

	EOR r12, r12, r1		;flips bits since it is negative

add_exp_sub:

	CMP r12, r2

	BGE add_exp_greater_sub

	CMP r12, r4

	BGE move_back_sub

	SUB r10, r10, r11

	MOV r12, r12, LSL #1

	B move_back_sub 

add_exp_greater_sub:

	ADD r10, r10, r11

	MOV r12, r12, LSR #1



move_back_sub:
	EOR r4, r4, r4

	MOV r12, r12, LSR #1;

	ADD r4, r4, r13

	MOV r4, r4, LSL #8

	ADD r4, r4, r10

	MOV r4, r4, LSL #23
	
	MOV r12, r12, LSL #9
	
	MOV r12, r12, LSR #9
	
	ADD r4, r4, r12
	
	LDR r14, =diff1and2 

	STR r4, [r14]
	
undo_negative:
	
	EOR r4, r4, r4
	
	MOV r4, #0xF0000000
	
	CMP r8, r4 

	BGE neg_undo
	
	;change sign of multiplication
	
	EOR r3, r3, r11
	
	B mul_start
	
neg_undo:
	
	SUB r8, r8, r11
	
	EOR r8, r8, r1		;flip bits for twos complement subtraction
	
	EOR r12, r12, r12
	
	MOV r10, r5
	
mul_start:
	
	CMP r8, r0
	
	BEQ done_mul
	
	MOV r9, #0x01000000

	ADDS	r12, r12, r7			;stored mul_sum + num1	

mul_exp:

	CMP r12, r2				;checks if exponent increased

	BGE mul_exp_greater		

	CMP r12, r9				;checks if exponent decreased

	BGE move_back

	SUB r10, r10, r11		;decrements exponent

	MOV r12, r12, LSL #1	;shifts number to normalize decimal

	B loopback
	
mul_exp_greater:

	ADD r10, r10, r11		;increments exponent

	MOV r12, r12, LSR #1	;shifts number to normalize decimal
	
	SUB r8, r8, r11
loopback:
	
	B mul_start

done_mul:
	
	CMP r3, r0
	
	BEQ mul_move_back
	
	SUB r12, r12, r11		;subtract one from twos complement number

	EOR r12, r12, r1		;flips bits since it is negative

mul_move_back:
	
	EOR r4, r4, r4

	MOV r12, r12, LSR #1;

	ADD r4, r4, r3

	MOV r4, r4, LSL #8

	ADD r4, r4, r10

	MOV r4, r4, LSL #23
	
	MOV r12, r12, LSL #9
	
	MOV r12, r12, LSR #9
	
	ADD r4, r4, r12
	
	LDR r14, =mul1and2 

	STR r4, [r14]
	

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

diff1and2:	.word 0

mul1and2:	.word 0





.end
