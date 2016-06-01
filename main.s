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
	//cmp		r1, #0

	cmp		r1, #1
	bleq		haltLoop$
	

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

.section .data  















//

