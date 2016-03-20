.global draw_start_screen_spaces

draw_start_screen_spaces:
	addi sp, sp, -4
	stw ra, (sp)

	movia r4, background_image2
	movi r5, BACKGROUND_WIDTH
	movi r6, BACKGROUND_HEIGHT

	ldw ra, (sp)
	addi sp, sp, 4
	ret