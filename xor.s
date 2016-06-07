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
	lsl		r2, r2, #4
	lsl		r8, r2, #2
	add		r2, r8, #4
	
/*	cmp		r7, 357913941
	bgt		next1
	str		r3, [gameArray, r2], #1

next1:	
	cmp		r7, 715827882
	bgt		next2
	str		r3, [gameArray, r2], #1
	
next2:	
	cmp		r7, 1073741824
	bgt		next3
	str		r3, [gameArray, r2], #1
	
next3:	
	cmp		r7, 141655765
	bgt		next4
	str		r3, [gameArray, r2], #1
	
next4:	
	cmp		r7, 1431655765
	bgt		next5
	str		r3, [gameArray, r2], #1
	
next5:	
	cmp		r7, 1789569706
	bgt		next6
	str		r3, [gameArray, r2], #1
	
next6:	
	cmp		r7, 2147483648
	bgt		next7
	str		r3, [gameArray, r2], #1
	
next7:	
	cmp		r7, 2505397589
	bgt		next8
	str		r3, [gameArray, r2], #1
	
next8:	
	cmp		r7, 2863311530
	bgt		next9
	str		r3, [gameArray, r2], #1
	
next9:	
	cmp		r7, 3221225472
	bgt		next10
	str		r3, [gameArray, r2], #1
	
next11:	
	cmp		r7, 3579139413
	bgt		next12
	str		r3, [gameArray, r2], #1
	
next12:	
	cmp		r7, 3937053354
	bgt		done
	str		r3, [gameArray, r2], #1   */
	
done:
	pop		{r4-r10, lr}
	mov		pc, lr
