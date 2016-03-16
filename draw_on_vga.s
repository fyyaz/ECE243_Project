/*
 * This subroutine draws an image onto VGA pixel buffer, VGA is RGB 565
 * r4 should be pointer to 2d array that has the pixels to display
 * r5 is the width of the image (x coordinates)
 * r6 is the height of the image (y coordinates)
 */

.equ VGA_ADDRESS, 0x08000000 #pixel buffer address
.equ WHITE, 0xffff #white color in 
.global draw_on_vga

draw_on_vga:
	#use r8 to hold the pixel buffer address
	movia r8, VGA_ADDRESS;

	#for (int i = 0;i<=319;i++) {
	#	for (int j = 0;j<=239;j++) {
	#		compute coordinate address = 2*i + 1024*j + 0x08000000 where i is the x coordinate j is the y
	#		store r4 at that coordinate address 
	#	}
	#}

	#use r10 for outer variable loop counter i.e. int i = 0;
	mov r10, r0 
	OUTER_FOR: #outer for loop should go through the height (y coordinate) 0:r6-1
		bge r10, r6, FINISHED_OUTER_FOR
		#using r11 as inner variable loop counter int j = 0;
		mov r11, r0
		INNER_FOR: #inner loop goes through the width (x coordinate) for now 0:r5-1
			bge r11, r5, FINISHED_INNER_FOR #exit the loop 
			#compute the coordinate
			muli r12, r10, 1024 #1024*r10 i.e. 1024y
			muli r13, r11, 2 #2*r11 i.e. 2x
			add r12, r12, r13 #r12 = 2*r11 + 1024*r10 2x + 1024y
			add r12, r12, r8 #find pixel to write to (vga start address + same offset)
			ldh r9, (r4) #load the half word out of memory (pixel value)
			#movui r9, WHITE
			sthio r9, (r12) #store the picture pixel into vga
			#go to the next picture hword
			addi r4, r4, 2
			#increment inner loop counter
			addi r11, r11, 1
			br INNER_FOR
		FINISHED_INNER_FOR:
			addi r10, r10, 1 #increment the outer loop counter
			br OUTER_FOR
	FINISHED_OUTER_FOR:

	#done
	ret
	