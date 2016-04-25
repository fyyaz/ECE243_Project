#Tharindu Silva
#1001471329

# this subroutine updates the screen (VGA), depending on,
# the current value of the game state variable (GAME_STATE)
# using registers:
# 	 r4, r5, r6 as function arguements for called subroutines
#    r8, r9 to hold temporary values, and addresses

.global update

update:
	addi sp, sp, -4
	stw ra, (sp)
	
	movia r8, KEN_HEALTH
	ldw r9, 0(r8)
	ble r9, r0, RYU_WINS
	
	movia r8, RYU_HEALTH
	ldw r9, 0(r8)
	ble r9, r0, KEN_WINS
	
	movia r8, GAME_STATE
	ldw r9, (r8)

	#check if drawing without space
	movi r10, DRAW_BACKGROUND
	beq r9, r10, GOTO_SPACE #currently displaying without spaces, now show the one with space bar text
	#chek if drawing the start screen with spaces
	movi r10, DRAW_BACKGROUND_SPACE
	beq r9, r10, GOTO_NO_SPACE
	#check if game has just been started, if so initialize the game
	movi r10, GAME_STARTED
	beq r9, r10, INIT
	
	movi r10, FIGHT_STATE
	beq r9, r10, HANDLE_CHARACTERS

	#else some unknown state, go back to the 0th state
	br UNKNOWN

	GOTO_SPACE: #change the state so that background with space is drawn
		#draw the background without spaces
		addi sp, sp, -8
		stw r8, (sp)
		stw r9, 4(sp)
		call draw_start_screen_no_spaces
		ldw r8, (sp)
		ldw r9, 4(sp)
		addi sp, sp, 8

		movi r9, DRAW_BACKGROUND_SPACE
		stw r9, (r8)
		br done

	GOTO_NO_SPACE:
		addi sp, sp, -8
		stw r8, (sp)
		stw r9, 4(sp)
		call draw_start_screen_spaces
		ldw r8, (sp)
		ldw r9, 4(sp)
		addi sp, sp, 8

		movi r9, DRAW_BACKGROUND
		stw r9, (r8)
		br done

	INIT:
		#move the background stage image into r4, and draw it
		addi sp, sp, -8
		stw r8, (sp)
		stw r9, 4(sp)
		call init #initialize the game
		#pop from stack
		ldw r8, (sp)
		ldw r9, 4(sp)
		addi sp, sp, 8
		#set the next state to FIGHT_STATE
		movi r9, FIGHT_STATE
		stw r9, 0(r8)
		
		movia r8, TIMER
		movi r9, %lo(GAME_PERIOD)
		stwio r9, 8(r8)
		movi r9, %hi(GAME_PERIOD)
		stwio r9, 12(r8)
		
		br done
	
	#Used to update character images based on character state
	HANDLE_CHARACTERS:
	
	#Redraw fight screen
	call init
	
	call draw_health_bars
	
	#Set flag to tell VGA to ignore characters green background
	movia r8, DRAW_CHAR
	movi r9, 1
	stb r9, 0(r8)
	
	HANDLE_KEN:
		#Get Ken's current state
		movia r8, KEN_STATE
		ldw r11, 0(r8)
		
		#Set VGA parameters
		movi r5, CHAR_WIDTH
		movi r6, CHAR_HEIGHT
		movi r7, STARTING_Y
		addi sp, sp, -4
		stw r7, 0(sp) #put starting y coordinate in stack 
	
		#Starting x position to draw
		movia r8, KEN_POSITION
		ldw r9, 0(r8)
		addi r9, r9, -20
	
		#make starting x coordinate r7
		mov r7, r9
		
		#Draw Ken based on state
		movi r10, IDLE1
		beq r11, r10, DRAW_KEN_IDLE1
		
		movi r10, IDLE2
		beq r11, r10, DRAW_KEN_IDLE2
		
		movi r10, IDLE3
		beq r11, r10, DRAW_KEN_IDLE3
		
		movi r10, IDLE4		
		beq r11, r10, DRAW_KEN_IDLE4
		
		movi r10, MOVING_RIGHT
		beq r11, r10, DRAW_KEN_MOVE_RIGHT
		
		movi r10, MOVING_LEFT
		beq r11, r10, DRAW_KEN_MOVE_LEFT
		
		movi r10, PUNCHING
		beq r11, r10, DRAW_KEN_PUNCHING
		
		movi r10, KICKING
		beq r11, r10, DRAW_KEN_KICKING
	
	#Default state
	DRAW_KEN_IDLE1:
	
		movia r4, ken_idle1
		
		call draw_on_vga
		#pop arg from the stack
		addi sp, sp, 4
		
		movia r8, KEN_STATE
		movi r9, IDLE2
		
		stw r9, 0(r8)
		
		br HANDLE_RYU
	
	DRAW_KEN_IDLE2:
	
		movia r4, ken_idle2
		
		call draw_on_vga
		#pop arg from the stack
		addi sp, sp, 4
		
		movia r8, KEN_STATE
		movi r9, IDLE3
		
		stw r9, 0(r8)
		
		br HANDLE_RYU
		
	DRAW_KEN_IDLE3:
	
		movia r4, ken_idle1
		
		call draw_on_vga
		#pop arg from the stack
		addi sp, sp, 4
		
		movia r8, KEN_STATE
		movi r9, IDLE4
		
		stw r9, 0(r8)
		
		br HANDLE_RYU
		
	
	DRAW_KEN_IDLE4:
		
		movia r4, ken_idle3
		
		call draw_on_vga
		#pop arg from the stack
		addi sp, sp, 4
		
		movia r8, KEN_STATE
		movi r9, IDLE1
		
		stw r9, 0(r8)
		
		br HANDLE_RYU

	DRAW_KEN_MOVE_RIGHT:
	
		movia r4, ken_move_right
		
		call draw_on_vga
		#pop arg from stack
		addi sp, sp, 4
		
		br RESET_KEN
	
	DRAW_KEN_MOVE_LEFT:
	
		movia r4, ken_move_left
		
		call draw_on_vga
		#pop arg from stack
		addi sp, sp, 4
		
		br RESET_KEN
	
	DRAW_KEN_PUNCHING:
	
		movia r4, ken_left_punch
		
		call draw_on_vga
		#pop arg from stack
		addi sp, sp, 4
		
		br RESET_KEN
	
	DRAW_KEN_KICKING:
	
		movia r4, ken_right_kick
		
		call draw_on_vga
		#pop arg from stack
		addi sp, sp, 4
		
		br RESET_KEN
	
	RESET_KEN:
		#Set Ken back to his idle state
		movia r8, KEN_STATE
		stw r0, 0(r8)
	
	HANDLE_RYU:
		#Get Ryu's current state
		movia r8, RYU_STATE
		ldw r11, 0(r8)
		
		#Set VGA parameters
		movi r5, CHAR_WIDTH
		movi r6, CHAR_HEIGHT
		movi r7, STARTING_Y
		addi sp, sp, -4
		stw r7, 0(sp)
	
		#Starting x position to draw
		movia r8, RYU_POSITION
		ldw r9, 0(r8)
		addi r9, r9, -20
	
		mov r7, r9
		
		#Draw Ryu based on state
		movi r10, IDLE1
		beq r11, r10, DRAW_RYU_IDLE1
		
		movi r10, IDLE2
		beq r11, r10, DRAW_RYU_IDLE2
		
		movi r10, IDLE3
		beq r11, r10, DRAW_RYU_IDLE3
		
		movi r10, IDLE4		
		beq r11, r10, DRAW_RYU_IDLE4
		
		movi r10, MOVING_RIGHT
		beq r11, r10, DRAW_RYU_MOVE_RIGHT
		
		movi r10, MOVING_LEFT
		beq r11, r10, DRAW_RYU_MOVE_LEFT
		
		movi r10, PUNCHING
		beq r11, r10, DRAW_RYU_PUNCHING
		
		movi r10, KICKING
		beq r11, r10, DRAW_RYU_KICKING

	DRAW_RYU_IDLE1:
	
		movia r4, ryu_idle1
		
		call draw_on_vga
		#pop arg from the stack
		addi sp, sp, 4
		
		movia r8, RYU_STATE
		movi r9, IDLE2
		
		stw r9, 0(r8)
		
		br done
	
	DRAW_RYU_IDLE2:
	
		movia r4, ryu_idle2
		
		call draw_on_vga
		#pop arg from the stack
		addi sp, sp, 4
		
		movia r8, RYU_STATE
		movi r9, IDLE3
		
		stw r9, 0(r8)
		
		br done
		
	DRAW_RYU_IDLE3:
	
		movia r4, ryu_idle1
		
		call draw_on_vga
		#pop arg from the stack
		addi sp, sp, 4
		
		movia r8, RYU_STATE
		movi r9, IDLE4
		
		stw r9, 0(r8)
		
		br done
	
	DRAW_RYU_IDLE4:
		
		movia r4, ryu_idle3
		
		call draw_on_vga
		#pop arg from the stack
		addi sp, sp, 4
		
		movia r8, RYU_STATE
		movi r9, IDLE1
		
		stw r9, 0(r8)
		
		br done
	
	DRAW_RYU_MOVE_RIGHT:
		
		movia r4, ryu_move_right
		
		call draw_on_vga
		#pop arg from the stack
		addi sp, sp, 4
		
		br RESET_RYU
		
	DRAW_RYU_MOVE_LEFT:
		
		movia r4, ryu_move_left
		
		call draw_on_vga
		#pop arg from the stack
		addi sp, sp, 4
		
		br RESET_RYU
		
	DRAW_RYU_PUNCHING:
		
		movia r4, ryu_right_punch
		
		call draw_on_vga
		#pop arg from the stack
		addi sp, sp, 4
		
		br RESET_RYU
	
	DRAW_RYU_KICKING:
		
		movia r4, ryu_left_kick
		
		call draw_on_vga
		#pop arg from the stack
		addi sp, sp, 4
		
		br RESET_RYU

	UNKNOWN:
		#get back to a known state
		stw r0, (r8)
		
	RESET_RYU:
		#Set Ryu back to his idle state
		
		movia r8, RYU_STATE
		stw r0, 0(r8)
		
		br done
		
	KEN_WINS:
	
		movia r4, ken_win_screen
		call draw_win_screen
		
		movia r8, GAME_STATE
		movi r9, WIN_STATE
		stw r9, 0(r8)
		
		br done
		
	RYU_WINS:
	
		movia r4, ryu_win_screen
		call draw_win_screen
		
		movia r8, GAME_STATE
		movi r9, WIN_STATE
		stw r9, 0(r8)
		
		br done

	done:

		#Reset flag to 0
		movia r8, DRAW_CHAR
		stb r0, 0(r8)
		
		ldw ra, (sp)
		addi sp, sp, 4
		ret
