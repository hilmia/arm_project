//CPSC 359 - Assignment 3 - RoadFighter
//Kyle Ostrander 10128524, Carlin Liu 10123584, Hilmi Abou-Saleh 10125373
//

.section    .init
.globl     _start


_start:
    b       main

.section .text

main:
    	mov     	sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG // Enable JTAG
	bl		InitUART    // Initialize the UART


	bl		InitFrameBuffer
	bl		Init_GPIO


	ldr		r0, =0x0000
	bl		FillScreen

	bl		Print_Menu_Start

	bl		Menu_Controller
	cmp		r1, #0
  bleq Game_Loop

haltLoop$:
	b	haltLoop$


//Moves Default array elements to GameArray
Reset_Array:
  push {r4 - r10, lr}

  element       .req r4
  defaultArray  .req r5
  changedArray  .req r6
  counter       .req r7

  ldr changedArray, =gameArray
  ldr defaultArray, =gameArray_default

  mov counter, #0

  reset_array_loop:
  ldr r8, =16000
  cmp counter, r8
  beq done_reset

  ldr element, [defaultArray, counter]
  str element, [changedArray, counter]

  add counter, #4
  b reset_array_loop

  done_reset:
  .unreq element
  .unreq defaultArray
  .unreq changedArray
  .unreq counter
  pop {r4 - r10, lr}
  mov pc, lr

.globl Reset_Game
Reset_Game:
  push {lr}
  bl Reset_Array
  mov r0, #0
  bl FillScreen
  bl Game_Loop
  pop {lr}
  mov pc, lr


.globl Restart_Game
Restart_Game:
  push {lr}
  bl Reset_Array
  bl main
  pop {lr}
  mov pc, lr



.globl Game_Loop
Game_Loop:
  push {r4 - r10, lr}

  state       .req r4
  counter     .req r5
  temp_state  .req r6
  player      .req r7
  random_row_counter .req r8

  ldr state, =gameArrayEnd
  sub state, #1520 //Offset to fill entire screen

  ldr temp_state, =gameArrayEnd
  add temp_state, #40 //Offset to middle of row.

  mov counter, #0
  mov player, #11

  start_screen_init:
  bl Screen_Data_Init


  //Add Enemies and Fuel Trucks
  mov random_row_counter, #0

  addEnemy:
    cmp random_row_counter, #200
    bge addFuel_Init
    mov r0, random_row_counter
    mov r1, #10
    bl  randomGen
    add random_row_counter, #5
    b addEnemy


  addFuel_Init:
    mov random_row_counter, #0
  addFuel:
    cmp random_row_counter, #200
    bge gameState
    mov r0, random_row_counter
    mov r1, #11
    bl randomGen
    add random_row_counter, #15
    b addFuel



  //Start Loop
  gameState:
    sub state, #80 //Offset by row  (20x4)

    //Update Location

    sub temp_state, #80

    cmp counter, #200
    beq end_game

    mov r0, #12
    str r0, [temp_state]

    //Display Information:

    bl Screen_Data_Print

    //Update Game
    mov r0, state
    bl ArrayToScreen

    read_loop:
      bl Read_Data

      //no input
    	ldr     r1, =0xFFFF
    	cmp     r0, r1
      beq read_loop

      //dpadleft & A
        ldr	r1, =0xFEBF
        cmp	r0, r1
        beq g_dpadleft

       	ldr	r1, =0xFFBF
      	cmp	r0, r1
        bne g_dpadrightA

      g_dpadleft:

        //Check Fuel or Enemy
        ldr r2, [temp_state, #-84]

        cmp r2, #10
        beq update_game_for_enemy_hit


        cmp r2, #11
        bleq Screen_Data_Add


        mov r0, #5
        str r0, [temp_state, #84]
        sub temp_state, #4
        sub player, #1

        b update_game


      g_dpadrightA:
      	ldr	r1, =0xFE7F
        cmp	r0, r1
        beq g_dpadright

        //dpadright with no A
      	ldr	r1, =0xFF7F
        cmp	r0, r1
        bne g_a_button
      g_dpadright:
        //Check Fuel or Enemy
        ldr r2, [temp_state, #-76]

        cmp r2, #10
        beq update_game_for_enemy_hit

        cmp r2, #11
        bleq Screen_Data_Add

        mov r0, #5
        str r0, [temp_state, #76]
        add temp_state, #4
        add player, #1

        b update_game

    	g_a_button:
      	ldr	r1, =0xFEFF
      	cmp	r0, r1
        bne g_select_button

        //Check Fuel or Enemy
        ldr r2, [temp_state, #-80]

        cmp r2, #10 //Enemy Hit
        beq update_game_for_enemy_hit

        cmp r2, #11
        bleq Screen_Data_Add

        mov r0, #5
        str r0, [temp_state, #80]

        b update_game

      g_select_button:
        ldr  r1, =0xFFFB
        cmp  r0, r1
        beq  Restart_Game

      g_start_button:
        ldr r1, =0xFFF7
        cmp r0, r1
        moveq r0, #5
        streq r0, [temp_state]

        ldreq r0, =0x0
        bleq FillScreen
        bleq Reset_Game

        b read_loop

    update_game_for_enemy_hit:
      mov r0, #1
      bl Screen_Data_Change

      mov r0, #0
      mov r1, #10
      bl Screen_Data_Change

      rsb r9, player, #11
      mov r0, #12
      lsl r9, #2 //r9 * 4
      add temp_state, r9
      str r0, [temp_state]

      b update_player

    update_game:
      //Check collision with Right Wall
      cmp player, #17
      movge r0, #1
      blge  Screen_Data_Change
      mov r0, #0
      mov r1, #10
      blge Screen_Data_Change
      movge r0, #12
      subge temp_state, #24
      strge r0, [temp_state]

      bge update_player

      //Check collision with Left Wall
      cmp player, #4
      //No collision with left or right wall
      bgt finish_update

      mov r0, #1
      bl  Screen_Data_Change
      mov r0, #0
      mov r1, #10
      bl Screen_Data_Change
      mov r0, #12
      add temp_state, #28
      str r0, [temp_state]


      update_player:
        mov player, #11

      finish_update:

        ldr r0, =0x0
        bl FillScreen_M
        mov r0, #0
        mov r1, #1
        bl Screen_Data_Change
        add counter, #1

        b gameState


  end_game:
    bl Game_Win
    bl Game_End_Menu

    .unreq state
    .unreq counter

    .unreq temp_state
    .unreq player
    .unreq random_row_counter
    pop {r4 - r10, lr}
    mov pc, lr





.section .data















//
