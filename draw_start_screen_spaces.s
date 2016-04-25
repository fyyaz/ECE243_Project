#Tharindu Silva
#1001471329

.global draw_start_screen_spaces

draw_start_screen_spaces:
	movia r4, background_image2
	movi r5, BACKGROUND_WIDTH
	movi r6, BACKGROUND_HEIGHT
	mov r7, r0
	addi sp, sp, -8
	stw r0, 0(sp)
	stw ra, 4(sp)
	call draw_on_vga
	ldw ra, 4(sp)
	addi sp, sp, 8
	ret