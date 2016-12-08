@ Converts successfully with all tested numbers
@ Tested with 0x3001A000, 0x10F1A800, 0x7FFFF000, 0x0000F000, 0x0000a800, and 0xFFFFFFFF successfully
@ R9 holds OUR sum which corresponds to r1 which is FP sum
@ R4 holds OUR difference whcih corresponds to r2 which is FP difference
@ R_ holds OUR product which corresponds to r3 whcih is FP product



@ FIR Filter
	.text
	.global _start
_start:

	LDR r1, =0x10F1A800
	LDR r2, =0x3001A000

	CMP r1, #0
	BEQ store_zero_num1


	MOV r3, r1, LSR #31		;@sign num 1		
	MOV r4, r2, LSR #31		;@sign num 2
	LDR r14, =num1_sign
	STR r3, [r14]		;@ store the signs
	LDR r14, =num2_sign
	STR r4, [r14]
	
	EOR r3, r3, r3 			;@ clear registers for reuse
	EOR r4, r4, r4


	MOV r3, r1, LSL #1		;@ num1 without sign bit
	MOV r8, #14 			;@ counter for the integer mark
	MOV r9, #1				;@ hold the constant 1
	
num1_integer:


	MOV r4, r3, LSR #31 	;@ check if the first bit has a 1
	CMP r4, r9		;@ if it is then it computes the exponent, else it checks the next bit
	BEQ num1_exponent
	
	MOV r3, r3, LSL #1	;@ shift left by one
	SUB r8, r8, r9		;@subtracting 1 from counter
	B num1_integer
	
num1_exponent:


	MOV r7, #127
	ADD r7, r7, r8
	LDR r14, =num1_exp
	STR r7, [r14]		;@ store the num1 exponent
	
num1_mant:


	MOV r3, r3, LSL #1		;@ mantissa
	LDR r14, =num1_mantissa
	STR r3, [r14]

	LDR r8, =num1_sign	;@putting each component into a register
	LDR r8, [r8]
	LDR r9, =num1_exp
	LDR r9, [r9]
	LDR r10, =num1_mantissa
	LDR r10, [r10]


	EOR r3, r3, r3
	
	ADD r3, r3, r8		;@adding sign bit to final register
	MOV r3, r3, LSL #8	;@making room for exponent
	
	ADD r3, r3, r9		;@adding exponent
	MOV r3, r3, LSL #23	;@making room for mantissa
	
	MOV r10, r10, LSR #9	;@shifting mantissa to fit format
	ADD r3, r3, r10		;@adding mantissa

	LDR r14, =ieee1
	STR r3, [r14]

num2_start:

	EOR r3, r3, r3
	EOR r4, r4, r4
	EOR r5, r5, r5 			;@ clear registers for reuse
	EOR r6, r6, r6
	EOR r7, r7, r7 			;@ clear registers for reuse
	EOR r8, r8, r8
	EOR r9, r9, r9 			;@ clear registers for reuse
	EOR r10, r10, r10

	CMP r2, #0
	BEQ store_zero_num2	

	MOV r3, r2, LSL #1		;@ num2 without sign bit
	MOV r8, #14 			;@ counter for the integer mark
	MOV r9, #1				;@ hold the constant 1
	
num2_integer:


	MOV r4, r3, LSR #31 	;@ check if the first bit has a 1
	CMP r4, r9
	BEQ num2_exponent
	
	MOV r3, r3, LSL #1		;@ shift left by one
	SUB r8, r8, r9
	B num2_integer
	
num2_exponent:

	MOV r7, #127
	ADD r7, r7, r8
	;LDR r11, =num2_exp
	LDR r14, =num2_exp
	STR r7, [r14]		;@ store the num2 exponent (r7 is correct when this instruction is reached)
	
num2_mant:


	MOV r3, r3, LSL #1		;@ mantissa
	LDR r14, =num2_mantissa
	STR r3, [r14]

	EOR r9, r9, r9

	LDR r8, =num2_sign	;@putting each component into a register for troubleshooting
	LDR r8, [r8]
	LDR r9, =num2_exp
	LDR r9, [r9]
	LDR r10, =num2_mantissa
	LDR r10, [r10]

	EOR r3, r3, r3

	ADD r3, r3, r8		;@adding sign bit to final register
	MOV r3, r3, LSL #8	;@making room for exponent
	
	ADD r3, r3, r7		;@adding exponent
	MOV r3, r3, LSL #23	;@making room for mantissa
	
	MOV r10, r10, LSR #9	;@shifting mantissa to fit format
	ADD r3, r3, r10		;@adding mantissa

	LDR r14, =ieee2
	STR r3, [r14]

	B float_pt_mul

store_zero_num1:

	MOV r0, #0
	STR r0, =ieee2		;@store zero into memory
	STR r0, =num1_sign
	STR r0, =num1_exp
	STR r0, =num1_mantissa
	B num2_start 

store_zero_num2:

	MOV r0, #0
	STR r0, =ieee2		;@store zero into memory
	STR r0, =num2_sign
	STR r0, =num2_exp
	STR r0, =num2_mantissa

float_pt_mul:

	LDR r1, =ieee1
	LDR r1, [r1]
	LDR r2, =ieee2
	LDR r2, [r2]

ValueBreakdown:

	;LDR r1, =0x41b48f5c
	;LDR r2, =0x41dcf5c3
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

	MOV r7, r7, LSR #2		;fraction num 1

	MOV r8, r2, LSL #9		;shift out sign and exponent

	ADD r8, r8, r10			;add the omitted top bit

	MOV r8, r8, ROR #1		;rotate that bit to the beginning of the number

	MOV r8, r8, LSR #2		;fraction num 2

	

	EOR r9, r9, r9

	EOR r12, r12, r12

	EOR r11, r11, r11


	

normalize_exponent:

	MOV r1, #0xFFFFFFFF	;used with xor to flip bits

	MOV r2, #0x40000000 ;2^30 to check if addition and subtraction shifts exponent

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

	EOR r13, r13, r13

	MOV r9, #0x20000000		;2^29 because if sum is below @^29 then it degcreased

	ADD r12, r7, r8			;stored num1 + num2 and sets status bits (carry, zero, overflow, etc)	
	
	MOV r13, r12, LSR #31		;gets sign bit out of addition

	CMP r13, r0			; if carry bit isnt set then check what the value should be and set it
	
	BEQ check_sum	

neg_sum:

	SUB r12, r12, r11		;subtract one from twos complement number

	EOR r12, r12, r1		;flips bits since it is negative
	
check_sum:

	CMP r12, r0  			;checks special codition where the sum is zero and zeros out everything else
	
	BNE cont_add
	
	MOV r13, r0
	
	MOV r12, r0
	
	MOV r10, r0
	
	B move_back

cont_add:

	CMP r12, r2				;checks if exponent increased

	BGE add_exp_greater		
	
dec_exp:

	CMP r12, r9				;checks if exponent decreased

	BGE move_back

	SUB r10, r10, r11		;decrements exponent

	MOV r12, r12, LSL #1	;shifts number to normalize decimal

	B dec_exp

add_exp_greater:

	ADD r10, r10, r11		;increments exponent

	MOV r12, r12, LSR #1	;shifts number to normalize decimal



move_back:
	EOR r9, r9, r9			;store answer in r9 and clear
	
	MOV r12, r12, LSR #6;	;shift number to fix earlier displacement

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
	
	EOR r13, r13, r13
	
	MOV r4, #0x40000000   ;subtraction is the same as addition but with the added effect of switching the sign bits: all stuff before sub_start, rest is addition
	
	AND r4, r4, r8
	
	CMP r4, r0 

	BNE neg_sub
	
	EOR r8, r8, r1		;flip bits for twos complement subtraction
	
	ADD r8, r8, r11		;add one to change to twos complement
	
	B sub_start
	
neg_sub:
	
	SUB r8, r8, r11
	
	EOR r8, r8, r1		;flip bits for twos complement subtraction

sub_start:
	
	MOV r4, #0x20000000

	ADD	r12, r7, r8			;stored num1 - num2	
	
	MOV r13, r12, LSR #31		;gets sign bit out of addition

	CMP r13, r0	
	
	BEQ check_sum_sub	

neg_sub_flip:

	SUB r12, r12, r11		;subtract one from twos complement number

	EOR r12, r12, r1		;flips bits since it is negative
	
check_sum_sub:
	
	CMP r12, r0
	
	BNE cont_sub
	
	MOV r13, r0
	
	MOV r12, r0
	
	MOV r10, r0
	
	B move_back_sub

cont_sub:

	CMP r12, r2

	BGE add_exp_greater_sub
	
sub_dec_exp:

	CMP r12, r4

	BGE move_back_sub

	SUB r10, r10, r11

	MOV r12, r12, LSL #1

	B sub_dec_exp 

add_exp_greater_sub:

	ADD r10, r10, r11

	MOV r12, r12, LSR #1

move_back_sub:
	EOR r4, r4, r4

	MOV r12, r12, LSR #6;

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
	
	MOV r4, #0x80000000           ; holds 2^31 becaause largest number 
	
	AND r4, r4, r8
	
	CMP r4, r0

	BNE neg_undo 			; flip 2nd sign value back if it was a positive number
	
	;change sign of multiplication
	
	EOR r3, r3, r11   		
	
	B check_inc_neg
	
neg_undo:
	
	SUB r8, r8, r11
	
	EOR r8, r8, r1		;flip bits for twos complement subtraction
	
	EOR r12, r12, r12
	
	MOV r10, r5
	
	EOR r12, r12, r12
	
check_inc_neg:
	
	MOV r4, #0x80000000          ;all of this checks if the first number is negative
	
	AND r4, r7, r4
	
	CMP r4, r0
	
	BEQ mul_exp
	
	SUB r7, r7, r11
	
	EOR r7, r7, r1
	
mul_exp:
	MOV r9, #127				;gets final exponent(sum of two exponents except: + 1 if it overflows)
	
	ADD	r10, r5, r6			; add 127 after the addition
	
	SUB r10, r10, r9
	
	SUB r6, r6, r9

	MOV r2, #29
	
mul_dec_setup:

	MOV r4, #0x01000000
	
	CMP r7, r4
	
	BLT mov_back_second
	
	MOV r7, r7, LSR #1
	
	B mul_dec_setup
	
mov_back_second:

	CMP r8, r4
	
	BLT cont_mov
	
	MOV r8, r8, LSR #1
	
	B mov_back_second
	
cont_mov:
	
	MOV r4, #0x00800000

mov_forward_first:

	CMP r7, r4
	
	BGE mov_forward_second
	
	MOV r7, r7, LSL #1
	
	B mov_forward_first

mov_forward_second:

	CMP r8, r4
	
	BGE cont
	
	MOV r8, r8, LSL #1
	
	B mov_forward_second 

cont:
	
	EOR r9, r9, r9
	
	EOR r14, r14, r14
	
	EOR r13, r13, r13
	
mul_start:
	
	CMP r8, r0				;check r8 because that holds a value until you are done multiplying
	
	BEQ done_mul
	
	ADDS r14, r9, r14
	
	ADDCS r12, r12, r11

	ADD r12, r7, r12			;stored mul_sum + : first number to sum 2nd number number of times
	
	MOV r4, #0x01000000
	
check_overflow:
	
	CMP r12, r4				;check if it was incremented, if it was shift everything right 1 and add 1 to the front 
		
	BLT loopback
	
	;ORR r12, r12, r11			;ors r12(current sum) with 1 which leaves everythig but sets first bit to 1 and moves it to the front which accounts for overflow
	
	MOV r4, r7, LSL #31
	
	MOV r9, r9, LSR #1
	
	ADD r9, r9, r4
	
	MOV r4, r12, LSL #31
	
	MOV r14, r14, LSR #1
	
	ADD r14, r14, r4
	
	MOV r12, r12, LSR #1
	
	MOV r7, r7, LSR #1			; shifts the number you're adding the same amount to keep them aligned
	
	ADD r13, r13, r11			; counter above counts # of shifts over and subtract frm 23 and get difference at end, if difference add one to exponent
	
loopback:

	SUB r8, r8, r11				;# times decremented
	
	B mul_start

done_mul:
	
	CMP r12, r0  			;zero case again accounted for
	
	BNE check_mul_exp
	
	MOV r13, r0
	
	MOV r12, r0
	
	MOV r10, #127
	
check_mul_exp:

	MOV r2, #23

	SUB r2, r13, r2 			;checks difference between expected overflow and actual overflow, if difference. increase exponent by 1
	
	CMP r2, r0
	
	BLE mul_move_back
	
	ADD r10, r10, r11
	
mul_move_back:
	
	EOR r4, r4, r4				;moves to place and stores in memory

	;MOV r12, r12, LSR #6

	ADD r4, r4, r3

	MOV r4, r4, LSL #8

	ADD r4, r4, r10

	MOV r4, r4, LSL #23
	
	MOV r12, r12, LSL #9
	
	MOV r12, r12, LSR #9
	
	ADD r4, r4, r12
	
	LDR r14, =mul1and2 

	STR r4, [r14]

	LDR r1, =ieee1
	LDR r1, [r1]
	LDR r2, =ieee2
	LDR r2, [r2]

	FMSR s1, r1 		;@ move floating point operand 1 into s1
	FMSR s2, r2 		;@ move floating point operand 2 into s2
	FADDS s3, s1, s2	;@ add the floating point numbers. store result into s3
	FSUBS s4, s1, s2	;@ subtract s2 from s1. store result into s4 
	FMULS s5, s1, s2 	;@ perform floating point multiply. store result into s5
	FMRS r1, s3		;@ sum
	LDR	r14, =fpsum
	STR r1, [r14]
	FMRS r2, s4		;@ difference
	LDR	r14, =fpdiff
	STR r2, [r14]
	FMRS r3, s5		;@ product
	LDR	r14, =fpprod
	STR r3, [r14]
	
.data


num1_sign: 	.word 0
num2_sign: 	.word 0
num1_exp: 	.word 0
num2_exp:	.word 0
num1_mantissa: .word 0
num2_mantissa: .word 0
ieee1:	.word 0
ieee2:	.word 0
sum1and2:	.word 0
diff1and2:	.word 0
mul1and2:	.word 0
fpsum:	.word 0
fpdiff:	.word 0
fpprod:	.word 0
	
.end


