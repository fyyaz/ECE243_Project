#Tharindu Silva
#1001471329

.global draw_health_bars

draw_health_bars:
	addi sp, sp, -4
	stw ra, (sp)

	movia r4, health_bar
	movia r5, KEN_HEALTH
	ldw r5, 0(r5)
	movi r6, 15
	movi r7, 20
	addi sp, sp, -4
	stw r7, 0(sp)
	movi r7, 30
	call draw_on_vga
	
	#pop the last arg from stack
	addi sp, sp, 4
	
	movia r4, health_bar
	movia r5, RYU_HEALTH
	ldw r5, 0(r5)
	movi r6, 15
	movia r7, 20
	addi sp, sp, -4
	stw r7, 0(sp)
	movi r7, 190
	call draw_on_vga
	
	#pop the last arg from stack
	addi sp, sp, 4

	ldw ra, (sp)
	addi sp, sp, 4
	ret