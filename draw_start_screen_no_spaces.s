#Tharindu Silva
#1001471329

.global draw_start_screen_no_spaces

draw_start_screen_no_spaces:

	movia r4, background_image #**ptr = img[][]
	movi r5, BACKGROUND_WIDTH #width of the picture
	movi r6, BACKGROUND_HEIGHT #height of the picture
	mov r7, r0 #starting x position
	addi sp, sp, -8
	stw r0, (sp) #starting y position
	stw ra, 4(sp) #return address
	call draw_on_vga
	ldw ra, 4(sp)
	addi sp, sp, 8
	ret