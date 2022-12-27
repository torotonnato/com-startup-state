all: com_init.com

com_init.com: com_init.asm
	nasm com_init.asm -o com_init.com
	ls com_init.com -l

clean:
	rm com_init.com

