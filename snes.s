//CPSC 359 - Assignment 2 - SNES Driver
//Kyle Ostrander 10128524, Carlin Liu 10123584, Hilmi Abou-Saleh 10125373
//Functions have been taken from ARM05-SNES Controller by Jalal Kawash
//This program is fully functional.
//Given more time the follow functionality would be implemented:
//  - Multiple button support
//  - General loop to deal with buttons pressed.


.section    .text

.globl	mainSNES
mainSNES:
	  mov     sp, #0x8000   // Initializing the stack pointer
	  bl		  EnableJTAG        // Enable JTAG
    bl      InitUART

	  ldr		  r0, =Names
    bl      Print_Message //Display creator names

    bl		  Init_GPIO



//This following loop works in the following way:
//  On a button press the r6 register is updated with the button value
//  it is then compared against the r7 register which initally contains zero
//  but will contain the last pressed button. If the buttons match, we will
//  read button press again (Read_Data).If they do not match it will print the
//  button pressed and loop. UNLESS the start button is pressed, which the
//  program will terminate.
mainSNES_loop:
    //Prompt button press
    ldr		  r0, =enterc
    bl 		  Print_Message

//Wait loop
wait_input:
    bl 		  Read_Data

  //Waits for input
  //If no input (0xFFFF) read more data
    ldr     r1, =0xFFFF
    cmp     r0, r1
    moveq   r7, #0
    beq     wait_input

	//Terminate on Start Button Press
	  ldr     r1, =0xFFF7
	  cmp     r0, r1

	  ldreq   r0, =StartButton
	  bleq    Print_Message
	  ldreq   r0, =endMessage
	  bleq    Print_Message
	  beq     haltLoop$

  //Each one of these sublabels, does the same thing. There is a way to make it
  //general, within our time constraints we were unable to do so.
  //Each label, will check against the number returned, and if it matches
  //it will print the message and update r6, and possibly r7, and reprompt
  //for input.
b_button:
    ldr		  r1, =0xFFFE
    cmp		  r0, r1

    bne     y_button //Not correct button
    mov     r6, r0   //Update r6
    cmp     r6, r7

    beq     wait_input //Button is still held.
    movne   r7, r6     //New button, so get ready to print and update
    ldrne		r0, =BButton
    blne		Print_Message
    bne		  end_mainSNES_loop

y_button:
    ldr		  r1, =0xFFFD
    cmp		  r0, r1

    bne     select_button
    mov     r6, r0
    cmp     r6, r7

    beq     wait_input
    movne   r7, r6
    ldrne		r0, =YButton
    blne		Print_Message
    bne		  end_mainSNES_loop

select_button:
    ldr		  r1, =0xFFFB
    cmp		  r0, r1

    bne     dpadup_button
    mov     r6, r0
    cmp     r6, r7

    beq     wait_input
    movne   r7, r6
    ldrne		r0, =SelectButton
    blne		Print_Message
    bne		  end_mainSNES_loop

dpadup_button:
    ldr		  r1, =0xFFEF
    cmp		  r0, r1

    bne     dpaddown_button
    mov     r6, r0
    cmp     r6, r7

    beq     wait_input
    movne   r7, r6
    ldrne		r0, =DPadUp
    blne		Print_Message
    bne   	end_mainSNES_loop

dpaddown_button:
    ldr		  r1, =0xFFDF
    cmp		  r0, r1

    bne     dpadleft_button
    mov     r6, r0
    cmp     r6, r7

    beq     wait_input
    ldr	    r0, =0xFF00
    bl	    FillScreen
    bl	    Print_Menu_Quit
    //movne   r7, r6
    //ldrne		r0, =DPadDown
    //blne		Print_Message
    bne		  end_mainSNES_loop

dpadleft_button:
    ldr		  r1, =0xFFBF
    cmp		  r0, r1

    bne     dpadright_button
    mov     r6, r0
    cmp     r6, r7

    beq     wait_input
    movne   r7, r6
    ldrne		r0, =DPadLeft
    blne		Print_Message
    bne		  end_mainSNES_loop

dpadright_button:
    ldr		  r1, =0xFF7F
    cmp		  r0, r1

    bne     a_button
    mov     r6, r0
    cmp     r6, r7

    beq     wait_input
    movne   r7, r6
    ldrne		r0, =DPadRight
    blne		Print_Message
    bne		  end_mainSNES_loop

a_button:
    ldr		  r1, =0xFEFF
    cmp		  r0, r1

    bne     x_button
    mov     r6, r0
    cmp     r6, r7

    beq     wait_input
    movne   r7, r6
    ldrne		r0, =AButton
    blne		Print_Message
    bne		  end_mainSNES_loop

x_button:
    ldr		  r1, =0xFDFF
    cmp		  r0, r1

    bne     left_bumper
    mov     r6, r0
    cmp     r6, r7

    beq     wait_input
    movne   r7, r6
    ldrne		r0, =XButton
    blne		Print_Message
    bne		  end_mainSNES_loop

left_bumper:
    ldr		  r1, =0xFBFF
    cmp		  r0, r1

    bne     right_bumper
    mov     r6, r0
    cmp     r6, r7

    beq     wait_input
    movne   r7, r6
    ldrne		r0, =LeftBumper
    blne		Print_Message
    bne		  end_mainSNES_loop

right_bumper:
    ldr	    r1, =0xF7FF
    cmp		  r0, r1

    bne     end_mainSNES_loop
    mov     r6, r0
    cmp     r6, r7

    beq     wait_input
    movne   r7, r6
    ldrne	  r0, =RightBumper
    blne	  Print_Message
    bne		  end_mainSNES_loop

end_mainSNES_loop:
  	mov 	  r0, #12 //Waits 12 microseconds
  	bl 		  Wait
  	b 		  mainSNES_loop

haltLoop$:
  	b		    haltLoop$



//a.Init_GPIO: takes in no arguments and returns nothing. The function clears
//the corresponding bits and then sets them to the function code passed in.
//This function automatically sets GPIO pin 9(LATCH), 10(DATA), 11(CLOCK)
//Function taken from ARM05-SNES Controller by Jalal Kawash
.globl Init_GPIO
Init_GPIO:
	push	  {r4-r10, lr}

//GPIO PIN 9 - OUTPUT (LATCH)
	ldr		  r5, =0x3F200000		//address for GPFSEL0
	ldr		  r0, [r5]				  //copy GPFSEL0 into r0

	mov		  r1, #7						//b0111
	lsl		  r1, #27						//clear bit 27-29
	bic		  r0, r1						//bits cleared

	mov		  r2, #1						//output function code (001)
	lsl		  r2, #27						//shift 27 times
	orr		  r0, r2						//set to output
	str		  r0, [r5]				  //write back to GPFSEL0

//GPIO PIN 10 - INPUT (DATA)
  ldr		 r4, =0x3F200004		//address for GPFSEL1
	ldr		  r0, [r4]				  //copy GPFSEL1 into r0

	mov		  r1, #7						//b0111
	bic		  r0, r1						//bits cleared
	str		  r0, [r4]				  //write back to GPFSEL1

//GPIO PIN 11 - OUTPUT (CLOCK)
	ldr		  r0, [r4]				  //copy GPFSEL1 into r0

	mov		  r1, #7						//b0111
	lsl		  r1, #3						//clear bit 3-5
	bic		  r0, r1						//bits cleared

	mov		  r2, #1						//output function code (001)
	lsl		  r2, #3						//shift 3 times
	orr		  r0, r2						//set to output
	str		  r0, [r4]				  //write back to GPFSEL1

  pop     {r4-r10, lr}
  mov     pc, lr


//b.Write_Latch: Function takes in the input of r0 (0 or 1) and write it to
//the latch line. There is no return.
//Function taken from ARM05-SNES Controller by Jalal Kawash
Write_Latch:
	push	  {r4-r10, lr}

	ldr		  r4, =0x3F200000		//GPFSEL0

	mov		  r1,	#1
	mov		  r2,	#9						//pin #9

	lsl		  r1, r2						//align to pin #9
	teq		  r0, #0						//check 0

	streq	  r1,	[r4, #40]			//GPSCLR0
	strne   r1,	[r4, #28]		  //GPSET0

	pop		  {r4-r10, lr}
  mov     pc, lr


//c.Write_Clock: Function takes in the input of r0 (0 or 1) and writes it to
//the clock line. There is no return.
//Function taken from ARM05-SNES Controller by Jalal Kawash
Write_Clock:
	push	  {r4-r10, lr}

	ldr		  r4, =0x3F200000		//GPSEL0

	mov		  r1,	#1
	mov		  r2, #11						//pin #11

	lsl		  r1, r2						//align to pin #11
	teq		  r0, #0						//check 0

	streq	  r1,	[r4, #40]			//GPSCLR0
	strne   r1,	[r4, #28]			//GPSET0

	pop	    {r4-r10, lr}
  mov     pc, lr


//d.Read_SNES: Main snes subroutines reads input from SNES controller (DATA LINE)
//and returns the pressed button in a binary form in r0.
//returns r0 containing button pressed (0 or 1)
//Function taken from ARM05-SNES Controller by Jalal Kawash
Read_SNES:
	push	  {r4-r10, lr}

	ldr		  r4, =0x3F200000		//GPFSEL0

	mov		  r1, #10					  //pin10
	ldr		  r3,	[r4, #52]			//GPLEV0

	mov		  r2, #1						//mask
	lsl		  r2,	r1						//align pin10

	and		  r3,	r2						//mask everything else
	teq		  r3,	#0						// test if the pin is low

  //return placed in r0
	moveq	  r0, #0						//r0 = 0
	movne   r0, #1						//r0 = 1

	pop		  {r4-r10, lr}
  mov     pc, lr


//e.Wait: Function takes in input in r0 and waits that amount in micro seconds.
//Nothing is returned.
//Function taken from ARM05-SNES Controller by Jalal Kawash
.globl Wait
Wait:
	push		{r4-r10, lr}

	ldr		  r4, = 0x3F003004	//address of CLO
	ldr		  r5, [r4]		      //read CLO

	add		  r5, r0			      //add r0 micros

waitLoop:
  ldr		  r6, [r4]
  cmp		  r5, r6			      //stop when CLO = r4
  bhi		  waitLoop

	pop		  {r4-r10, lr}
	mov		  pc, lr


//f.Read_Data: Function takes in no arguments but implements algorithm used to
//sample the buttons from the SNES controller. The bit pattern is returned in
//r0 to tell you which buttons were pressed.
//Function taken from ARM05-SNES Controller by Jalal Kawash
.globl Read_Data
Read_Data:
	push	  {r4-r10, lr}

	mov		  r5, #0

	mov		  r0, #1					  //#1 into Clock
	bl		  Write_Clock

	mov		  r0, #1						//#1 into Latch
	bl		  Write_Latch

	mov		  r0, #12					  //12 micros into Wait
	bl		  Wait

	mov		  r0, #0						//#0 into Clock
	bl		  Write_Latch

	mov		  r4,	#0					  //set index 0

//Loop that runs through all 16 bits and writes button status to r5
pulseloop:
	mov		  r0, #6					  //6 micros into Wait
	bl		  Wait

	mov		  r0, #0						//#0 into Clock
	bl		  Write_Clock

	mov		  r0, #6						//6 micros into Wait
	bl		  Wait

	bl		  Read_SNES					//Read GPIO Data
										        //r0 = (0 or 1)
	cmp		  r0, #1						//check high
	bne		  zero					    //(r0 = 0) when its not high
//(r0 = 1)
	mov		  r2, #1						//make a mask
	lsl		  r2, r4					  //align mask to button
	orr		  r5, r2					  //write button to r5

//(r0 = 0)
zero:
	mov		  r0, #1						//#1 into Clock
	bl		  Write_Clock

	add		  r4, #1					  //increment index

	cmp		  r4, #16
	bne		  pulseloop				  //Branch if not equal to 16

	mov		  r0, r5					  //Buttons pressed in r5 returned in r0

	pop	    {r4-r10, lr}
  mov     pc, lr


//Helper Functions//

//g.Print_Message prints the message contained at address r0
//r0 = contains address to print
Print_Message:
  	push		{r4-r10, lr}

  	bl 		stringLength
  	bl		WriteStringUART

  	pop		{r4-r10, lr}
  	mov 		pc, lr


//readStringLength - Looks at length of string
//r0 - contains address of string
//r0 - returns address of string
//r1 - returns length of string
//APCS
stringLength:
    	push		{r4-r10, lr}
	mov 		r5, #0 //Counter
stringLength_loop:
	ldrb 		r4, [r0, r5]
	add 		r5, #1
    //If null then stop loop, otherwise keep going
	teq 		r4, #0
	bne 		stringLength_loop
    //loop end
	mov 		r1, r5
    	pop		{r4-r10, lr}
    	mov 		pc, lr



.section .data
Names:
	.asciz	"Creator names: Kyle Ostrander, Carlin Liu and Hilmi Abou-Saleh\r\n"
enterc:
	.asciz	"\r\nPlease press a Button...\r\n\r\n"
endMessage:
	.asciz	"\r\nProgram is terminating...\r\n"

BButton:
	.asciz	"You have pressed the B-Button\r\n"
AButton:
	.asciz	"You have pressed the A-Button\r\n"
XButton:
	.asciz	"You have pressed the X-Button\r\n"
YButton:
	.asciz	"You have pressed the Y-Button\r\n"

SelectButton:
	.asciz	"You have pressed the Select-Button\r\n"
StartButton:
	.asciz	"You have pressed the Start-Button\r\n"

DPadUp:
	.asciz	"You have pressed the JoyPad-Up-Button\r\n"
DPadDown:
	.asciz	"You have pressed the JoyPad-Down-Button\r\n"
DPadLeft:
	.asciz	"You have pressed the JoyPad-Left-Button\r\n"
DPadRight:
	.asciz	"You have pressed the JoyPad-Right-Button\r\n"

LeftBumper:
	.asciz	"You have pressed the Left-Bumper-Button\r\n"
RightBumper:
	.asciz	"You have pressed the Right-Bumper-Button\r\n"
