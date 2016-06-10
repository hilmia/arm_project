//CPSC 359 - Assignment 3 - RoadFighter - xor.s
//Kyle Ostrander 10128524, Carlin Liu 10123584, Hilmi Abou-Saleh 10125373

//xor.s
//Functions:
//randomGen
//References: https://en.wikipedia.org/wiki/Xorshift
 
//Randomly generate locations for fuel and cars using an xor shift random number generator

//randomGen
//Args: r0 (row), r1 (10 or 11 to indicated fuel of enemy car)
//Returns: nothing, changes game array in the function
.section .text
.align 4

.globl randomGen
randomGen:
	push	{r4-r10, lr}
	game_Array .req r10
	ldr game_Array, =gameArray
	//Initialize constants for xor shift algorithm
	ldr		r4, = 0x3F003004	//address of CLO
	ldr		r5, [r4]		//read CLO, y
	ldr	 	r4, =0x72E1		//x
	ldr		r6, =0x3		//z
	lsr		r7, r5, #10		//w
	mov		r8, r4			//t = x
	lsl		r9, r8, #11		//t = t xor t << 11
	eor		r8, r9
	//Generate random number
	mov		r4, r5			//x = y
	mov		r5, r6			//y = z
	mov		r6, r7			//z = w
	lsr		r9, r7, #19		//w = w xor w >> 19
	eor		r7, r9
	eor		r7, r8			//w = w xor t
	
	//Generate offset to change tile in the game array
	lsl		r0, r0, #4		//r0 = r0*20
	lsl		r8, r0, #2
	add		r0, r8, #4
	add		r0, r0, #6		//Offset for grass
	lsl		r0, r0, #4		//Multiply by size

	//Put Fuel or Enemy Car in game based on random number generatored
next1:
	ldr r1, =61000000
	cmp		r7, r1
	bgt		next2
	str		r1, [game_Array, r0]
next2:
	ldr r1, =61050000
	cmp		r7, r1
	bgt		next3
	str		r1, [game_Array, r0]
next3:
	ldr r1, =61200000
	cmp		r7, r1
	bgt		next4
	str		r1, [game_Array, r0]
next4:
	ldr r1, =61250000
	cmp		r7, r1
	bgt		next5
	str		r1, [game_Array, r0]
next5:
	ldr r1, =61300000
	cmp		r7, r1
	bgt		next6
	str		r1, [game_Array, r0]
next6:
	ldr r1, =61350000
	cmp		r7, r1
	bgt		next7
	str		r1, [game_Array, r0]
next7:
	ldr r1, =6140000
	cmp		r7, r1
	bgt		next8
	str		r1, [game_Array, r0]
next8:
	ldr r1, =61450000
	cmp		r7, r1
	bgt		next9
	str		r1, [game_Array, r0]
next9:
	ldr r1, =61550000
	cmp		r7, r1
	bgt		next10
	str		r1, [game_Array, r0]
next10:
	ldr r1, =61600000
	cmp		r7, r1
	bgt		next10
	str		r1, [game_Array, r0]
next11:
	ldr r1, =61650000
	cmp		r7, r1
	bgt		next12
	str		r1, [game_Array, r0]
next12:
	ldr r1, =61700000
	cmp		r7, r1
	bgt		done
	str		r1, [game_Array, r0]

done:
	pop		{r4-r10, lr}
	mov		pc, lr
