#initializes the game, draws the stage background, sets the state variable

.global init

init:
	addi sp, sp, -4
	stw ra, (sp)

	movia r4, stage_background
	movi r5, BACKGROUND_WIDTH
	movi r6, BACKGROUND_HEIGHT
	call draw_on_vga

	ldw ra, (sp)
	addi sp, sp, 4
	ret