.section .text
.align 4

.global isr_stub_keyboard
.extern keyboard_handler
.extern pic_ack

isr_stub_keyboard:
	# Push EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI on Stack
	call keyboard_handler
	# Calling Zig Handler, Zig using C call convention (so it's compatible)
	pusha
	# PIC acknowledgment (very important, otherwise the keyboard locks up after one keystroke)
	# We sending the EOI signal (End Of Interrupt)
	call pic_ack
	# Context Restoration (Retrieve everything that has been pushed onto the stack)
	popa
	# Interruption return (Special instruction that restores EFLAGS and CS:EIP)
	iret
