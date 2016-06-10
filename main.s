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


End_Game_Loop:
  push {r4, lr}
  mov r0, #0

  bleq Game_End_Menu
  pop {r4, lr}
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
    beq addFuel_Init
    mov r0, random_row_counter
    mov r1, #10
    bl  randomGen
    add random_row_counter, #10
    b addEnemy


  addFuel_Init:
    mov random_row_counter, #0
  addFuel:
    cmp random_row_counter, #200
    beq gameState
    mov r0, random_row_counter
    mov r1, #11
    bl randomGen
    add random_row_counter, #20
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

        moveq r0, #1
        bleq Screen_Data_Change

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
        moveq r0, #1
        bleq Screen_Data_Change

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

        cmp r2, #10
        moveq r0, #1
        bleq Screen_Data_Change

        cmp r2, #11
        bleq Screen_Data_Add

        mov r0, #5
        str r0, [temp_state, #80]

        b update_game

      g_select_button:
        ldr  r1, =0xFFFB
        cmp  r0, r1
        beq  _start

      g_start_button:
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
      mov r10, r0
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
      mov r10, r0
      mov r0, #12
      add temp_state, #28
      str r0, [temp_state]


      update_player:
        mov player, #11

      finish_update:
        cmp r10, #1
        bleq End_Game_Loop

        ldr r0, =0x0
        bl FillScreen_M
        mov r0, #0
        bl Screen_Data_Change
        add counter, #1

        b gameState


  end_game:
    ldr r0, =0x0
    //bl FillScreen
    .unreq state
    .unreq counter

    .unreq temp_state
    .unreq player
    .unreq random_row_counter
    pop {r4 - r10, lr}
    mov pc, lr





.section .data















//
