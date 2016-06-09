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
	//cmp		r1, #1
	//bleq		haltLoop$


	//bl		mainSNES

	//Quit game
	//Initialize game
	//Play Game
	///In game menu
	///Drive Car
	///Modify lives
	///Car death
	///Modify fuel
	///End game

haltLoop$:
	b	haltLoop$

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

  //Insert Random

  start_screen_init:
  bl Screen_Data_Init


  //Start Loop
  gameState:
    sub state, #80 //Offset by row  (20x4)

    //Update Location

    sub temp_state, #80

    cmp counter, #400
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
      //Controller Input:
      //dpadleft & A
        ldr	r1, =0xFEBF
        cmp	r0, r1
        moveq r0, #5
        streq r0, [temp_state, #84]
        subeq temp_state, #4
        subeq player, #1
        beq update_game
    	//dpadleft
       	ldr	r1, =0xFFBF
      	cmp	r0, r1
        moveq r0, #5
        streq r0, [temp_state, #84]
        subeq temp_state, #4
        subeq player, #1
        beq update_game
        //Check for Collision
        //Update Fuel
        //Update Lives
        //Update Position if game state not finished
        //beq	dpadup_Menu
      //dpadright & A
      	ldr	r1, =0xFE7F
        cmp	r0, r1
        moveq r0, #5
        streq r0, [temp_state, #76]
        addeq temp_state, #4
        addeq player, #1
        beq update_game


    	//dpadright:
      	ldr	r1, =0xFF7F
        cmp	r0, r1
        moveq r0, #5
        streq r0, [temp_state, #76]
        addeq temp_state, #4
        addeq player, #1
        beq update_game
        //Check for Collision
        //Update Lives
      	//beq	dpaddown_Menu

    	//A_button:
      	ldr	r1, =0xFEFF
      	cmp	r0, r1
        moveq r0, #5
        streq r0, [temp_state, #80]
        //Update Fuel
        //Check for Collision
      	beq	update_game

      //Select_button:
        ldr  r1, =0xFFFB
        cmp  r0, r1
        beq  _start

      //Start_button:
        ldr r1, =0xFFF7
        cmp r0, r1
        moveq r0, #5
        streq r0, [temp_state]

        ldreq r0, =0x0
        bleq FillScreen

        beq Game_Loop

        b read_loop

    update_game:
      //Check collision with Right Wall
      cmp player, #17
      movge r0, #1
      blge  Screen_Data_Change

      movge r0, #12
      subge temp_state, #24
      strge r0, [temp_state]

      bge update_player

      //Check collision with Left Wall
      break:
      cmp player, #4
      //No collision with left or right wall
      bgt finish_update

      mov r0, #1
      bl  Screen_Data_Change

      mov r0, #12
      add temp_state, #28
      str r0, [temp_state]


      update_player:
        mov player, #11

      finish_update:
        ldr r0, =0x0
        bl FillScreen_M
        mov r0, #0
        bl Screen_Data_Change
        add counter, #1
        b gameState

  end_game:
    ldr r0, =0x0
    bl FillScreen
    .unreq state
    .unreq counter

    .unreq temp_state
    .unreq player
    .unreq random_row_counter
    pop {r4 - r10, lr}
    mov pc, lr

.section .data















//
