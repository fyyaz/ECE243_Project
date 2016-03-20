# this subroutine updates the screen (VGA), depending on,
# the current value of the game state variable (GAME_STATE)
# using registers:
# 	 r4, r5, r6 as function arguements for called subroutines
#    r8, r9 to hold temporary values, and addresses

.global update

update:
	addi sp, sp, -4
	stw ra, (sp)

	movia r8, GAME_STATE
	ldwio r9, (r8)

	#check if drawing without space
	movi r10, DRAW_BACKGROUND
	beq r9, r10, GOTO_SPACE #currently displaying without spaces, now show the one with space bar text
	#chek if drawing the start screen with spaces
	movi r10, DRAW_BACKGROUND_SPACE
	beq r9, r10, GOTO_NO_SPACE
	#check if game has just been started, if so initialize the game
	movi r10, GAME_STARTED
	beq r9, r10, INIT

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
		stwio r9, (r8)
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
		stwio r9, (r8)
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
		#set the next state as PLAYING 
		##TODO
		br done

	UNKNOWN:
		#get back to a known state
		stw r0, (r8)

	done:
		ldw ra, (sp)
		addi sp, sp, 4
		ret
