//Randomly generate locations for fuel and cars
//References: https://en.wikipedia.org/wiki/Xorshift
//Pass row into r2
//Pass in 10 or 11 into r3
.section .text
.align 4

.globl randomGen
randomGen:	
	push	{r4-r10, lr}
kylethebum:
	ldr		r4, = 0x3F003004	//address of CLO
	ldr		r5, [r4]		//read CLO, y	
	ldr	 	r4, =0x72E1		//x
	ldr		r6, =0x3		//z
	lsr		r7, r5, #10		//w
	mov		r8, r4			//t = x
	lsl		r9, r8, #11		//t = t xor t << 11
	eor		r8, r9

	mov		r4, r5			//x = y
	mov		r5, r6			//y = z
	mov		r6, r7			//z = w
	lsr		r9, r7, #19		//w = w xor w >> 19
	eor		r7, r9
	eor		r7, r8			//w = w xor t
hilms:
	lsl		r2, r2, #4		//r2 = r2*20
	lsl		r8, r2, #2
	add		r2, r8, #4
	add		r2, r2, #6		//Offset for grass 
	lsl		r2, r2, #4		//Multiply by size

next1:	
	cmp		r7, 61000000
	bgt		next2
	str		r3, [gameArray, r2]	
next2:	
	cmp		r7, 61050000
	bgt		next3
	str		r3, [gameArray, r2]	
next3:	
	cmp		r7, 61200000
	bgt		next4
	str		r3, [gameArray, r2]	
next4:	
	cmp		r7, 61250000
	bgt		next5
	str		r3, [gameArray, r2]	
next5:	
	cmp		r7, 61300000
	bgt		next6
	str		r3, [gameArray, r2]	
next6:	
	cmp		r7, 61350000
	bgt		next7
	str		r3, [gameArray, r2]	
next7:	
	cmp		r7, 6140000
	bgt		next8
	str		r3, [gameArray, r2]	
next8:	
	cmp		r7, 61450000
	bgt		next9
	str		r3, [gameArray, r2]	
next9:	
	cmp		r7, 61550000
	bgt		next10
	str		r3, [gameArray, r2]	
next11:	
	cmp		r7, 61600000
	bgt		next12
	str		r3, [gameArray, r2]	
next12:	
	cmp		r7, 61650000
	bgt		done
	str		r3, [gameArray, r2] */
	
done:
	pop		{r4-r10, lr}
	mov		pc, lr
