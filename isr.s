/*
ISR
*/

.section .exceptions, "ax"
ISR:
	#Push current register values onto the stack
	addi sp, sp, -20
	stw r8, 0(sp)
	stw r9, 4(sp)
	stw r10, 8(sp)
	stw r11, 12(sp)
	stw r12, 16(sp)
	addi sp, sp, -16
	stw r4, 0(sp)
	stw r5, 4(sp)
	stw r6, 8(sp)
	stw ra, 12(sp)

	rdctl et, ctl4
	andi et, et, 0x080 #Check if keyboard interrupted
	beq et, r0, CHECK_TIMER #If PS/2 didn't interrupt check the timer
	br SERVE_PS2

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
		#popopopopop
		ldw r4, 0(sp)
		ldw r5, 4(sp)
		ldw r6, 8(sp)
		ldw ra, 12(sp)
		addi sp, sp, 16
		#Pop off values on the stack
		ldw r12, 16(sp)
		ldw r11, 12(sp)
		ldw r10, 8(sp)
		ldw r9, 4(sp)
		ldw r8, 0(sp)
		addi sp, sp, 20
		
		subi ea, ea, 4
		eret