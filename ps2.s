#Tharindu Silva
#1001471329

/*
 * This function is called by the ISR 
 * to handle keyboard interrupts
 */

#Ken's buttons
.equ a, 0x01C
.equ d, 0x023
.equ w, 0x01D
.equ s, 0x01B

#Ryu's buttons
.equ j, 0x03B
.equ l, 0x04B
.equ i, 0x043
.equ k, 0x042

.equ space, 0x29
.equ BREAK_CODE, 0x0F0
.global ps2

ps2:
	movia r10, KEN_POSITION
	movia r11, RYU_POSITION
	
	movia et, PS2_ADDR #Store address of PS/2 device
	ldwio r8, 0(et) #Load value of the base register
	andi r8, r8, 0x0FF #Only want the first eight bits which is the data portion
	
	#Check if break code was sent (F0)
	movi r9, BREAK_CODE
	beq r8, r9, SET_BREAK_CODE_FLAG
	
	#Check if break code flag is 1
	movia et, BREAK_CODE_FLAG
	ldb r9, 0(et)
	movi r12, 0b1
	#If it's 1, ignore the key and reset the flag
	beq r12, r9, RESET_FLAG
	
	#If player hits spacebar: start game
	movi r9, space 
	beq r8, r9, INIT_GAME
	
	#Check if game is in the fight state
	movia et, GAME_STATE
	ldw r9, 0(et)
	movi et, FIGHT_STATE
	#If not, do nothing and exit
	bne r9, et, EXIT
	
	#If player enters a: move Ken to the left
	movi r9, a
	beq r8, r9, MOVE_KEN_LEFT
	
	#Else if player enters d: move Ken to the right
	movi r9, d
	beq r8, r9, MOVE_KEN_RIGHT

	#Else if player enters w: make Ken punch
	movi r9, w
	beq r8, r9, KEN_PUNCH
	
	#Else if player enters s: make Ken kick
	movi r9, s
	beq r8, r9, KEN_KICK

	#Else if player enters j: move Ryu to the left
	movi r9, j
	beq r8, r9, MOVE_RYU_LEFT
	
	#Else if player enters l: move Ryu to the right
	movi r9, l
	beq r8, r9, MOVE_RYU_RIGHT
	
	#Else if player enters i: make Ryu punch
	movi r9, i
	beq r8, r9, RYU_PUNCH
	
	#Else if player enters k: make Ryu kick
	movi r9, k
	beq r8, r9, RYU_KICK

	#Else ??
	br EXIT
	
MOVE_KEN_LEFT:
	#Get current posiiton information
	ldw r9, 0(r10)
	
	#Don't allow Ken to go past the left edge of the screen
	movi r12, 19
	beq r9, r12, EXIT
	
	#Decrement Ken's position register by 5
	addi r9, r9, -5 
	stw r9, 0(r10)
	
	#Change character's state
	movia r10, KEN_STATE
	movi r9, MOVING_LEFT
	stw r9, 0(r10)
	
	br EXIT

MOVE_KEN_RIGHT:
	#Get current posiiton information
	ldw r9, 0(r10)
	
	#Don't allow Ken to go past Ryu
	ldw r12, 0(r11)
	sub r12, r12, r9
	movi r13, 35
	beq r12, r13, EXIT
	
	#Increment Ken's position register by 5
	addi r9, r9, 5 
	stw r9, 0(r10)
	
	#Change character's state
	movia r10, KEN_STATE
	movi r9, MOVING_RIGHT
	stw r9, 0(r10)
	
	br EXIT

KEN_PUNCH:
	
	#Change character's state
	movia r10, KEN_STATE
	movi r9, PUNCHING
	stw r9, 0(r10)
	
	movia r10, KEN_POSITION
	movia r11, RYU_POSITION
	
	#Get current posiiton information
	ldw r9, 0(r10)
	ldw r12, 0(r11)
	
	#Check if Ken is close enough to damage Ryu
	sub r12, r12, r9
	movi r13, 35
	bne r12, r13, EXIT
	
	#Decrement Ryu's health by 5
	movia r11, RYU_HEALTH
	ldw r9, 0(r11)
	movi r10, 5
	sub r9, r9, r10
	stw r9, 0(r11)
	
	br EXIT

KEN_KICK:

	#Change character's state
	movia r10, KEN_STATE
	movi r9, KICKING
	stw r9, 0(r10)
	
	movia r10, KEN_POSITION
	movia r11, RYU_POSITION
	
	#Get current posiiton information
	ldw r9, 0(r10)
	ldw r12, 0(r11)
	
	#Check if Ken is close enough to damage Ryu
	sub r12, r12, r9
	movi r13, 35
	bne r12, r13, EXIT
	
	#Decrement Ryu's health by 5
	movia r11, RYU_HEALTH
	ldw r9, 0(r11)
	movi r10, 10
	sub r9, r9, r10
	stw r9, 0(r11)
	
	br EXIT

MOVE_RYU_LEFT:
	#Get current posiiton information
	ldw r9, 0(r11)
	
	#Don't allow Ryu to go past Ken
	ldw r12, 0(r10)
	sub r12, r9, r12
	movi r13, 35
	beq r12, r13, EXIT
	
	#Decrement Ryu's position register by 5
	addi r9, r9, -5
	stw r9, 0(r11)
	
	#Change character's state
	movia r10, RYU_STATE
	movi r9, MOVING_LEFT
	stw r9, 0(r10)
	
	br EXIT

MOVE_RYU_RIGHT:
	#Get current posiiton information
	ldw r9, 0(r11)
	
	#Don't allow Ryu to go past the right edge of the screen
	movi r12, 299
	beq r9, r12, EXIT
	
	#Increment Ryu's position register by 5
	addi r9, r9, 5 
	stw r9, 0(r11)
	
	#Change character's state
	movia r10, RYU_STATE
	movi r9, MOVING_RIGHT
	stw r9, 0(r10)
	
	br EXIT

RYU_PUNCH:

	#Change character's state
	movia r10, RYU_STATE
	movi r9, PUNCHING
	stw r9, 0(r10)
	
	movia r10, KEN_POSITION
	movia r11, RYU_POSITION
	
	#Get current posiiton information
	ldw r9, 0(r10)
	ldw r12, 0(r11)
	
	#Check if Ryu is close enough to damage Ken
	sub r12, r12, r9
	movi r13, 35
	bne r12, r13, EXIT
	
	#Decrement Ken's health by 5
	movia r11, KEN_HEALTH
	ldw r9, 0(r11)
	movi r10, 5
	sub r9, r9, r10
	stw r9, 0(r11)
	
	br EXIT
	
RYU_KICK:

	#Change character's state
	movia r10, RYU_STATE
	movi r9, KICKING
	stw r9, 0(r10)
	
	movia r10, KEN_POSITION
	movia r11, RYU_POSITION
	
	#Get current posiiton information
	ldw r9, 0(r10)
	ldw r12, 0(r11)
	
	#Check if Ryu is close enough to damage Ken
	sub r12, r12, r9
	movi r13, 35
	bne r12, r13, EXIT
	
	#Decrement Ken's health by 10
	movia r11, KEN_HEALTH
	ldw r9, 0(r11)
	movi r10, 10
	sub r9, r9, r10
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