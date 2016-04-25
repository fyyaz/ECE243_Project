#Tharindu Silva
#1001471329

#initializes the game, draws the stage background, sets the state variable
.global init

init:
	addi sp, sp, -4
	stw ra, (sp)

	movia r4, stage_background
	movi r5, BACKGROUND_WIDTH
	movi r6, BACKGROUND_HEIGHT
	mov r7, r0
	addi sp, sp, -4
	stw r0, 0(sp)
	call draw_on_vga
	#pop the last arg from stack
	addi sp, sp, 4

	ldw ra, (sp)
	addi sp, sp, 4
	ret