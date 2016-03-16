/*
ISR
*/

.equ PS2_ADDR, 0xFF200100
.equ a, 0x01C
.equ d, 0x023
.equ j, 0x03B
.equ l, 0x04B

.section .exceptions, "ax"
ISR:
	rdctl et, ctl4
	andi et, et, 0x080 #Check if keyboard interrupted
	beq et, r0, EXIT_EXCEPTION #If PS/2 didn't interrupt, return
	
	#Push current register values onto the stack
	addi sp, sp, -16
	stw r8, 0(sp)
	stw r9, 4(sp)
	stw r10, 8(sp)
	stw r11, 12(sp)
	
	movia r10, KEN_POSITION
	movia r11, RYU_POSITION
	
	movia et, PS2_ADDR #Store address of PS/2 device
	ldwio r8, 0(et) #Load value of the base register
	andi r8, r8, 0b011111111 #Only want the first eight bits which is the data portion
	
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
	
EXIT_EXCEPTION:
	#Pop off values on the stack
	ldw r11, 12(sp)
	ldw r10, 8(sp)
	ldw r9, 4(sp)
	ldw r8, 0(sp)
	addi sp, sp, 16
	
	subi ea, ea, 4
	eret