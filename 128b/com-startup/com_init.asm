BITS 16
ORG  0x100

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
	mov cl, 15                ;ch will be cleared after the first
				  ;call to print_hex_u16
show_regs_loop:
	lodsb                     ;Load encoded reg name into al
	aam 0x10                  ;Unpack al (4:4) -> ah:al
	daa                       ;Magic
	add ax, 'A' + ('I' * 256) ;ax = reg name (reverse order)
	call print_ch
	mov dl, dh
	int 0x21
	mov dl, '='
	int 0x21
	pop bx
	call print_hex_u16
	loop show_regs_loop
                                  ;Now si points to print_hex_u16
	sub di, di
show_mem_loop:
	test cl, 0x0F
	jnz show_mem_data
	mov dl, 0x0A
	int 0x21
	mov bx, cs
	call si                   ;print_hex_u16
	mov bx, di
	call si                   ;print_hex_u16
show_mem_data:
	mov bh, [di]              ;technically should use the cs: prefix,
                                  ;but we know ds = cs
	inc di
	call print_hex_u8
	dec cl
	jnz show_mem_loop

	ret

;Encoded registers names (see encode_regs.py)
regs:
        db 0x03, 0x0c, 0x71, 0x7c, 0xf1, 0xf3, 0xf2, 0xf0
        db 0xa3, 0xa4, 0xac, 0xa2, 0xa5, 0xa6, 0x35

;Precondition: ah = 0x02, bx = n
print_hex_u16:
	mov ch, ah
;Precondition: ah = 0x02, ch = 0x00, bh = n
print_hex_u8:
	add ch, ah                ;Clears AF
print_hex_loop:
	rol bx, 4
	mov al, bl
        aaa                       ;AF should be undefined after rol
                                  ;but practically stays cleared
        jnc print_hex_lt10_xdigit
	add al, 'A' - '0'
print_hex_lt10_xdigit:
	add al, '0'
	call print_ch
	dec ch                    ;Clears AF
	jnz print_hex_loop
	mov al, ' '
print_ch:
	xchg ax, dx
	mov ah, 2
	int 0x21
	ret
