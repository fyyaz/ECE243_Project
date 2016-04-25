#Tharindu Silva
#1001471329

/*
 * This function is called by the ISR to
 * handle push button interrupts
 */

.global push_button

push_button:
	movia r8, PUSH_BUTTONS
	ldwio r9, 0(r8)
	movi r10, 0b010
	stwio r10, 12(r8) #Clear edge capture register

	#Reset game state
	movia r8, GAME_STATE
	stw r0, 0(r8)
	
	#Reset character states
	
	#Ken
	movia r8, KEN_STATE
	stw r0, 0(r8)
	
	#Ryu
	movia r8, RYU_STATE
	stw r0, 0(r8)
	
	#Reset characters positions
	
	#Ken
	movia r8, KEN_POSITION
	movi r9, 39
	stw r9, 0(r8)
	
	#Ryu
	movia r8, RYU_POSITION
	movi r9, 289
	stw r9, 0(r8)
	
	#Reset characters health
	
	movi r9, 100
	
	#Ken
	movia r8, KEN_HEALTH
	stw r9, 0(r8)
	
	#Ryu
	movia r8, RYU_HEALTH
	stw r9, 0(r8)
	
EXIT:
	ret