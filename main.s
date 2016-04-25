#Tharindu Silva
#1001471329

/*
main funcion enables interrupts, and calls other subroutines
*/
.global PS2_ADDR
.global TIMER
.global PUSH_BUTTONS
.global DRAW_BACKGROUND
.global DRAW_BACKGROUND_SPACE
.global GAME_STARTED
.global FIGHT_STATE
.global WIN_STATE
.global BACKGROUND_HEIGHT
.global BACKGROUND_WIDTH
.global CHAR_HEIGHT
.global CHAR_WIDTH
.global STARTING_Y
.global GAME_STARTED
.global IDLE1
.global IDLE2
.global IDLE3
.global IDLE4
.global MOVING_RIGHT
.global MOVING_LEFT
.global PUNCHING
.global KICKING
.global ONE_SEC
.global GAME_PERIOD
.global DMA_CONTROLLER
.global VGA_ADDRESS

.equ DRAW_BACKGROUND, 0
.equ DRAW_BACKGROUND_SPACE, 1

.equ COUNTER, 9877000

#Game states
.equ GAME_STARTED, 2
.equ FIGHT_STATE, 3
.equ WIN_STATE, 4

.equ BACKGROUND_HEIGHT, 240
.equ BACKGROUND_WIDTH, 320

#Constants used for drawing
.equ STARTING_Y, 140
.equ CHAR_HEIGHT, 80
.equ CHAR_WIDTH, 40

.equ DMA_CONTROLLER, 0xFF203020
.equ PS2_ADDR, 0xFF200100
.equ AUDIO_ADDR, 0xFF203040
.equ TIMER, 0xFF202000
.equ PUSH_BUTTONS, 0xFF200050
.equ ONE_SEC, 50000000
.equ GAME_PERIOD, 5000000 
.equ VGA_ADDRESS, 0x08000000 #pixel buffer address

#Character states
.equ IDLE1, 0
.equ IDLE2, 1
.equ IDLE3, 2
.equ IDLE4, 3
.equ MOVING_RIGHT, 4
.equ MOVING_LEFT, 5
.equ PUNCHING, 6
.equ KICKING, 7

.section .data

.global GAME_STATE
.global KEN_POSITION
.global RYU_POSITION
.global KEN_HEALTH
.global RYU_HEALTH
.global KEN_STATE
.global RYU_STATE
.global BREAK_CODE_FLAG
.global DRAWABLE

.global background_image
.global background_image2
.global stage_background

.global DRAW_CHAR

.global BUFFER

#Ryu sprites
.global ryu_idle1
.global ryu_idle2
.global ryu_idle3
.global ryu_left_kick
.global ryu_right_kick
.global ryu_move_right
.global ryu_move_left
.global ryu_left_punch
.global ryu_right_punch
.global ryu_win_screen

#Ken sprites
.global ken_idle1
.global ken_idle2
.global ken_idle3
.global ken_left_kick
.global ken_right_kick
.global ken_move_right
.global ken_move_left
.global ken_left_punch
.global ken_right_punch
.global ken_win_screen

.global BACK_BUFFER_ADDR

.global GAME_MUSIC

#Health bar for Ken and Ryu
.global health_bar

.align 2
GAME_MUSIC: .incbin "Ryu.wav"
GAME_STATE: .word 0
KEN_STATE: .word 0
RYU_STATE: .word 0
KEN_POSITION: .word 39 #x position of Ken (Start at x = 39)
RYU_POSITION: .word 289 #x position of Ryu (Start at x = 289)
KEN_HEALTH: .word 100 #Health of Ken, starting value of 100
RYU_HEALTH: .word 100 #Health of Ryu, starting value of 100

.align 0
BREAK_CODE_FLAG: .byte 0 #Set to 1 when receiving break code
DRAW_CHAR: .byte 0 #Set to 1 so that VGA ignores the characters white background
BUFFER: .byte 1 #1 for pixel buffer, 0 for back buffer

.align 1
background_image: .incbin "background.rgb565"
background_image2: .incbin "background2.rgb565"
stage_background: .incbin "stage_background.rgb565"

BACK_BUFFER_ADDR: .skip 153600 #320x240x2

#Ryu sprites
ryu_idle1: .incbin "RyuIdle1.rgb565"
ryu_idle2: .incbin "RyuIdle2.rgb565"
ryu_idle3: .incbin "RyuIdle3.rgb565"
ryu_left_kick: .incbin "RyuLeftKick.rgb565"
ryu_right_kick: .incbin "RyuRightKick.rgb565"
ryu_move_right: .incbin "RyuMoveRight.rgb565"
ryu_move_left: .incbin "RyuMoveLeft.rgb565"
ryu_left_punch: .incbin "RyuLeftPunch.rgb565"
ryu_right_punch: .incbin "RyuRightPunch.rgb565"
ryu_win_screen: .incbin "RyuWinScreen.rgb565"

#Ken sprites
ken_idle1: .incbin "KenIdle1.rgb565"
ken_idle2: .incbin "KenIdle2.rgb565"
ken_idle3: .incbin "KenIdle3.rgb565"
ken_left_kick: .incbin "KenLeftKick.rgb565"
ken_right_kick: .incbin "KenRightKick.rgb565"
ken_move_right: .incbin "KenMoveRight.rgb565"
ken_move_left: .incbin "KenMoveLeft.rgb565"
ken_left_punch: .incbin "KenLeftPunch.rgb565"
ken_right_punch: .incbin "KenRightPunch.rgb565"
ken_win_screen: .incbin "KenWinScreen.rgb565"

health_bar: .incbin "HealthBar.rgb565"

.align 0
DRAWABLE: .byte 1 #flag telling whether you can draw now

.section .text

.global _start
_start:
	
	#set up stack pointer
	movia sp, 0x80000000
	
	#Enable interrupts on push buttons
	movia r8, PUSH_BUTTONS
	movi r9, 0b010 #Enable interrupt on KEY[1]
	stwio r9, 12(r8) #Clear edge capture register
	stwio r9, 8(r8)
	
	#Enable interrupts on PS/2
	movia r8, PS2_ADDR
	movi r9, 0b1
	stwio r9, 4(r8)

	#set up TIMER
	movia r8, TIMER
	movi r9, %lo(ONE_SEC)
	stwio r9, 8(r8)
	movi r9, %hi(ONE_SEC)
	stwio r9, 12(r8)

	#Enable IRQ lines (timer, keyboard, and push buttons)
	movi r9, 0x083
	wrctl ctl3, r9
	
	#Enable PIE bit
	movi r9, 0b1
	wrctl ctl0, r9

	#start timer with interrupts
	movi r9, 0b0101
	movia r8, TIMER
	stwio r9, 4(r8)
	
	movia r8, COUNTER
	movia r9, AUDIO_ADDR
	movia r10, GAME_MUSIC
	mov r11, r8
	
	#Check if space is available for writing
wait_for_write_space:
	ldwio r12, 4(r9)
	andhi r13, r12, 0xFF00
	beq r13, r0, wait_for_write_space
	andhi r13, r12, 0x00FF
	beq r13, r0, wait_for_write_space
	
	#Write samples to the audio out L/R channels
	ldw r13, 0(r10)
	stwio r13, 8(r9)
	stwio r13, 12(r9)
	addi r10, r10, 4
	addi r11, r11, -1
	bne r11, r0, wait_for_write_space
	
	mov r11, r8
	movia r10, GAME_MUSIC
	br wait_for_write_space

	stop: br stop