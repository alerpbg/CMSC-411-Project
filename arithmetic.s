@ FIR Filter
@ Properly converts hexadecimal number to IEEE 754
@ Properly adds IEEE 754 numbers
@ Updates exponent after addition
@ Stores final sum in R3

	.text

	.global _start

_start:
	

ValueBreakdown:

	LDR r1, =0x41b48f5c

	LDR r2, =0x41dcf5c3

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
	
	;AND r4, r8, r11 			;shifts everything right to get rid of trailing zeros

	;CMP r4, r11 
	
	;BEQ mul_start
	
	;MOV r8, r8, LSR #1
	
	;SUB r2, r2, r11
	
	;B mul_dec_setup
	
	MOV r8, r8, LSR #6
	
	MOV r7, r7, LSR #6
	
	EOR r9, r9, r9
	
	EOR r14, r14, r14
	
	EOR r13, r13, r13
	
mul_start:
	
	CMP r8, r0				;check r8 because that holds a value until you are done multiplying
	
	BEQ done_mul
	
	;ADD r9, r9, r14

	ADD r12, r7, r12			;stored mul_sum + : first number to sum 2nd number number of times
	
	MOV r4, #0x01000000
	
	;CMP r9, r4
	
	;BLT check_overflow
	
	;SUB r9, r9, r4
	
	;ADD r12, r12, r11
	
check_overflow:
	
	;CMP r12, r4				;check if it was incremented, if it was shift everything right 1 and add 1 to the front 
		
	;BLT loopback
	
	;ORR r12, r12, r11			;ors r12(current sum) with 1 which leaves everythig but sets first bit to 1 and moves it to the front which accounts for overflow
	
	;AND r4, r7, r11
	
	;MOV r4, r4, LSL #24
	
	;ADD r9, r9, r4
	
	;MOV r9, r9, LSR #1
	
	;AND r4, r12, r11
	
	;MOV r4, r4, LSL #24
	
	;ADD r14, r14, r4
	
	;MOV r14, r14, LSR #1
	
	CMP r12, r4
	
	BLT loopback
	
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

	MOV r2, #24

	SUB r2, r13, r2 			;checks difference between expected overflow and actual overflow, if difference. increase exponent by 1
	
	ADD r10, r10, r2
	
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
	

	.data



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