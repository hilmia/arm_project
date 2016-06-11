.section .text



//r0 - start x
//r1 - start y
//r2 - address of picture
DrawBlock:
  push {r4 - r10, lr}

  row_start       .req r10
  column_start    .req r9
  picture_address .req r8

  column_counter  .req r4
  row_counter     .req r5

  column_end      .req r6
  row_end         .req r7

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

  big_draw_block:
    cmp column_counter, column_end
    beq done_draw_block

    add column_counter, #1

    mov row_counter, row_start
  start_draw_block:
    cmp row_counter, row_end
    beq big_draw_block

    mov r0, row_counter
    mov r1, column_counter
    ldrh r2, [picture_address], #2
    bl DrawPixel
    add row_counter, #1

    b start_draw_block

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
.globl ArrayToScreen
ArrayToScreen:
  push  {r3 - r10, lr}

  current_element  .req r4
  array            .req r5
  counter          .req r6
  row_counter      .req r10
  column_counter   .req r3
  current_picture  .req r7
  x                .req r8
  y                .req r9


  //Move array into local register
  mov   array, r0
  mov   counter, #0
  mov x, #32
  mov y, #0
  mov column_counter, #0

array_column_loop:

  cmp column_counter, #20
  beq done_array

  mov row_counter, #0
  add x, #32
  mov y, #192

  array_row_loop:

    cmp row_counter, #80
    addeq column_counter, #1
    beq array_column_loop
    //Load element of array
    ldr   current_element, [array, counter]

    cmp current_element, #13
    ldreq current_picture, =thirteen
    beq print_element

    cmp current_element, #14
    ldreq current_picture, =fourteen
    beq print_element

    cmp current_element, #1
    ldreq current_picture, =one
    beq print_element

    cmp current_element, #2
    ldreq current_picture, =two
    beq print_element

    cmp current_element, #5
    ldreq current_picture, =five
    beq print_element

    cmp current_element, #6
    ldreq current_picture, =six
    beq print_element

    cmp current_element, #7
    ldreq current_picture, =seven
    beq print_element

    cmp current_element, #8
    ldreq current_picture, =eight
    beq print_element

    cmp current_element, #9
    ldreq current_picture, =nine
    beq print_element

    cmp current_element, #12
    ldreq current_picture, =twelve
    beq print_element

    cmp current_element, #10
    ldreq current_picture, =ten
    beq print_element

    cmp current_element, #11
    ldreq current_picture, =eleven
    beq print_element

    cmp current_element, #0
    ldr current_picture, =zero



  //This section is where the optimizations are going to lie.
  //We need to check if block is the same and reprint.

  print_element:

    //First Time Program Runs
    //cmp column_counter, #
    //bgt do_element_print

    //mov r0, current_element
    //mov r1, array
    //bl checkPicture

    //cmp r0, #1
    //beq done_print_element

  do_element_print:
    mov r0, y
    mov r1, x
    mov r2, current_picture
    bl DrawBlock

  done_print_element:
    add y, #32
    add counter, #4
    add row_counter, #4

    b array_row_loop

  done_array:

    .unreq current_element
    .unreq array
    .unreq counter
    .unreq current_picture
    .unreq x
    .unreq y
    .unreq column_counter
    .unreq row_counter
    pop   {r3 - r10, lr}
    mov   pc, lr

checkPicture:
  push {r4 - r10, lr}
  mov r4, r0
  mov r5, r1
  ldr r6, [r5, #-80]
  cmp r4, r6
  moveq r0, #1
  movne r0, #0
  pop {r4 - r10, lr}
  mov pc, lr

//r0 - Contains colour to fill screen with
FillScreen:
  push {r4 - r10, lr}

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

    pop {r4 - r10, lr}
    mov pc, lr



/* Draw Pixel
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
