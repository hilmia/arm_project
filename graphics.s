
.section .text

//DrawBlock - Draws a 32x32 pixels starting at the passed in x and y coordinates
//Args: r0 - start x, r1 - start y, r2 - address of picture
DrawBlock:
  push {r4 - r10, lr}

  row_start       .req r10
  column_start    .req r9
  picture_address .req r8

  column_counter  .req r4
  row_counter     .req r5

  column_end      .req r6
  row_end         .req r7

  //Moving into non-scratch registers
  mov picture_address,   r2
  mov column_start,   r1
  mov row_start,  r0

  //row/column end = start + 32
  add row_end, row_start, #32
  add column_end, column_start, #32

  //column_counter = start -1 (because of preincrement)
  add column_counter, column_start, #-1
  //row_counter = start (ex. row_start = 0, row_counter = 0)
  mov row_counter,    row_start

  //Starts column counting, setting (resets once per column)
  big_draw_block:
    //Column Compare
    cmp column_counter, column_end
    beq done_draw_block

    add column_counter, #1

    mov row_counter, row_start
  start_draw_block:
    //Row Compare
    cmp row_counter, row_end
    beq big_draw_block
    //Do Print
    mov r0, row_counter
    mov r1, column_counter
    ldrh r2, [picture_address], #2
    bl DrawPixel
    //Go Back
    add row_counter, #1
    b start_draw_block

  //Uninitializing variables and finishing subroutine
  done_draw_block:
    .unreq column_counter
    .unreq row_counter
    .unreq row_start
    .unreq column_start
    .unreq row_end
    .unreq column_end
    .unreq picture_address
    pop {r4 - r10, lr}
    mov pc, lr





//r0 - address of array
//r1 - initialize (1), or reprint (0)

//ArrayToScreen - Fills screen based on Game Array
//Args: r0 - address of array, r1 - init_flag
//init_flag: 1 - Initialize (print everything), 0 - Reprint
.globl ArrayToScreen
ArrayToScreen:
  push  {r4 - r10, lr}

  current_element  .req r4
  array            .req r5
  counter          .req r6
  row_counter      .req r10
  column_counter   .req r7
  x                .req r8
  y                .req r9


  //Move array into local register
  mov   array, r0
  mov   counter, #0
  mov x, #32
  mov y, #0
  mov column_counter, #0

  //Store init flag
  ldr r0, =i_buffer
  str r1, [r0]

//Same Row/Column Loop concept as in DrawBlock
array_column_loop:
  cmp column_counter, #20 //20x20 is what is displayed on a turn
  beq done_array

  mov row_counter, #0
  add x, #32  //32 = Tile length
  mov y, #192 // offset by 6 tiles

  array_row_loop:
    //Loop through row
    cmp row_counter, #80 // 20x4 because word indexed
    addeq column_counter, #1
    beq array_column_loop

    //Load element of array
    ldr   current_element, [array, counter]

    //Goes through every known element and stores the "picture" in r2
    cmp current_element, #13
    ldreq r2, =thirteen
    beq print_element

    cmp current_element, #14
    ldreq r2, =fourteen
    beq print_element

    cmp current_element, #1
    ldreq r2, =one
    beq print_element

    cmp current_element, #2
    ldreq r2, =two
    beq print_element

    cmp current_element, #5
    ldreq r2, =five
    beq print_element

    cmp current_element, #6
    ldreq r2, =six
    beq print_element

    cmp current_element, #7
    ldreq r2, =seven
    beq print_element

    cmp current_element, #8
    ldreq r2, =eight
    beq print_element

    cmp current_element, #9
    ldreq r2, =nine
    beq print_element

    cmp current_element, #12
    ldreq r2, =twelve
    beq print_element

    cmp current_element, #10
    ldreq r2, =ten
    beq print_element

    cmp current_element, #11
    ldreq r2, =eleven
    beq print_element


    cmp current_element, #17
    ldreq r2, =finish
    beq print_element

    //Fall-Back, or grass
    cmp current_element, #0
    ldr r2, =zero

  //Section does actual printing of picture
  print_element:
    //Store picture into buffer
    ldr r1, =buffer
    str r2, [r1]

    //Loads initializing flag
    ldr r0, =i_buffer
    ldr r1, [r0]
    //If 1 initalize print, do not optimize, otherwise optimize.
    cmp r1, #1
    beq do_element_print

    //Check if picture is equal to that of the previous row
    mov r0, current_element
    mov r1, array
    bl checkPicture

    //If returns 1 then element @ row = row - 1, do not print
    cmp r0, #1
    beq done_print_element

  do_element_print:
    //Print Block
    //Load Picture
    ldr r1, =buffer
    ldr r2, [r1]

    mov r0, y
    mov r1, x
    bl DrawBlock

  //Increment Variables and Loop back
  done_print_element:
    add y, #32
    add counter, #4
    add row_counter, #4

    b array_row_loop

  //Uninitializing variables, and ending subroutine
  done_array:
    .unreq current_element
    .unreq array
    .unreq counter
    .unreq x
    .unreq y
    .unreq column_counter
    .unreq row_counter
    pop   {r4 - r10, lr}
    mov   pc, lr

//checkPicture -  Checks element at current position, and compares it to the one
//                at the row after. If they match, then no need to print, so
//                return r0 - 1
//Args: r0 - Current Element, r1 - Game Array,
//Return: r0 - If to update (0), or not (1).
checkPicture:
  push {r4 - r10, lr}
  //Move Variables into APCS compliant registers
  mov r4, r0
  mov r5, r1
  //Load element @ row + 1
  ldr r6, [r5, #-80]
  cmp r4, r6
  //Return Value
  moveq r0, #1
  movne r0, #0

  pop {r4 - r10, lr}
  mov pc, lr

//FillScreen - Fills the entire screen with the color passed into r0
//Args: r0 - Colour
FillScreen:
  push {r4 - r10, lr}
  //Init
  colour .req r10
  row_size .req r6
  column_size .req r7
  row_counter	.req	r4
  column_counter	.req	r5

  //Size of Screen
  mov row_size, #768
  mov column_size, #1024

  mov colour, r0
  //Offset because of preincremental counter
  mov row_counter, #-1

  //Goes in row major.
  fill_loop_row:
    //Checks if entire screen is printed, if so we are done
    cmp row_counter, row_size
    bge fill_done_block

    mov column_counter, #0
    add row_counter, #1


    fill_loop_column:
      cmp column_counter, column_size
      bge fill_loop_row

      //Prints pixel
      mov r2, colour
      mov r0, column_counter
      mov r1, row_counter
      bl DrawPixel

      //Increments Variables and loop back
      add column_counter, #1
      b fill_loop_column

  fill_done_block:
    .unreq row_size
    .unreq column_size
    .unreq row_counter
    .unreq column_counter

    pop {r4 - r10, lr}
    mov pc, lr



/* Draw Pixel - Provided by CPSC 359 A3 Specs
 *  r0 - x
 *  r1 - y
 *  r2 - color
 */
DrawPixel:
	push	{r0, r1, r2, r4, lr}


	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset

	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0]
	strh	r2, [r0, offset]

  .unreq offset
	pop		{r0, r1, r2, r4, lr}
	mov pc, lr



.section .data

//Small Buffers used in ArrayToScreen (Cannot use more that r4 - r10)
buffer:
  .rept 32
  .byte 0
  .endr

i_buffer:
  .rept 32
  .byte 0
  .endr
