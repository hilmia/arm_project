//
.section .text
.align 4

/* Draw Pixel
 *  r0 - x
 *  r1 - y
 *  r2 - color
 */

DrawPixel:
	push	{r4}


	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset

	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0]
	strh	r2, [r0, offset]

	pop		{r4}
	bx		lr


//
//Draw_Char
//Code Taken from Tutorial08 and modified
//r0 = x value
//r1 = y value
//r2 = colour of text
//r3 = character to be drawn

.globl Draw_Char
Draw_Char:
	push	{r4-r10, lr}

	chAdr	.req	r4
	px	.req	r5
	py	.req	r6
	row	.req	r7
	mask	.req	r8
	colour	.req	r9
	pxINIT	.req	r10

	ldr	chAdr, =font		// load the address of the font map
	add	chAdr, r3, lsl #4	// char address = font base + (char * 16)

	mov	colour, r2
	mov	py, r1			// init the Y coordinate (pixel coordinate)
	mov	pxINIT,	r0

charLoop$:
	mov	px, pxINIT			// init the X coordinate

	mov	mask, #0x01		// set the bitmask to 1 in the LSB
	
	ldrb	row, [chAdr], #1	// load the row byte, post increment chAdr

rowLoop$:
	tst	row, mask		// test row byte against the bitmask
	beq	noPixel$

	mov	r0, px
	mov	r1, py
	mov	r2, colour
	bl	DrawPixel		// draw r2 coloured pixel at (px, py)

noPixel$:
	add	px, #1			// increment x coordinate by 1
	lsl	mask, #1			// shift bitmask left by 1

	tst	mask, #0x100		// test if the bitmask has shifted 8 times (test 9th bit)
	beq	rowLoop$

	add	py, #1			// increment y coordinate by 1

	tst	chAdr, #0xF
	bne	charLoop$		// loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)


	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask
	.unreq	colour
	.unreq	pxINIT

	pop	{r4-r10, lr}
	mov	pc, lr

//Draw_String
//r0 = x
//r1 = y
//r2 = colour
//r3 = address of string -> .asciz

.globl Draw_String
Draw_String:
	push 	{r4-r10, lr}	//*******do we push before or after .req

	senAdr	.req	r4
	px	.req	r5
	py	.req	r6
	colour	.req	r7


	mov	px, r0
	mov	py, r1
	mov	colour, r2
	mov	senAdr, r3

	mov	r8, #0	//index = 0

	ldrb	r9, [senAdr]

Draw_String_Loop:
	mov	r0, px
	mov	r1, py
	mov	r2, colour
	mov	r3, r9
	bl	Draw_Char

	add	r8, #1			//increment index
	add	px, #10			//*******increment spacing for letters*******CHANGE SPACING HERE

	ldrb	r9, [senAdr, r8] 	//load next letter in string
	
	cmp	r9, #0			//compare to /0
	bne	Draw_String_Loop
	
Draw_String_Loop_Done:
	.unreq	senAdr
	.unreq	px
	.unreq	py
	.unreq	colour	

	pop 	{r4-r10, lr}
	mov	pc, lr


//r0 - Contains colour to fill screen with
.globl FillScreen
FillScreen:
  push {r4-r10, lr}

  colour .req r10
  row_size .req r6
  column_size .req r7
  row_counter	.req	r4
  column_counter	.req	r5


  mov row_size, #768
  mov column_size, #1024

  mov colour, r0

  mov row_counter, #-1

  fill_loop_row:
    cmp row_counter, row_size
    bge fill_done_block

    mov column_counter, #0
    add row_counter, #1


    fill_loop_column:
      cmp column_counter, column_size
      bge fill_loop_row

      mov r2, colour
      mov r0, column_counter
      mov r1, row_counter
      bl DrawPixel

      add column_counter, #1
      b fill_loop_column

  fill_done_block:
    .unreq row_size
    .unreq column_size
    .unreq row_counter
    .unreq column_counter

    pop {r4-r10, lr}
    mov pc, lr

/////////////////////////////////////////////////////////////////////////////////////
/* Draw the character 'B' to (0,0)
 */
//r2 = colour
.globl DrawCharB
DrawCharB:
	push	{r4-r8, lr}

	chAdr	.req	r4
	px		.req	r5
	py		.req	r6
	row		.req	r7
	mask	.req	r8

	ldr		chAdr,	=font		// load the address of the font map
	mov		r0,		#'B'		// load the character into r0
	add		chAdr,	r0, lsl #4	// char address = font base + (char * 16)

	mov		py,		#0			// init the Y coordinate (pixel coordinate)

charLoop$$:
	mov		px,		#0			// init the X coordinate

	mov		mask,	#0x01		// set the bitmask to 1 in the LSB
	
	ldrb	row,	[chAdr], #1	// load the row byte, post increment chAdr

rowLoop$$:
	tst		row,	mask		// test row byte against the bitmask
	beq		noPixel$$

	mov		r0,		px
	mov		r1,		py
	mov		r2,		r2	// **********************red = #0xF800	
	bl		DrawPixel			// draw red pixel at (px, py)

noPixel$$:
	add		px,		#1			// increment x coordinate by 1
	lsl		mask,	#1			// shift bitmask left by 1

	tst		mask,	#0x100		// test if the bitmask has shifted 8 times (test 9th bit)
	beq		rowLoop$$

	add		py,		#1			// increment y coordinate by 1

	tst		chAdr,	#0xF
	bne		charLoop$$		// loop back to charLoop$$, unless address evenly divisibly by 16 (ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask

	pop		{r4-r8, pc}

///////////////////////////////////////////////////////////////////////////////////////


.section .data
.align 4


//
font:
	.incbin "font.bin"


