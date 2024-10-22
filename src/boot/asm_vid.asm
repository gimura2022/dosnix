[bits 16]

global vidint_set_mode
vidint_set_mode:	                                                               
	push bp
	mov bp, sp

	push ax

	mov ah, 0x0
	mov al, [bp + 6]
	int 0x10

	pop ax

	mov sp, bp
	pop bp

	ret

global vidint_print_char
vidint_print_char:
	push bp
	mov bp, sp

	push ax

	mov ah, 0x0e
	mov al, [bp + 6]
	int 0x10

	pop ax

	mov sp, bp
	pop bp

	ret
