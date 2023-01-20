BITS 16
ORG  0x100

;preconditions: ah = 0, bx = 0, top of memory = 0x9FFF

%define INTERLEAVED 1

%if INTERLEAVED
	bitmask equ 0xc0
%else
	bitmask equ 0xe0
%endif

	mov al, 0x13
	int 0x10
	lds ax, [bx]
				  	; bx = x = 0
	aam 0x55		  	; ax = y = 547 (long orbit)
	mov dx, 0x03C9
L:
 	dec si			  	; frame--
	xchg ax, bx		  	; x' = y, y' = x
	neg bx			  	; x' = -y, y' = x
	mov di, ax
A:
	neg di
	js A
	lea bx, [bx + di + 512]   	; x' = 512 - y + |x|, y' = x
	pusha
	and al, bitmask
	imul di, ax, byte 10  	  	; di = 320 * y
	shrd ax, si, 18		 	; ax = frame >> 2 (sharper: mov ax, si)
	out dx, al
	out dx, al
	out dx, al		  	; set_palette( ~frame, al, al, al )
	sar bx, 5		  	; bx = x >> 5
	inc byte [bx + di + 0x4B92]	; pixels[bx + di + align]++
	in ax, 0x60
	dec ax
	popa
	jnz L

	ret
