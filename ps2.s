/*
 * This function is called by the ISR 
 * to handle keyboard interrupts
 */

.equ a, 0x01C
.equ d, 0x023
.equ j, 0x03B
.equ l, 0x04B
.equ space, 0x29
.equ BREAK_CODE, 0x0F0
.global ps2

ps2:
	movia r10, KEN_POSITION
	movia r11, RYU_POSITION
	
	movia et, PS2_ADDR #Store address of PS/2 device
	ldwio r8, 0(et) #Load value of the base register
	andi r8, r8, 0b011111111 #Only want the first eight bits which is the data portion
	
	#Check if break code was sent (F0)
	movi r9, BREAK_CODE
	beq r8, r9, SET_BREAK_CODE_FLAG
	
	#Check if break code flag is 1
	movia et, BREAK_CODE_FLAG
	ldb r9, 0(et)
	movi r12, 0b1
	#If it's 1, ignore the key and reset the flag
	beq r12, r9, RESET_FLAG
	
	#If player enters a: move Ken to the left
	movi r9, a
	beq r8, r9, MOVE_KEN_LEFT
	
	#Else if player enters d: move Ken to the right
	movi r9, d
	beq r8, r9, MOVE_KEN_RIGHT
	
	#Else if player enters j: move Ryu to the left
	movi r9, j
	beq r8, r9, MOVE_RYU_LEFT
	
	#Else if player enters l: move Ryu to the right
	movi r9, l
	beq r8, r9, MOVE_RYU_RIGHT
	
	#Else if player hits spacebar: start game
	movi r9, space 
	beq r8, r9, INIT_GAME
	
	
	
	#Else WTF
	br EXIT
	
MOVE_KEN_LEFT:
	#Get current posiiton information
	ldw r9, 0(r10)
	#Decrement Ken's position register by 1
	addi r9, r9, -1 
	stw r9, 0(r10)
	br EXIT

MOVE_KEN_RIGHT:
	#Get current posiiton information
	ldw r9, 0(r10)
	#Increment Ken's position register by 1
	addi r9, r9, 1 
	stw r9, 0(r10)
	br EXIT

MOVE_RYU_LEFT:
	#Get current posiiton information
	ldw r9, 0(r11)
	#Decrement Ryu's position register by 1
	addi r9, r9, -1 
	stw r9, 0(r11)
	br EXIT

MOVE_RYU_RIGHT:
	#Get current posiiton information
	ldw r9, 0(r11)
	#Increment Ryu's position register by 1
	addi r9, r9, 1 
	stw r9, 0(r11)
	br EXIT

INIT_GAME:
	movia r8, GAME_STATE
	movi r9, GAME_STARTED
	stw r9, (r8)
	br EXIT
	
SET_BREAK_CODE_FLAG:
	#Set break code to 1
	movia r8, BREAK_CODE_FLAG
	ldb r9, 0(r8)
	addi r9, r9, 1
	stb r9, 0(r8)
	br EXIT
	
RESET_FLAG:
	#Set break code flag to 0
	addi r9, r9, -1
	stb r9, 0(et)
	
EXIT:
	ret