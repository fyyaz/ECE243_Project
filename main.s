/*
main funcion enables interrupts, and calls other subroutines
*/
/*
	TODO: make graphics done in the interrupt
*/
.global PS2_ADDR
.global TIMER
.global DRAW_BACKGROUND
.global DRAW_BACKGROUND_SPACE
.global GAME_STARTED
.global BACKGROUND_HEIGHT
.global BACKGROUND_WIDTH
.global GAME_STARTED
.equ DRAW_BACKGROUND, 0
.equ DRAW_BACKGROUND_SPACE, 1
.equ GAME_STARTED, 2
.equ BACKGROUND_HEIGHT, 240
.equ BACKGROUND_WIDTH, 320
.equ PS2_ADDR, 0xFF200100
.equ TIMER, 0xFF202000
.equ ONE_SEC, 50000000


.section .data
.global GAME_STATE
.global KEN_POSITION
.global RYU_POSITION
.global BREAK_CODE_FLAG
.global DRAWABLE
.global background_image
.global background_image2
.global stage_background

.align 2
GAME_STATE: .word 0
KEN_POSITION: .word 0 #x position of Ken
RYU_POSITION: .word 0 #y position of Ryu
BREAK_CODE_FLAG: .byte 0 #Set to 1 when receiving break code

.align 1
background_image: .incbin "background.rgb565"
background_image2: .incbin "background2.rgb565"
stage_background: .incbin "stage_background.rgb565"
DRAWABLE: .byte 1 #flag telling whether you can draw now

.section .text

.global _start
_start:
	
	#set up stack pointer
	movia sp, 0x80000000

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

	stop: br stop