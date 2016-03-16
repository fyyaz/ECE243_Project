/*
main funcion enables interrupts, and calls other subroutines
*/

.equ PS2_ADDR, 0xFF200100
.global KEN_POSITION
.global RYU_POSITION

KEN_POSITION: .word 0 #x position of Ken
RYU_POSITION: .word 0 #y position of Ryu

background_image: .incbin "background.bin"
.equ BACKGROUND_HEIGHT, 240
.equ BACKGROUND_WIDTH, 320

.global _start
_start:
	
	#set up stack pointer
	movia sp, 0x40000000

	#Enable interrupts on device
	movia r8, PS2_ADDR
	movi r9, 0b1
	stwio r9, 4(r8)
	
	#Enable IRQ line
	movi r9, 0x080
	wrctl ctl3, r9
	
	#Enable PIE bit
	movi r9, 0b1
	wrctl ctl0, r9

	#set r4 to point to the array that has pixels, r5 is width r6 is height
	movia r4, background_image
	movi r5, BACKGROUND_WIDTH  #x coordinates
	movi r6, BACKGROUND_HEIGHT #y coordinates
	call draw_on_vga

	stop: br stop