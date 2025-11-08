[bits 32]
[section .multiboot]
align 4

multiboot_header:
	dd 0x1BADB002           ; Magic number
	dd 0x0                  ; No flags
	dd -(0x1BADB002 + 0x0)  ; Checksum

[section .text]
global start
extern kmain    ; We tell to NASM 'kmain' exits (in Zig)

start:
	cli                 ; Stop interruptions
	mov esp, stack_top  ; We point the stack pointer to ‘stack_top’, which we define in .bss
	call kmain          ; Now we can call Zig code

.halt:
	hlt         ; Use hlt to save CPU cycles
	jmp .halt   ; Infinite loop

[section .bss]
align 16
; We reserve memory for the stack,
; 16384 bytes = 16KB, it's wide to start with.
; The stack grows downward (from top to bottom).
stack_bottom:
	resb 16384 ; 16KB
stack_top:
	; The ‘stack_top’ symbol is at the end of this area,
	; that's where ESP needs to start.