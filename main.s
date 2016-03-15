/*
main funcion enables interrupts, and calls other subroutines
*/

.equ PS2_ADDR, 0xFF200100
.global KEN_POSITION
.global RYU_POSITION

KEN_POSITION: .word 0 #x position of Ken
RYU_POSITION: .word 0 #y position of Ryu

.global _start
_start:
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
	
	call draw_on_vga

	stop: br stop