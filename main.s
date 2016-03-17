/*
main funcion enables interrupts, and calls other subroutines
*/

.global PS2_ADDR
.global TIMER
.global DRAW_BACKGROUND
.global DRAW_BACKGROUND_SPACE
.equ DRAW_BACKGROUND, 0
.equ DRAW_BACKGROUND_SPACE, 1
.equ BACKGROUND_HEIGHT, 240
.equ BACKGROUND_WIDTH, 320
.equ PS2_ADDR, 0xFF200100
.equ TIMER, 0xFF202000
.equ ONE_SEC, 500000000

.section .data
.global GAME_STATE
.global KEN_POSITION
.global RYU_POSITION
.global BREAK_CODE_FLAG

.align 2
GAME_STATE: .word 0
KEN_POSITION: .word 0 #x position of Ken
RYU_POSITION: .word 0 #y position of Ryu
BREAK_CODE_FLAG: .byte 0 #Set to 1 when receiving break code

.align 0
background_image: .incbin "background.rgb565"
background_image2: .incbin "background2.rgb565"

.section .text

.global _start
_start:
	
	#set up stack pointer
	movia sp, 0x40000000

	#Enable interrupts on device
	movia r8, PS2_ADDR
	movi r9, 0b1
	stwio r9, 4(r8)

	#set up TIMER
	movia r8, TIMER
	movi r9, %lo(ONE_SEC)
	stwio r9, 8(r8)
	movi r9, %hi(ONE_SEC)
	stwio r9, 12(r8)

	#Enable IRQ lines
	movi r9, 0x081
	wrctl ctl3, r9
	
	#Enable PIE bit
	movi r9, 0b1
	wrctl ctl0, r9

	#start timer with interrupts
	movi r9, 0b0101
	movia r8, TIMER
	stwio r9, 4(r8)

	top:
		
		#check the state
		movia r4, GAME_STATE
		ldwio r4, (r4)
		
		#based on state choose the background image to load into r4
		beq r4, r0, START_BACKGROUND_NO_SPACES #state = 0 means draw the start screen with no text
		START_BACKGROUND_YES_SPACES:
			movia r4, background_image2 # yes text
		START_BACKGROUND_NO_SPACES:
			movia r4, background_image
			
		#set r5 to be background width, r6 is background height
		movi r5, BACKGROUND_WIDTH  #x coordinates
		movi r6, BACKGROUND_HEIGHT #y coordinates

		#draw it
		call draw_on_vga
	br top

	stop: br stop