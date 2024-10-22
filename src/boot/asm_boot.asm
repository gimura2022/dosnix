[bits 16]

extern boot_entry

boot_start:
	call boot_entry

	jmp halt

global halt
halt:
	cli
	hlt
	jmp halt