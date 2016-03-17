/*
ISR
*/

.equ a, 0x01C
.equ d, 0x023
.equ j, 0x03B
.equ l, 0x04B
.equ BREAK_CODE, 0x0F0

.section .exceptions, "ax"
ISR:
	#Push current register values onto the stack
	addi sp, sp, -20
	stw r8, 0(sp)
	stw r9, 4(sp)
	stw r10, 8(sp)
	stw r11, 12(sp)
	stw r12, 16(sp)

	rdctl et, ctl4
	andi et, et, 0x080 #Check if keyboard interrupted
	beq et, r0, CHECK_TIMER #If PS/2 didn't interrupt check the timer
	br SERVE_PS2

	CHECK_TIMER:
		rdctl et, ctl4
		andi et, et, 0b01 
		beq et, r0, EXIT_EXCEPTION #neither timer nor ps2 interrupted

	#SERVE TIMER
	movia r8, GAME_STATE
	ldwio r9, (r8)
	beq r9, r0, GOTO_SPACE #currently displaying without spaces, now show the one with space bar text

	#now check if previously was displaying with space text, if so show without now 
	movi et, DRAW_BACKGROUND_SPACE 
	beq r9, et, GOTO_NO_SPACE

	GOTO_SPACE: #change the state so that background with space is drawn
		movi r9, DRAW_BACKGROUND_SPACE
		stwio r9, (r8)
		br RESTART_TIMER

	GOTO_NO_SPACE:
		movi r9, DRAW_BACKGROUND
		stwio r9, (r8)

	RESTART_TIMER: #acknowledge timer interrupt and restart it
		movia r9, TIMER
		stwio r0, (r9)
		movi r8, 0b0101
		stwio r8, 4(r9)
		br EXIT_EXCEPTION
	
	SERVE_PS2:
	
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
	
	#Else WTF
	br EXIT_EXCEPTION
	
MOVE_KEN_LEFT:
	#Get current posiiton information
	ldw r9, 0(r10)
	#Decrement Ken's position register by 1
	addi r9, r9, -1 
	stw r9, 0(r10)
	br EXIT_EXCEPTION

MOVE_KEN_RIGHT:
	#Get current posiiton information
	ldw r9, 0(r10)
	#Increment Ken's position register by 1
	addi r9, r9, 1 
	stw r9, 0(r10)
	br EXIT_EXCEPTION

MOVE_RYU_LEFT:
	#Get current posiiton information
	ldw r9, 0(r11)
	#Decrement Ryu's position register by 1
	addi r9, r9, -1 
	stw r9, 0(r11)
	br EXIT_EXCEPTION

MOVE_RYU_RIGHT:
	#Get current posiiton information
	ldw r9, 0(r11)
	#Increment Ryu's position register by 1
	addi r9, r9, 1 
	stw r9, 0(r11)
	br EXIT_EXCEPTION
	
SET_BREAK_CODE_FLAG:
	#Set break code to 1
	movia r8, BREAK_CODE_FLAG
	ldb r9, 0(r8)
	addi r9, r9, 1
	stb r9, 0(r8)
	br EXIT_EXCEPTION
	
RESET_FLAG:
	#Set break code flag to 0
	addi r9, r9, -1
	stb r9, 0(et)
	
EXIT_EXCEPTION:
	#Pop off values on the stack
	ldw r12, 16(sp)
	ldw r11, 12(sp)
	ldw r10, 8(sp)
	ldw r9, 4(sp)
	ldw r8, 0(sp)
	addi sp, sp, 20
	
	subi ea, ea, 4
	eret