/*
 * This subroutine draws an image onto VGA pixel buffer, VGA is RGB 565
 */

.equ VGA_ADDRESS, 0x08000000 #pixel buffer address
.equ WHITE, 0xffff #white color in 
.global draw_on_vga

draw_on_vga:
	#use r8 to hold the pixel buffer address
	movia r8, VGA_ADDRESS;
	#store white color into r4
	movui r9, WHITE

	#for (int i = 0;i<=319;i++) {
	#	for (int j = 0;j<=239;j++) {
	#		compute coordinate address = 2*i + 1024*j + 0x08000000
	#		store r4 at that coordinate address 
	#	}
	#}

	#use r10 for outer variable loop counter i.e. int i = 0;
	mov r10, r0 
	OUTER_FOR:
		movi r12, 319
		bgt r10, r12, FINISHED_OUTER_FOR
		#using r11 as inner variable loop counter int j = 0;
		mov r11, r0
		INNER_FOR:
			movi r12, 239 
			bgt r11, r12, FINISHED_INNER_FOR #exit the loop 
			#compute the coordinate
			muli r12, r10, 2 #2*r10
			muli r13, r11, 1024 #1024*r11
			add r12, r12, r13 #r12 = 2*r10 + 1024*r11
			add r12, r12, r8 #add base address
			sthio r9, (r12) #store white colored pixel into the vga memory
			#increment inner loop counter
			addi r11, r11, 1
			br INNER_FOR
		
		FINISHED_INNER_FOR:
			addi r10, r10, 1 #increment the outer loop counter
			br OUTER_FOR
	FINISHED_OUTER_FOR:

	#done
	ret
	