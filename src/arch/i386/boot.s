.set ALIGN, 1 << 0
.set MEMINFO, 1 << 1
.set FLAGS, ALIGN | MEMINFO
.set MAGIC, 0x1BADB002
.set CHECKSUM, -(MAGIC + FLAGS)

.section .multiboot
.align 4
.global multiboot_header
multiboot_header:
	.long MAGIC
	.long FLAGS
	.long CHECKSUM

.section .text
.global _start
.type _start, @function
_start:
	movl $stack_top, %esp  # We point the stack pointer to ‘stack_top’, which we define in .bss
	call kmain          # Now we can call Zig code
	cli

.halt:
	hlt         # Use hlt to save CPU cycles
	jmp .halt   # Infinite loop

.size _start, . - _start

.section .bss
.align 16
stack_bottom:
	.skip 16384 # 16KB
stack_top:
	# The ‘stack_top’ symbol is at the end of this area,
	# that's where ESP needs to start.
