//CPSC 359 - Assignment 3 - RoadFighter - menu.s
//Kyle Ostrander 10128524, Carlin Liu 10123584, Hilmi Abou-Saleh 10125373
 
//Menu.s
//Functions:
//Print_Menu_Start, Print_Menu_Quit, Print_Menu_Black_Start, Print_Menu_Black_Quit
//Print_Menu_Starting_Game, Print_Menu_Quitting_Game, Menu_Controller, Game_End_Menu
//Game_Over, Game_Win


.section .text
.align 4


//Print_Menu_Start
//Args: None
//Return: None
//This function sets the location and colours to print out the strings for game name etc.
//This function will print <> around the start.
.globl Print_Menu_Start
Print_Menu_Start:
	push	{r4-r10, lr}

	//Game_Name
	mov	r0, #100
	mov	r1, #100
	ldr	r2, =0x0FF0
	ldr	r3, =Game_Name
	bl	Draw_String

	//Creator_Names
	mov	r0, #100
	mov	r1, #300
	ldr	r2, =0x0FF0
	ldr	r3, =Creator_Names
	bl	Draw_String

	//Main_Menu
	mov	r0, #500
	mov	r1, #500
	ldr	r2, =0x0FF0
	ldr	r3, =Main_Menu
	bl	Draw_String

	//Start_Game
	mov	r0, #500
	mov	r1, #600
	ldr	r2, =0x0FF0
	ldr	r3, =Start_Game_Selected
	bl	Draw_String

	//Quit_Game
	mov	r0, #500
	mov	r1, #700
	ldr	r2, =0x0FF0
	ldr	r3, =Quit_Game
	bl	Draw_String


	pop	{r4-r10, lr}
	mov	pc, lr


//Print_Menu_Quit
//Args: None
//Return: None
//This function sets the location and colours to print out the strings for game name etc.
//This function will print <> around the Quit.
.globl Print_Menu_Quit
Print_Menu_Quit:
	push	{r4-r10, lr}

	//Game_Name
	mov	r0, #100
	mov	r1, #100
	ldr	r2, =0x0F00
	ldr	r3, =Game_Name
	bl	Draw_String

	//Creator_Names
	mov	r0, #100
	mov	r1, #300
	ldr	r2, =0x0F00
	ldr	r3, =Creator_Names
	bl	Draw_String

	//Main_Menu
	mov	r0, #500
	mov	r1, #500
	ldr	r2, =0x0F00
	ldr	r3, =Main_Menu
	bl	Draw_String

	//Start_Game
	mov	r0, #500
	mov	r1, #600
	ldr	r2, =0x0F00
	ldr	r3, =Start_Game
	bl	Draw_String

	//Quit_Game
	mov	r0, #500
	mov	r1, #700
	ldr	r2, =0x0F00
	ldr	r3, =Quit_Game_Selected
	bl	Draw_String


	pop	{r4-r10, lr}
	mov	pc, lr


//Print_Menu_Black_Start
//Args: None
//Return: None
//This function Changes the options of <Start> and quit to be black
.globl Print_Menu_Black_Start
Print_Menu_Black_Start:
	push	{r4-r10, lr}

	//Start_Game
	mov	r0, #500
	mov	r1, #600
	ldr	r2, =0x0000
	ldr	r3, =Start_Game_Selected
	bl	Draw_String

	//Quit_Game
	mov	r0, #500
	mov	r1, #700
	ldr	r2, =0x0000
	ldr	r3, =Quit_Game
	bl	Draw_String


	pop	{r4-r10, lr}
	mov	pc, lr

//Print_Menu_Black_Quit
//Args: None
//Return: None
//This function Changes the options of <quit> and start to be black
.globl Print_Menu_Black_Quit
Print_Menu_Black_Quit:
	push	{r4-r10, lr}

	//Start_Game
	mov	r0, #500
	mov	r1, #600
	ldr	r2, =0x0000
	ldr	r3, =Start_Game
	bl	Draw_String

	//Quit_Game
	mov	r0, #500
	mov	r1, #700
	ldr	r2, =0x0000
	ldr	r3, =Quit_Game_Selected
	bl	Draw_String


	pop	{r4-r10, lr}
	mov	pc, lr

//Print_Menu_Starting_Game
//Args: None
//Return: None
//This function prints out the Starting_Game string
.globl Print_Menu_Starting_Game
Print_Menu_Starting_Game:
	push	{r4-r10, lr}

	ldr	r2, =0x0F00	//Test B
	bl	DrawCharB

	//Starting Game
	mov	r0, #500
	mov	r1, #600
	ldr	r2, =0x0F00
	ldr	r3, =Starting_Game
	bl	Draw_String

	ldr	r0, =0x0000
	bl	FillScreen

	pop	{r4-r10, lr}
	mov	pc, lr

//Print_Menu_Quitting_Game
//Args: None
//Return: None
//This function prints out the Quitting_Game string
.globl Print_Menu_Quitting_Game
Print_Menu_Quitting_Game:
	push	{r4-r10, lr}

	ldr	r2, =0x0F00	//Test B
	bl	DrawCharB

	//Quitting Game
	mov	r0, #500
	mov	r1, #600
	ldr	r2, =0xFFFF
	ldr	r3, =Quitting_Game
	bl	Draw_String
	
	ldr	r0, =0x0000
	bl	FillScreen

	pop	{r4-r10, lr}
	mov	pc, lr


//Menu_Controller
//Args: r4 = start/quit flag 0 = START, 1 = QUIT
//Return: r1 = start/quit return flag 0 = START, 1 = QUIT
//This function determines which button is pressed on the main menu screen. 
//The function runs on a loop waiting on input. When input is entered, it will
//be compared to up,down etc. Based on the flag it will determine what to print
//to the screen.
.globl Menu_Controller
Menu_Controller:
	push	{r4-r10, lr}
	mov	r4, #0

Menu_Wait:
	bl	Read_Data			//read in data

	//no input
	ldr     r1, =0xFFFF		
    	cmp     r0, r1
    	beq     Menu_Wait

	//dpadup
   	ldr	r1, =0xFFEF		
    	cmp	r0, r1
	beq	dpadup_Menu
	
	//dpaddown_button:
	ldr	r1, =0xFFDF
	cmp	r0, r1
	beq	dpaddown_Menu

	//A_button:
	ldr	r1, =0xFEFF
	cmp	r0, r1
	beq	A_Menu

	b	Menu_Wait

dpadup_Menu:
	ldr	r2, =0x0FF0			//draw test B
	bl	DrawCharB

	cmp	r4, #0				//Check if flag 0
	beq	Menu_Wait			//if 0, up does nothing

	cmp	r4, #1				//if 1, make <quit> black
	bleq	Print_Menu_Black_Quit

	cmp	r4, #1				//if 1, print <start>
	bleq	Print_Menu_Start
	
	moveq	r4, #0				//set flag to 0
	b	Menu_Wait

dpaddown_Menu:
	ldr	r2, =0xF0F0			//draw test B	
	bl	DrawCharB

	cmp	r4, #1				//Check if flag 1
	beq	Menu_Wait			//if 1, down does nothing

	cmp	r4, #0				//if 0, make <start> black
	bleq	Print_Menu_Black_Start

	cmp	r4, #0				//if 0, print <quit>
	bleq	Print_Menu_Quit	

	moveq	r4, #1				//set flag to 0
	b	Menu_Wait

A_Menu:	
	ldr	r2, =0xFFFF			//draw test B	
	bl	DrawCharB

	bl	Print_Menu_Black_Start		//set everything to black
	bl	Print_Menu_Black_Quit

	cmp	r4, #0				//if 0, start
	bleq	Print_Menu_Starting_Game
	moveq	r1, #0

	cmp	r4, #1				//if 1, end
	bleq	Print_Menu_Quitting_Game
	moveq	r1, #1

	b	Menu_Controller_Done
	

Menu_Controller_Done:
	pop	{r4-r10, lr}
	mov	pc, lr



//Game_Over
//Args: r0 = Fuel/Lives Flag, 0=Fuel/ 1=Lives
//Return: None
//This function prints out Game over no lives/no fuel depending on the r0 flag being set.
//Also prints instructions to return
.globl Game_Over
Game_Over:
	push	{r4-r10, lr}

	cmp	r0, #0				//Check r0 Flag and Branch
	beq	Game_Over_No_Fuel
	
	cmp	r0, #1
	beq	Game_Over_No_Lives

Game_Over_No_Fuel:
	ldr	r0, =0x0000
	bl	FillScreen
	
	//Game Over
	mov	r0, #300
	mov	r1, #300
	ldr	r2, =0xFFFF
	ldr	r3, =Game_Over_String
	bl	Draw_String

	//No Fuel
	mov	r0, #300
	ldr	r1, =315
	ldr	r2, =0xFFFF
	ldr	r3, =Game_Over_Fuel_Message
	bl	Draw_String
	
	b	Game_Over_Done

Game_Over_No_Lives:
	ldr	r0, =0x0000
	bl	FillScreen

	//Game Over
	mov	r0, #300
	mov	r1, #300
	ldr	r2, =0xFFFF
	ldr	r3, =Game_Over_String
	bl	Draw_String

	//No Lives
	mov	r0, #300
	ldr	r1, =315
	ldr	r2, =0xFFFF
	ldr	r3, =Game_Over_Lives_Message
	bl	Draw_String
	
	b	Game_Over_Done

Game_Over_Done:
	//Instructions
	mov	r0, #300
	ldr	r1, =330
	ldr	r2, =0xFFFF
	ldr	r3, =Game_Over_Message
	bl	Draw_String

	//Branch to Game_End_Menu
	pop	{r4-r10, lr}
	mov	pc, lr


//Game_Win
//Args: None
//Return: None
//This function prints Game Winning message and instructions to return
.globl Game_Win
Game_Win:
	push	{r4-r10, lr}

	ldr	r0, =0x0000
	bl	FillScreen

	//Game Win
	mov	r0, #300
	mov	r1, #300
	ldr	r2, =0xFFFF
	ldr	r3, =Game_Win_String
	bl	Draw_String

	//Instructions
	mov	r0, #300
	ldr	r1, =315
	ldr	r2, =0xFFFF
	ldr	r3, =Game_Over_Message
	bl	Draw_String

	//Branch to Game_End_Menu
	pop	{r4-r10, lr}
	mov	pc, lr

//Game_End_Menu
//Args: None
//Return: None
//This function waits for either start or select input and will restart the game or
//jump back to main menu.
.globl Game_End_Menu
Game_End_Menu:
	push	{r4-r10, lr}
Game_End_Wait:
	bl	Read_Data			//read in data

	//no input
	ldr     r1, =0xFFFF		
    	cmp     r0, r1
    	beq     Menu_Wait

	//select
   	ldr	r1, =0xFFFB	
    	cmp	r0, r1
	beq	Game_End_Select
	
	//start
	ldr	r1, =0xFFF7
	cmp	r0, r1
	beq	Game_End_Start

	b	Game_End_Wait

Game_End_Select:
	//branch to _start
	b	Game_End_Done

Game_End_Start:
	//reinitialize game
	b	Game_End_Done

Game_End_Done:
	pop	{r4-r10, lr}
	mov	pc, lr

//Strings
.section .data
.align 4

Game_Name:
	.asciz	"RoadFighter"
Creator_Names:
	.asciz	"A Video Game by Kyle Ostrander, Carlin Liu & Hilms Abou-Saleh"
Main_Menu:
	.asciz	"MAIN MENU"
Start_Game:
	.asciz	"START"
Quit_Game:
	.asciz	"QUIT"

Start_Game_Selected:
	.asciz	"<START>"
Quit_Game_Selected:
	.asciz	"<QUIT>"


Starting_Game:
	.asciz	"Initializing game"
Quitting_Game:
	.asciz	"Exiting program..."


Game_Over_String:
	.asciz	"Game Over!"
Game_Over_Message:
	.asciz	"Press <Start> to play again, <Select> to return to main menu"
Game_Over_Fuel_Message:
	.asciz	"You Ran Out of Fuel"
Game_Over_Lives_Message:
	.asciz	"You Ran Out of Lives"

Game_Win_String:
	.asciz	"You Win!"












//





