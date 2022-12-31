ORG 0x100

main:
	pushf
	push gs
	push fs
	push cs
	push ss
	push es
	push ds
	pusha			  ;push ax, cx, dx, bx, sp, bp, si, di
				  ;sp should be adjusted but \_(^ ^)_/
	mov si, regs
	mov cx, 15                ;Don't assume ch = 0
show_regs_loop:
	lodsb                     ;Load encoded reg name into al
	aam 0x10                  ;Unpack al (4:4) -> ah:al
	daa                       ;Magic
	add ax, 'A' + ('I' * 256) ;ax = reg name (reverse order)
	xchg ax, dx
	mov ah, 2
	int 0x21
	mov dl, dh
	int 0x21
	mov dl, '='
	int 0x21
	pop bx
	call print_num_16bit
	loop show_regs_loop

	sub di, di
show_mem_loop:
	test cl, 0x0F
	jnz show_mem_no_ofs
	mov dl, 0x0A
	int 0x21
	mov bx, cs
	call si                   ;print_num_16bit
	mov bx, di
	call si                   ;print_num_16bit
show_mem_no_ofs:
	mov bh, [di]
	inc di
	call print_num_8bit
	dec cl
	jnz show_mem_loop

	ret

;Compressed registers names (see encode_regs.py)
regs:
        db 0x03, 0x0c, 0x71, 0x7c, 0xf1, 0xf3, 0xf2, 0xf0
        db 0xa3, 0xa4, 0xac, 0xa2, 0xa5, 0xa6, 0x35

;Precondition: ah = 0x02, bx = n
print_num_16bit:
	mov ch, ah
;Precondition: ah = 0x02, dh = 0x00, bh = n
print_num_8bit:
	add ch, ah                ;Clears AF
print_num_loop:
	rol bx, 4
	mov al, bl
        aaa                       ;AF should be undefined after rol
                                  ;but practically stays cleared
        jnc print_num_lt10_digit
	add al, 'A' - '0'
print_num_lt10_digit:
	add al, '0'
	mov dh, 2
	xchg ax, dx
	int 0x21
	dec ch
	jnz print_num_loop
	mov dl, ' '
	int 0x21
	ret
