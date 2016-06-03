//CPSC 359 - Assignment 3 - RoadFighter - ScreenData.s
//Kyle Ostrander 10128524, Carlin Liu 10123584, Hilmi Abou-Saleh 10125373

//ScreenData.s
//Functions:
//Screen_Data_Change, Screen_Data_Print, Screen_Data_Print_Black


.section .text
.align 4


.globl Screen_Data_Init
Screen_Data_Init:
	push	{r4-r10, lr}

	ldr	r3, =Fuel_Storage	
	mov	r0, #100
	strb	r0, [r3]

	ldr	r3, =Live_Storage	
	mov	r0, #51
	strb	r0, [r3]

	pop	{r4-r10, lr}
	mov	pc, lr


//Screen_Data_Change
//Args: r0 = Data type 0 = Fuel, 1 = Lives
//Return: None
//This function takes in the flag r0 to determine if either Fuel or Lives will 
//be changed. The function loads either the Fuel/Live storage and will change the 
//value. Then it will store it back.
.globl Screen_Data_Change
Screen_Data_Change:
	push	{r4-r10, lr}

	cmp		r0, #0			//r0 = 0, Branch to Fuel Change
	beq		Change_Fuel
	
	cmp		r0, #1			//r0 = 1, Branch to Life Change
	beq		Change_Life
	
Change_Fuel:
	ldr		r8, =Fuel_Storage	//Load Address
		
	ldrb		r4, [r8]		//Load Value
	sub		r4, #1			//*****Minus Change
	strb		r4, [r8]		//Store

	b		Screen_Data_Change_Done
	
Change_Life:
	ldr		r8, =Live_Storage	//Load Address
		
	ldrb		r4, [r8]		//Load Value
	sub		r4, #1			//*****Minus Change
	strb		r4, [r8]		//Store

Screen_Data_Change_Done:
	pop		{r4-r10, lr}
	mov		pc, lr


//Screen_Data_Print
//Args: None
//Return: None
//This function loads and prints out the values of the Fuel/Life and prints
//them to the screen
.globl Screen_Data_Print
Screen_Data_Print:
	push	{r4-r10, lr}

//Fuel_Display
	mov	r0, #100		//Print out Fuel:
	mov	r1, #100
	ldr	r2, =0xFFFF
	ldr	r3, =Fuel_Display
	bl	Draw_String

	ldr	r3, =Fuel_Storage	//Print out Fuel Value
	ldrb	r0, [r3]
	bl	Draw_Int


//Life_Display
	mov	r0, #100		//Print out Lives:
	mov	r1, #115
	ldr	r2, =0xFFFF
	ldr	r3, =Life_Display
	bl	Draw_String
	
	mov	r0, #160		//Print out Lives Value
	mov	r1, #115
	ldr	r2, =0xFFFF

	ldr	r3, =Live_Storage

	bl	Draw_String

	pop	{r4-r10, lr}
	mov	pc, lr
	

//Screen_Data_Print_Black
//Args: None
//Return: None
//This function loads and prints out the values of the Fuel/Life and prints them over with black
//them to the screen
.globl Screen_Data_Print_Black
Screen_Data_Print_Black:
	push	{r4-r10, lr}

//Fuel_Display
	mov	r0, #100		//Print out Fuel:
	mov	r1, #100
	ldr	r2, =0x0000
	ldr	r3, =Fuel_Display
	bl	Draw_String

	ldr	r3, =Fuel_Storage	//Print out Fuel Value
	ldrb	r0, [r3]
	bl	Draw_Int_Black


//Life_Display
	mov	r0, #100		//Print out Lives:
	mov	r1, #115
	ldr	r2, =0x0000
	ldr	r3, =Life_Display
	bl	Draw_String
	
	mov	r0, #160		//Print out Lives Value
	mov	r1, #115
	ldr	r2, =0x0000

	ldr	r3, =Live_Storage

	bl	Draw_String

	pop	{r4-r10, lr}
	mov	pc, lr
	
//Strings and Fuel/ Life Storage
.section .data
.align 4

.globl	Fuel_Display
Fuel_Display:
	.asciz	"Fuel:"
//Offset by 50 when printing

.globl Life_Display
Life_Display:
	.asciz	"Lives:"
//Offset by 60 when printing

.globl Fuel_Storage
Fuel_Storage:
	.word 100
	
.globl Live_Storage
Live_Storage:
	.word 51
//ascii value of 3 = 51









//

