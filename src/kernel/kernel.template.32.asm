
bits		32
section		.text
    align	4
    dd		0x1BADB002
    dd		0x00
    dd		- (0x1BADB002+0x00)

global	start
extern kmain						; the entry function kmain in the object file
start:
        cli							; clear the interrupts
        call kmain					; instruct processor to continue execution from kmain function in c code
        hlt							; halt the cpu from this address