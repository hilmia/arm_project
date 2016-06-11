//CPSC 359 - Assignment 3 - RoadFighter
@  main.s
@  Kyle OStrander, Carlin Liu, Hilmi Abou-Saleh
@  Version - 0.4 (FINAL)
@  June 13 2016
@
@  Description -  Main file. Contains game loop, as well as game handling
@                 subroutines.
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

  //Screen to Black - Clear Screen
	ldr		r0, =0x0000
	bl		FillScreen


	bl		Print_Menu_Start


	bl		Menu_Controller
	cmp		r1, #0 // Check if quit was entered.

  //Start Game
  bleq Game_Loop

haltLoop$:
	b	haltLoop$


//Reset_Array - Moves default (unchanged) elements to GameArray
//Args: NONE
Reset_Array:
  push {r4 - r10, lr}

  //Initialize Variables
  element       .req r4
  defaultArray  .req r5
  changedArray  .req r6
  counter       .req r7

  ldr changedArray, =gameArray
  ldr defaultArray, =gameArray_default


  mov counter, #0

  //Start Loop
  reset_array_loop:
    ldr r8, =16000 //20*200*4 Size of Array
    cmp counter, r8
    beq done_reset

    //Load unchanged element and store it into the changed array
    ldr element, [defaultArray, counter]
    str element, [changedArray, counter]

    //Increment Variables and branch back
    add counter, #4
    b reset_array_loop

  done_reset:
    .unreq element
    .unreq defaultArray
    .unreq changedArray
    .unreq counter
    pop {r4 - r10, lr}
    mov pc, lr

//Reset_Game - Resets Array, and starts game again
//Args: NONE
.globl Reset_Game
Reset_Game:
  push {lr}
  //Reset Game
  bl Reset_Array
  //Screen to Black
  mov r0, #0
  bl FillScreen
  //Start Game Again
  bl Game_Loop

  pop {lr}
  mov pc, lr

//Restart_Game - Resets Array, and Goes to start menu
//Args: NONE
.globl Restart_Game
Restart_Game:
  push {lr}
  bl Reset_Array
  bl main
  pop {lr}
  mov pc, lr


//Game_Loop - Main Game Function.
//Args: NONE
.globl Game_Loop
Game_Loop:
  push {r4 - r10, lr}

  //Variable Init
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
  mov player, #11 //11 corresponds to player value in game array (see: GameLogic.s)

  //Start Game Initialization
  start_screen_init:
  bl Screen_Data_Init


  //Add Enemies and Fuel Trucks
  mov random_row_counter, #0

  addEnemy:
    cmp random_row_counter, #200 //200 is length of game
    bge addFuel_Init
    mov r0, random_row_counter
    mov r1, #10 //10 corresponds to an enemy unit
    bl  randomGen
    add random_row_counter, #5 //Places enemy every 5 places
    b addEnemy


  addFuel_Init:
    mov random_row_counter, #0
  addFuel:
    cmp random_row_counter, #200
    movge r9, #1
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
    sub temp_state, #80 //Every time, offset a row

    cmp counter, #200   //Time to finish line is 200 long
    beq end_game        //If hit, game is won

    mov r0, #12
    str r0, [temp_state] //Update Player Location

    //Display Information
    bl Screen_Data_Print


    //Update Game
    //Getting ready to update game
    mov r0, state
    mov r1, #1
    //If r9 = 1 then this is the first time the game is run, so print EVERYTHING
    //otherwise r9 = 0 meaning only update what has changed.
    cmp r9, #1
    bleq ArrayToScreen
    mov r9, #0
    //Update screen with changed only
    movne r0, state
    movne r1, #0
    blne ArrayToScreen

    //This loop waits for input to be read.
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
        ldr r2, [temp_state, #-84] //Loading (row + 1) - 4
        //If enemy
        cmp r2, #10
        beq update_game_for_enemy_hit

        //If fuel_vehicle
        cmp r2, #11
        bleq Screen_Data_Add

        //Replacing Existing Player
        mov r0, #5
        str r0, [temp_state, #84]
        sub temp_state, #4
        sub player, #1

        b update_game

      //Similar to above
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
        ldr r2, [temp_state, #-76] //Loading (row+1) +1

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

        cmp r2, #11 //Fuel Hit
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
        bleq Reset_Game

        b read_loop

    //An enemy has been hit
    update_game_for_enemy_hit:
      //Subtract Life
      mov r0, #1
      bl Screen_Data_Change

      //Subtract 10 fuel
      mov r0, #0
      mov r1, #10
      bl Screen_Data_Change

      //r9 = 11 - player (shift that needs to occur to replace player @ 11)
      rsb r9, player, #11
      mov r0, #12
      lsl r9, #2 //r9 * 4
      add temp_state, r9 //Update shift to state.
      str r0, [temp_state]

      b update_player

    update_game:
      //Check collision with Right Wall
      cmp player, #17
      //Update Life
      movge r0, #1
      blge  Screen_Data_Change
      //Update Fuel
      mov r0, #0
      mov r1, #10
      blge Screen_Data_Change
      //Move Player
      movge r0, #12
      subge temp_state, #24
      strge r0, [temp_state]

      bge update_player

      //Check collision with Left Wall
      cmp player, #4
      //No collision with left or right wall
      bgt finish_update
      //Update Life
      mov r0, #1
      bl  Screen_Data_Change
      //Update Fuel
      mov r0, #0
      mov r1, #10
      bl Screen_Data_Change
      //Move Player
      mov r0, #12
      add temp_state, #28
      str r0, [temp_state]


      update_player:
        mov player, #11

      finish_update:
        //Fill Lives/Fuel with Black (will be redrawn in a second)
        ldr r0, =0x0
        bl FillScreen_M
        //Subtract fuel
        mov r0, #0
        mov r1, #1
        bl Screen_Data_Change
        //One closer to victory and move player
        add counter, #1
        b gameState
  //GAME IS WON!
  end_game:
    //Print Message
    bl Game_Win
    //Get controller input
    bl Game_End_Menu
    //finished
    .unreq state
    .unreq counter

    .unreq temp_state
    .unreq player
    .unreq random_row_counter
    pop {r4 - r10, lr}
    mov pc, lr

.section .data















//
