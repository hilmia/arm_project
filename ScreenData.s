//Fuel and Lives Calculator

//
.globl Screen_Data_Init
Screen_Data_Init:
	push	{r4-r10, lr}

	//initialize Data
		
	mov		r0, #100
	mov		r1, #51
	
	ldr		r3, =Fuel_Storage
	str		r0, [r3]			//fuel

	ldr		r3, =Live_Storage
	str		r1, [r3]			//Lives

	
	pop		{r4-r10, lr}
	mov		pc, lr



//r0 = Data type 0 = Fuel, 1 = Lives
//r1 = Change - This is the minus value ie) 100- r1
//

.globl Screen_Data_Change
Screen_Data_Change:
	push	{r4-r10, lr}

	cmp		r0, #0
	beq		Change_Fuel
	
	cmp		r0, #1
	beq		Change_Life
	
Change_Fuel:
	ldr		r3, =Fuel_Storage
		
	ldr		r4, [r3]
	sub		r4, #1	//*****Minus Change

	str		r4, [r3]
	b		Screen_Data_Change_Done
	
Change_Life:
	ldr		r3, =Live_Storage	
		
	ldr		r4, [r3]
	sub		r4, #1	//*****Minus Change

	cmp		r4, #0
	//***************beq		//Game Over Loop here
	
	//
	beq		gameover

gameover:
	bl		Game_Over
	//

	str		r4, [r3]
	b		Screen_Data_Change_Done
	
Screen_Data_Change_Done:
	pop		{r4-r10, lr}
	mov		pc, lr



//
.globl Screen_Data_Print
Screen_Data_Print:
	push	{r4-r10, lr}

//Fuel_Display
	mov	r0, #100
	mov	r1, #100
	ldr	r2, =0xFFFF
	ldr	r3, =Fuel_Display
	bl	Draw_String


	ldr	r3, =Fuel_Storage
	ldrb	r0, [r3]
	bl	Draw_Int


//Life_Display
	mov	r0, #100//***********CHANGE VALUES
	mov	r1, #115
	ldr	r2, =0xFFFF
	ldr	r3, =Life_Display
	bl	Draw_String

	mov	r0, #160//***********CHANGE VALUES
	mov	r1, #115
	ldr	r2, =0xFFFF

	ldr	r3, =Live_Storage

	bl	Draw_String

	pop	{r4-r10, lr}
	mov	pc, lr
	

.section .data
.align 4

.globl	Fuel_Display
Fuel_Display:
	.asciz	"Fuel:"
//*****Offset by 50?


.globl Life_Display
Life_Display:
	.asciz	"Lives:"
//*****Offset by 60?

.globl Fuel_Storage
Fuel_Storage:
	.word 100
	

.globl Live_Storage
Live_Storage:
	.word 51
	//.asciz "hello"

BStorage:
	.word	100 //must be less than 300ish

Fuel0:
	.asciz "0"
Fuel1:
	.asciz "1"
Fuel2:
	.asciz "2"
Fuel3:
	.asciz "3"
Fuel4:
	.asciz "4"
Fuel5:
	.asciz "5"
Fuel6:
	.asciz "6"
Fuel7:
	.asciz "7"
Fuel8:
	.asciz "8"
Fuel9:
	.asciz "9"










//

