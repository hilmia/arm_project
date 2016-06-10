//Randomly generate locations for fuel and cars
//References: https://en.wikipedia.org/wiki/Xorshift
//Pass row into r0
//Pass in 11 or 15 into r1
.section .text
.align 4

.globl randomGen
randomGen:
	push	{r4-r10, lr}
	game_Array .req r10
	ldr game_Array, =gameArray

	mov r3, r0
	mov r0, #4000
	bl Wait

	mov r0, r3
	ldr		r4, = 0x3F003004	//address of CLO
	ldr		r5, [r4]		//read CLO, y (seed value)
	b:
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
	//mov 	r1, #12 % 10
hilms:

	mov   r2, r0
	lsl		r0, r0, #4		//r0 = r0*20

	lsl		r8, r2, #2
	add		r0, r8
	lsl 	r0, #2
	add		r0, r0, #16		//Offset for grass
	//lsl		r0, r0, #4		//Multiply by size
	lsl 	r7, #27
	lsr  	r7, #27
next1:
	cmp		r7, #2
	bgt		next2
	ldr game_Array, =gameArray
	str		r1, [game_Array, r0]
	b	done
next2:
	cmp		r7, #4
	bgt		next3
	ldr game_Array, =gameArray
	add r0, #4
	str		r1, [game_Array, r0]
	b	done
next3:
	cmp		r7, #6
	bgt		next4
	ldr game_Array, =gameArray
	add r0, #8
	str		r1, [game_Array, r0]
	b	done
next4:
	cmp		r7, #8
	bgt		next5
	ldr game_Array, =gameArray
	add r0, #12
	str		r1, [game_Array, r0]
	b	done
next5:
	cmp		r7, #10
	bgt		next6
	ldr game_Array, =gameArray
	add r0, #16
	str		r1, [game_Array, r0]
	b	done
next6:
	cmp		r7, #12
	bgt		next7
	ldr game_Array, =gameArray
	add r0, #20
	str		r1, [game_Array, r0]
	b	done
next7:
	cmp		r7, #14
	bgt		next8
	ldr game_Array, =gameArray
	add r0, #24
	str		r1, [game_Array, r0]
	b	done
next8:
	cmp		r7, #16
	bgt		next9
	ldr game_Array, =gameArray
	add r0, #28
	str		r1, [game_Array, r0]
	b	done
next9:
	cmp		r7, #20
	bgt		next10
	ldr game_Array, =gameArray
	add r0, #32
	str		r3, [game_Array, r0]
	b	done
next10:
	bgt		next11
	cmp		r7, #24
	ldr game_Array, =gameArray
	add r0, #36
	str		r1, [game_Array, r0]
	b	done
next11:
	cmp		r7, #28
	bgt		next12
	add r0, #40
	str		r1, [game_Array, r0]
	b	done
next12:
	cmp		r7, #32
	//bgt		done
	ldr game_Array, =gameArray
	add r0, #44
	str		r1, [game_Array, r0]
	b	done

done:
	pop		{r4-r10, lr}
	mov		pc, lr
