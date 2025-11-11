ENTRY(_start)

OUTPUT_FORMAT(elf32-i386)
OUTPUT_ARCH(i386)

SECTIONS
{
	. = 1M;

	.text : ALIGN(4K) {
		*(.multiboot)
        *(.text*)
        *(.rodata*)
	}

	.data : {
        *(.data*)
    }

    .bss : {
        *(COMMON)
        *(.bss*)
    }
}
