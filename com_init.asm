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
	mov si, regs              ;The lesser evil...
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

	sub si, si
	mov ch, 1
show_mem_loop:
	test cl, 0x0F
	jnz show_mem_no_ofs
	mov dl, 0x0A
	int 0x21
	mov bx, cs
	call print_num_16bit
	mov bx, si
	call print_num_16bit
show_mem_no_ofs:
	lodsb
	call print_num_8bit
	loop show_mem_loop

	ret

;Precondition: ah= 0x02, bx= n
print_num_16bit:
	mov dh, 8
	jmp print_num_loop
;Precondition: ah= 0x02, al= n
print_num_8bit:
	mov dh, 4
	mov bh, al
print_num_loop:
	rol bx, 4
	mov al, bl                ;This block...
	and al, 0x0F              ;
	cmp al, 10                ;
	jge print_num_gt_10       ;
	add al, '0' - ('A' - 10)  ;
print_num_gt_10:                  ;
	add al, 'A' - 10          ;...can probably be optimized further
	mov dl, al
	int 0x21
	sub dh, ah
	jnz print_num_loop
	mov dl, ' '
	int 0x21
	ret

;Compressed registers names (see encode.py)
regs:
        db 0x03, 0x0c, 0x71, 0x7c, 0xf1, 0xf3, 0xf2, 0xf0
        db 0xa3, 0xa4, 0xac, 0xa2, 0xa5, 0xa6, 0x35
