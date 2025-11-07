ENTRY(start)

OUTPUT_FORMAT(elf32-i386)
OUTPUT_ARCH(i386)

SECTIONS
{
	. = 1M;

	.text : {
		*(.multiboot)
        *(.text*)
        *(.rodata*)
	}

	.data : {
        *(.data*)
    }

    .bss : {
        *(.bss*)
        *(COMMON)
    }
}
