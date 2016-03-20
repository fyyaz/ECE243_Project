.global draw_start_screen_no_spaces

draw_start_screen_no_spaces:
	addi sp, sp, -4
	stw ra, (sp)

	movia r4, background_image
	movi r5, BACKGROUND_WIDTH
	movi r6, BACKGROUND_HEIGHT
	call draw_on_vga

	ldw ra, (sp)
	addi sp, sp, 4
	ret