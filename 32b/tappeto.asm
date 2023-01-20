BITS 16
ORG  0x100

%define EVOLUTION 0

;precoditions: ah = 0, bx = 0, top of memory = 0x9FFF


	mov al, 0x13
	int 10h
	les ax, [bx]
	mov si, 320
L:
	lea ax, [di - 16]
	sub dx, dx
	div si
	add ax, bx
	mul dx
	mul ax			  ; pixel = ((x&255)*((y+frame)&255))^2

%if EVOLUTION = 1
	mul bh			  ; pixel *= frame >> 8
%elif EVOLUTION = 2
	cmp al, 0
	jz W
	add al, bh		  ; pixel += pixel ? (frame >> 8) : 0
%endif

W:
	stosb
	loop L
	inc bx
	in ax, 0x60
	dec ax
	jnz L

	ret
