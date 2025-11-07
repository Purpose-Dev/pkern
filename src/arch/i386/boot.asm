[bits 32]
[section .multiboot]
align 4

multiboot_header:
	dd 0x1BADB002
	dd 0x0
	dd -(0x1BADB002 + 0x0)

[section .text]
global start
start:
	extern kmain
	call kmain

.halt:
	jmp .halt