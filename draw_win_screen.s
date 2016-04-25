#Tharindu Silva
#1001471329

/*
 * Function used to draw the win screen of the winning character
 * Takes the image as a parameter(r4) and calls draw_on_vga
 *
 */
.global draw_win_screen

draw_win_screen:
	
	addi sp, sp, -4
	stw ra, (sp)

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
	