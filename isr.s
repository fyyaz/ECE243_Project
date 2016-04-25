#Tharindu Silva
#1001471329

/*
ISR
*/

.section .exceptions, "ax"
ISR:
	#Push current register values onto the stack
	addi sp, sp, -52 #save any GPR that interrupt clobbers
	stw r8, 0(sp)
	stw r9, 4(sp)
	stw r10, 8(sp)
	stw r11, 12(sp)
	stw r12, 16(sp)
	#calling functions so must save arguments, return address and return values 
	stw r4, 20(sp)
	stw r5, 24(sp)
	stw r6, 28(sp)
	stw r7, 32(sp)
	stw ra, 36(sp)
	stw r2, 40(sp)
	stw r3, 44(sp)
	stw r13, 48(sp)
	
	rdctl et, ctl4
	andi r8, et, 0b010
	movi r9, 0b010
	beq r8, r9, SERVE_PUSH_BUTTON#Check if push button interrupted
	andi et, et, 0x080 #Check if keyboard interrupted
	beq et, r0, CHECK_TIMER #If PS/2 didn't interrupt check the timer
	br SERVE_PS2
	
	SERVE_PUSH_BUTTON:
		call push_button
		br EXIT_EXCEPTION

	CHECK_TIMER:
		rdctl et, ctl4
		andi et, et, 0b01 
		beq et, r0, EXIT_EXCEPTION #neither timer nor ps2 interrupted

	#SERVE TIMER
	call update
	#acknowledge timer interrupt and restart it
	movia r9, TIMER
	stwio r0, (r9)
	movi r8, 0b0101
	stwio r8, 4(r9)
	br EXIT_EXCEPTION
	
	SERVE_PS2:
		call ps2

	EXIT_EXCEPTION:
		#pop gpr
		ldw r8, 0(sp)
		ldw r9, 4(sp)
		ldw r10, 8(sp)
		ldw r11, 12(sp)
		ldw r12, 16(sp)
		#pop function reserved register 
		ldw r4, 20(sp)
		ldw r5, 24(sp)
		ldw r6, 28(sp)
		ldw r7, 32(sp)
		ldw ra, 36(sp)
		ldw r2, 40(sp)
		ldw r3, 44(sp)
		ldw r13, 48(sp)
		addi sp, sp, 52	
		subi ea, ea, 4
		eret