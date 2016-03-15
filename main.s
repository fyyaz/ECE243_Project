/*
main funcion enables interrupts, and calls other subroutines
*/

.global _start
_start:

	call draw_on_vga

	stop: br stop